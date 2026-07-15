---
name: address-review-comments
description: Triage unresolved GitHub PR review threads. First read every thread as a whole and consolidate ones that a single fix resolves (the same point often gets raised across several files or lines). Then walk through each fix group interactively, propose one fix and a reply per thread, and confirm with the user. Apply code changes locally but stage every reply and thread resolution; only after a final confirmation post all replies, resolve all threads, and commit and push, as one atomic batch. Use when the user wants to triage or address pending PR review feedback.
---

# Address PR review comments

## Operating rules - read first

This skill is an interactive walkthrough with a batched submission. You first consolidate the threads into fix groups, then decide each group's fix and replies one at a time, but nothing reaches GitHub or git until a single final batch at the end.

Three phases:

1. **Consolidation**: read every unresolved thread and its full comment chain together, then group threads that a single fix would resolve. Confirm the grouping with the user.
2. **Walkthrough**: for every fix group, propose one fix and a reply per member thread, get the user's confirmation, then apply the code edit locally and record the replies and resolutions in a local batch ledger.
3. **Submission**: after every group is handled and the user confirms one final time, apply the whole batch at once: commit, push, post all replies, resolve all threads.

For every group you MUST:

1. Present the group and propose both the **single code fix** and the **reply text** for each member thread.
2. Wait for the user's explicit confirmation via `AskUserQuestion`.
3. Only then apply the local code edit and add the replies and thread ids to the batch ledger.

You MUST NOT, at any point before the final batch confirmation:

- Post any reply to GitHub.
- Resolve any thread.
- Commit or push anything.
- Apply a group's code edit before the user confirms that specific group.

Applying local code edits for each confirmed group is fine and expected; they stay uncommitted until the batch. If at any point you are unsure whether the user has confirmed: stop and ask.

## Scope

Cover both threads attached to code lines and PR-level review threads (no file/line). Skip resolved threads. Skip issue-style PR comments; those have no thread state.

## Prerequisites

Always invoke `gh` via `nix-shell -p gh --run '<cmd>'`. Assume `gh` is not on the global PATH and the user is authenticated; do not probe `gh --version` or `gh auth status`.

## Step 1 - identify the PR

If the user passed a PR number or URL, use it. Otherwise:

```bash
gh pr view --json number,url,headRepositoryOwner,headRepository,baseRefName,headRefName
```

If `gh pr view` errors with "no pull requests found", ask the user for the PR number/URL before continuing.

Capture `owner`, `repo`, `number` from the output. Use them in every subsequent call.

## Step 2 - list unresolved review threads

Fetch every review thread with its comments via GraphQL, paginate if needed:

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!, $cursor: String) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 50, after: $cursor) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            isOutdated
            path
            line
            originalLine
            subjectType
            comments(first: 50) {
              nodes {
                id
                databaseId
                url
                author { login }
                body
                createdAt
              }
            }
          }
        }
      }
    }
  }' -F owner="$OWNER" -F repo="$REPO" -F number="$NUMBER"
