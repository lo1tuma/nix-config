---
name: address-review-comments
description: Walk through unresolved GitHub PR review threads interactively, one by one. For each thread summarize the comment, propose a fix, ask the user for confirmation or adjustment, then apply the change, post a concise reply, and mark the thread resolved. Use when the user wants to triage or address pending PR review feedback.
---

# Address PR review comments

## Operating rules — read first

This skill is an **interactive walkthrough**. You handle one thread at a time, in full, before moving to the next.

For every thread you MUST:

1. Present the thread and propose both the **code fix** and the **reply text**.
2. Wait for the user's explicit confirmation via `AskUserQuestion`.
3. Only then apply edits, post the reply, or resolve the thread.

You MUST NOT:

- Edit any file before the user confirms the proposed fix for that specific thread.
- Post any reply before the user confirms (or adjusts) the proposed reply wording.
- Resolve a thread without an explicit confirmation for it.
- Batch threads, pre-apply changes, or "do all the easy ones first".

If at any point you are unsure whether the user has confirmed: stop and ask.

## Scope

Cover both threads attached to code lines and PR-level review threads (no file/line). Skip resolved threads. Skip issue-style PR comments — those have no thread state.

## Prerequisites

Always invoke `gh` via `nix-shell -p gh --run '<cmd>'`. Assume `gh` is not on the global PATH and the user is authenticated; do not probe `gh --version` or `gh auth status`.

## Step 1 — identify the PR

If the user passed a PR number or URL, use it. Otherwise:

```bash
gh pr view --json number,url,headRepositoryOwner,headRepository,baseRefName,headRefName
```

If `gh pr view` errors with "no pull requests found", ask the user for the PR number/URL before continuing.

Capture `owner`, `repo`, `number` from the output. Use them in every subsequent call.

## Step 2 — list unresolved review threads

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

Filter to `isResolved == false`. Keep top-to-bottom order (by file, then PR-level). For each thread keep: `thread.id` (node ID, starts with `PRRT_`), `path`, `line`, first comment author + body, last reply (if any), and the **first comment's `databaseId`** — needed for the REST reply endpoint.

Report the count before iterating: e.g. "7 unresolved threads. Walking through them now."

## Step 3 — for each unresolved thread

Strict order: 3a → 3b → 3c → 3d → 3e. Do not skip ahead. Do not start the next thread until 3e is done (or the user skips).

### 3a. Present the thread, propose fix and reply

Show the user, in one message:

- **Location**: `path:line` or "PR-level" if `path` is null.
- **Reviewer**: original author, latest comment quoted verbatim (truncate only if very long).
- **Summary**: one sentence on what the reviewer is asking for.
- **Proposed fix**: concrete code change, doc edit, clarification, or "no change needed because X". If on code, read the file around the line first so the suggestion reflects current code (comments may be outdated).
- **Proposed reply**: the exact 1–2 sentence reply you would post to the thread, in plain prose. State what was done or why no change. No filler, no sign-off.

Do not edit any file at this stage. The proposal is text only.

### 3b. Ask for confirmation

Use `AskUserQuestion` with these options:

- **Apply** — apply the proposed fix and post the proposed reply as-is.
- **Adjust fix** — user wants to change the code/doc change; capture their direction.
- **Adjust reply** — user wants to change the reply wording; capture their direction.
- **Skip** — leave the thread unresolved, move to the next.

Treat "Stop" as available via the standard chat — the user can interrupt at any time.

If the user picks **Adjust fix** or **Adjust reply**, loop back to 3a with the revised proposal. Keep looping until they pick **Apply** or **Skip**.

### 3c. Apply the change (only after Apply)

- For code/doc changes: edit the files.
- For "no change needed" threads: nothing to apply; continue to 3d.

Do not run the project quality gate per thread. Run it once at the end of the full walkthrough (Step 4), unless the user asks otherwise.

### 3d. Post the reply (only after Apply)

Use the confirmed reply text verbatim. REST endpoint with the first comment's `databaseId` as `comment_id`:

```bash
gh api \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$OWNER/$REPO/pulls/$NUMBER/comments/$COMMENT_ID/replies" \
  -f body="$REPLY_BODY"
```

For PR-level review threads (no file/line) the same endpoint works against the first comment's `databaseId`.

### 3e. Resolve the thread (only after Apply)

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: { threadId: $threadId }) {
      thread { id isResolved }
    }
  }' -F threadId="$THREAD_NODE_ID"
```

Verify `isResolved: true` in the response before moving on. If the mutation fails (e.g. permission), surface the error and ask the user how to proceed — do not silently continue.

## Step 4 — wrap up

After the last thread:

- Summarize: how many resolved, how many skipped, files touched.
- If any code changed, run the quality gate now and report PASS/FAIL: `npx just quality-gate agentic > /dev/null 2>&1 && echo PASS || echo FAIL`.
- Do **not** commit, push, or request re-review unless the user asks.

## Notes and edge cases

- **Outdated threads** (`isOutdated: true`): still walk through them. The reviewer's intent may already be addressed — confirm by reading the current code, then either reply "addressed in <commit/refactor>" and resolve, or treat like any other thread.
- **Multiple comments in one thread**: read the whole conversation before summarizing; the last reply often narrows the ask.
- **Threads authored by the current user**: still walk through them (the user may have left TODOs for themselves).
- **Pagination**: if `hasNextPage` is true, fetch the next page with `cursor` before iterating.
- **Suggested-change blocks** (` ```suggestion `): if the reviewer included one and the user picks **Apply**, use that exact diff.
