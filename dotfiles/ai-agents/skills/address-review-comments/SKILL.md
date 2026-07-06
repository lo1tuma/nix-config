---
name: address-review-comments
description: Walk through unresolved GitHub PR review threads interactively, one by one. For each thread summarize the comment, propose a fix and a reply, and confirm with the user. Apply code changes locally but stage every reply and thread resolution; only after a final confirmation post all replies, resolve all threads, and commit and push, as one atomic batch. Use when the user wants to triage or address pending PR review feedback.
---

# Address PR review comments

## Operating rules - read first

This skill is an interactive walkthrough with a batched submission. You decide each thread's fix and reply one at a time, but nothing reaches GitHub or git until a single final batch at the end.

Two phases:

1. **Walkthrough**: for every unresolved thread, propose a fix and reply, get the user's confirmation, then apply the code edit locally and record the reply and resolution in a local batch ledger.
2. **Submission**: after every thread is handled and the user confirms one final time, apply the whole batch at once: commit, push, post all replies, resolve all threads.

For every thread you MUST:

1. Present the thread and propose both the **code fix** and the **reply text**.
2. Wait for the user's explicit confirmation via `AskUserQuestion`.
3. Only then apply the local code edit and add the reply and thread id to the batch ledger.

You MUST NOT, at any point before the final batch confirmation:

- Post any reply to GitHub.
- Resolve any thread.
- Commit or push anything.
- Apply a thread's code edit before the user confirms that specific thread.

Applying local code edits for each confirmed thread is fine and expected; they stay uncommitted until the batch. If at any point you are unsure whether the user has confirmed: stop and ask.

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

Report the count before iterating: e.g. "7 unresolved threads. Walking through them now."

Start an empty **batch ledger** now. You append one entry per handled thread during Step 3 and drain it in Step 4. Each entry holds: thread node id (`PRRT_`), first comment `databaseId`, `path:line`, the confirmed reply text, and a short note of what changed (or "no change needed because X").

## Step 3 - walk through each unresolved thread

Strict order: 3a → 3b → 3c. This phase decides and stages only. It performs **no** GitHub writes, commits, or pushes. Do not start the next thread until 3c is done (or the user skips).

### 3a. Present the thread, propose fix and reply

Show the user, in one message:

- **Location**: `path:line` or "PR-level" if `path` is null.
- **Reviewer**: original author, latest comment quoted verbatim (truncate only if very long).
- **Summary**: one sentence on what the reviewer is asking for.
- **Proposed fix**: concrete code change, doc edit, clarification, or "no change needed because X". If on code, read the file around the line first so the suggestion reflects current code (comments may be outdated).
- **Proposed reply**: the exact 1-2 sentence reply you would post to the thread, in plain prose. State what was done or why no change. No filler, no sign-off.

Do not edit any file at this stage. The proposal is text only.

### 3b. Ask for confirmation

Use `AskUserQuestion` with these options:

- **Apply** - apply the proposed fix locally and stage the proposed reply as-is.
- **Adjust fix** - user wants to change the code/doc change; capture their direction.
- **Adjust reply** - user wants to change the reply wording; capture their direction.
- **Skip** - leave the thread unresolved and unstaged, move to the next.

Treat "Stop" as available via the standard chat; the user can interrupt at any time.

If the user picks **Adjust fix** or **Adjust reply**, loop back to 3a with the revised proposal. Keep looping until they pick **Apply** or **Skip**.

### 3c. Stage locally (only after Apply)

- For code/doc changes: edit the files now. Leave them **uncommitted**.
- Append an entry to the batch ledger: thread node id, first comment `databaseId`, the confirmed reply text, and a short note of what changed (or "no change needed because X").
- Do **not** post the reply, resolve the thread, commit, or push. Move to the next thread.

## Step 4 - apply the full batch

Reach this only after every unresolved thread has been applied or skipped.

### 4a. Consolidated review

Show a single summary of the staged batch:

- Each ledger entry: `path:line`, one-line note of the local change, and the reply that will be posted.
- Which threads will be resolved, and which were skipped (and stay unresolved).
- Files touched.

### 4b. Quality gate

If any code changed, run the gate now and report PASS/FAIL:

```bash
npx just quality-gate agentic > /dev/null 2>&1 && echo PASS || echo FAIL
```

If it FAILs, surface it and let the user decide whether to fix first or submit anyway; do not submit silently over a failing gate.

### 4c. Final confirmation

Use `AskUserQuestion`:

- **Submit all** - commit, push, post every reply, resolve every thread.
- **Adjust** - go back to a specific staged thread (re-run 3a-3c for it), then return here.
- **Abort** - leave everything local. Post nothing, resolve nothing, commit nothing.

### 4d. Execute the batch (only after Submit all)

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

### 4e. Report

Summarize: commit(s) pushed, replies posted, threads resolved, threads skipped.

If any batch step fails (push rejected, a reply post fails, a resolve permission error), stop, surface the error, and ask how to proceed. Do not resolve a thread whose reply failed to post, and do not silently continue past a failure.

## Notes and edge cases

- **Outdated threads** (`isOutdated: true`): still walk through them. The reviewer's intent may already be addressed; confirm by reading the current code, then either stage a reply "addressed in <commit/refactor>" for the batch, or treat like any other thread.
- **Multiple comments in one thread**: read the whole conversation before summarizing; the last reply often narrows the ask.
- **Threads authored by the current user**: still walk through them (the user may have left TODOs for themselves).
- **Pagination**: if `hasNextPage` is true, fetch the next page with `cursor` before iterating.
- **Suggested-change blocks** (` ```suggestion `): if the reviewer included one and the user picks **Apply**, use that exact diff.