```

Filter to `isResolved == false`. Keep top-to-bottom order (by file, then PR-level). For each thread keep: `thread.id` (node ID, starts with `PRRT_`), `path`, `line`, first comment author + body, last reply (if any), and the **first comment's `databaseId`** (needed for the REST reply endpoint).

Report the count before iterating: e.g. "7 unresolved threads. Consolidating them now."

Start an empty **batch ledger** now. You append one entry per handled thread during Step 4 and drain it in Step 5. Each entry holds: thread node id (`PRRT_`), first comment `databaseId`, `path:line`, the confirmed reply text, and a short note of what changed (or "no change needed because X").

## Step 3 - consolidate related threads into fix groups

Before proposing anything, read every unresolved thread and its full comment chain together, as one set. Reviewers routinely raise the same underlying point in several places: the same issue duplicated across files, repeated on multiple lines, or split into separate threads. Usually one fix resolves all of them, and the replies should reflect that rather than pretending each is independent.

Group the threads:

- Put every thread that a single code (or doc) change would resolve into one **fix group**.
- Group by the underlying cause, not by surface wording or location. Same file is not required; a pattern flagged across several files belongs in one group.
- A thread with no sibling is a group of one.
- Do **not** merge threads that merely look similar but genuinely need distinct fixes. When unsure, keep them separate and note the uncertainty.

Order groups top-to-bottom by each group's earliest thread.

Present the proposed grouping in one message: for each group, list its member threads (`path:line` each, or "PR-level") and one sentence on the shared underlying ask. Call out explicitly which threads you consider duplicates of each other.

Confirm with `AskUserQuestion`:

- **Accept** - proceed with this grouping.
- **Adjust** - user splits or merges groups; capture the direction, re-present, and confirm again.

The walkthrough in Step 4 iterates over the confirmed groups, not individual threads. A group still produces one reply and one resolution per member thread; it just shares a single fix.

## Step 4 - walk through each fix group

Strict order: 4a → 4b → 4c. This phase decides and stages only. It performs **no** GitHub writes, commits, or pushes. Do not start the next group until 4c is done (or the user skips).

### 4a. Present the group, propose one fix and the replies

Show the user, in one message:

- **Members**: each member thread's `path:line` (or "PR-level"), with the latest comment quoted verbatim per thread (truncate only if very long). For a single-thread group this is just the one.
- **Reviewer(s)**: the authors involved.
- **Summary**: one sentence on the shared ask.
- **Proposed fix**: the single concrete change that resolves the whole group, or "no change needed because X". If on code, read the file around each member's line first so the suggestion reflects current code (comments may be outdated).
- **Proposed replies**: the exact 1-2 sentence reply for each member thread, in plain prose. Wording may be shared across members, but each thread gets its own reply. State what was done or why no change. No filler, no sign-off.

Do not edit any file at this stage. The proposal is text only.

### 4b. Ask for confirmation

Use `AskUserQuestion` with these options:

- **Apply** - apply the proposed fix locally once and stage the proposed replies as-is for every member thread.
- **Adjust fix** - user wants to change the code/doc change; capture their direction.
- **Adjust replies** - user wants to change the reply wording; capture their direction.
- **Skip** - leave the whole group unresolved and unstaged, move to the next.

Treat "Stop" as available via the standard chat; the user can interrupt at any time.

If the user picks **Adjust fix** or **Adjust replies**, loop back to 4a with the revised proposal. Keep looping until they pick **Apply** or **Skip**. If while working a group you conclude the grouping itself is wrong, say so and re-group the affected threads via Step 3 before continuing.

### 4c. Stage locally (only after Apply)

- For code/doc changes: apply the single fix now. Leave the files **uncommitted**.
- Append one entry to the batch ledger **per member thread**: thread node id, first comment `databaseId`, the confirmed reply text, and a short note of what changed (or "no change needed because X"). Use the same change note across the group's entries so the shared fix is obvious.
- Do **not** post the replies, resolve the threads, commit, or push. Move to the next group.

## Step 5 - apply the full batch

Reach this only after every fix group has been applied or skipped.

### 5a. Consolidated review

Show a single summary of the staged batch:

- Grouped by fix group: the one-line note of the local change, and for each member thread its `path:line` and the reply that will be posted.
- Which threads will be resolved, and which were skipped (and stay unresolved).
- Files touched.

### 5b. Quality gate

If any code changed, run the gate now and report PASS/FAIL:

```bash
npx just quality-gate agentic > /dev/null 2>&1 && echo PASS || echo FAIL
```

If it FAILs, surface it and let the user decide whether to fix first or submit anyway; do not submit silently over a failing gate.

### 5c. Final confirmation

Use `AskUserQuestion`:

- **Submit all** - commit, push, post every reply, resolve every thread.
- **Adjust** - go back to a specific staged group (re-run 4a-4c for it), then return here.
- **Abort** - leave everything local. Post nothing, resolve nothing, commit nothing.

### 5d. Execute the batch (only after Submit all)

Run in this exact order so replies and resolutions reference pushed code:

1. **Commit and push.** Commit the staged changes following the repo's commit conventions, then push the branch.
2. **Post every reply.** For each ledger entry, use the confirmed reply text verbatim against the first comment's `databaseId`:

   ```bash
   gh api \
     -X POST \
     -H "Accept: application/vnd.github+json" \
     "/repos/$OWNER/$REPO/pulls/$NUMBER/comments/$COMMENT_ID/replies" \
     -f body="$REPLY_BODY"
   ```

   For PR-level review threads (no file/line) the same endpoint works against the first comment's `databaseId`.
3. **Resolve every thread.** For each ledger entry:

   ```bash
   gh api graphql -f query='
     mutation($threadId: ID!) {
       resolveReviewThread(input: { threadId: $threadId }) {
         thread { id isResolved }
       }
     }' -F threadId="$THREAD_NODE_ID"
   ```

   Verify `isResolved: true` in each response.

### 5e. Report

Summarize: commit(s) pushed, replies posted, threads resolved, threads skipped.

If any batch step fails (push rejected, a reply post fails, a resolve permission error), stop, surface the error, and ask how to proceed. Do not resolve a thread whose reply failed to post, and do not silently continue past a failure.

## Notes and edge cases

- **Duplicate or related threads**: this is common and the reason Step 3 exists. The same fix may resolve threads on different files or lines; group them and apply the fix once, but still reply to and resolve each thread individually.
- **Outdated threads** (`isOutdated: true`): still include them. The reviewer's intent may already be addressed; confirm by reading the current code, then either stage a reply "addressed in <commit/refactor>" for the batch, or treat like any other thread.
- **Multiple comments in one thread**: read the whole conversation before summarizing; the last reply often narrows the ask.
- **Threads authored by the current user**: still include them (the user may have left TODOs for themselves).
- **Pagination**: if `hasNextPage` is true, fetch the next page with `cursor` before consolidating.
- **Suggested-change blocks** (` ```suggestion `): if the reviewer included one and the user picks **Apply**, use that exact diff.
