---
name: address-review-comments
description: Walk through unresolved GitHub PR review threads interactively, one by one. For each thread summarize the comment, propose a fix, ask the user for confirmation or adjustment, then apply the change, post a concise reply, and mark the thread resolved. Use when the user wants to triage or address pending PR review feedback.
---

# Address PR review comments

Walk through every unresolved review thread on a pull request, one thread at a time. Cover both threads attached to code lines and threads without a file/line (PR-level review threads). Do not touch resolved threads. Do not touch issue-style PR comments — those have no thread state.

## Prerequisites

- Always invoke `gh` via `nix-shell -p gh --run '<cmd>'`. Assume `gh` is not on the global PATH and the user is authenticated; do not probe `gh --version` or `gh auth status`.

## Step 1 — identify the PR

If the user passed a PR number or URL, use it. Otherwise:

```bash
gh pr view --json number,url,headRepositoryOwner,headRepository,baseRefName,headRefName
```

If `gh pr view` errors with "no pull requests found", ask the user for the PR number/URL before continuing.

Capture `owner`, `repo`, `number` from the output. Use them in every subsequent call.

## Step 2 — list unresolved review threads

Use GraphQL to fetch every review thread with its comments, paginate if needed:

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

Filter to threads where `isResolved == false`. Keep the original order (top-to-bottom by file, then PR-level). For each thread keep: `thread.id` (node ID, starts with `PRRT_`), `path`, `line`, first comment author + body, last reply (if any), and the **first comment's `databaseId`** — needed for the REST reply endpoint.

Report the count to the user before iterating: e.g. "7 unresolved threads. Walking through them now."

## Step 3 — for each unresolved thread

Do the following in order. Never batch multiple threads in one user prompt.

### 3a. Present the thread

Show the user:

- File and line (`path:line`) or "PR-level" if `path` is null.
- Original author and the latest comment body (quote it verbatim, truncate only if very long).
- A one-sentence **summary** of what the reviewer is asking for.
- A concrete **suggested fix** — code change, doc edit, clarification reply, or "no change needed because X".

If the comment is on code, read the file around the line first so the suggestion is grounded in current code (the comment may be outdated).

### 3b. Get confirmation

Use AskUserQuestion with options:

- **Apply suggestion** — go ahead with the proposed fix and the proposed reply.
- **Adjust** — user wants to change the approach; let them describe it.
- **Skip** — leave the thread unresolved, move to next.
- **Stop** — abort the whole walkthrough.

If "Adjust", capture the user's direction and loop back to 3a with a revised suggestion until they pick Apply or Skip.

### 3c. Apply the change

- For code/doc changes: edit the files. Run the project quality gate (`npx just quality-gate agentic > /dev/null 2>&1 && echo PASS || echo FAIL`) only once at the end of the full walkthrough, not after every thread — unless the user asks otherwise.
- For "no change needed" threads: skip straight to the reply.

### 3d. Reply to the thread

Keep the reply short (1–2 sentences). State what was done or why no change. No filler, no sign-off.

Use the REST endpoint with the **first comment's `databaseId`** as `comment_id`:

```bash
gh api \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$OWNER/$REPO/pulls/$NUMBER/comments/$COMMENT_ID/replies" \
  -f body="$REPLY_BODY"
```

For PR-level review threads (no file/line) the REST replies endpoint still works against the first comment's `databaseId`.

### 3e. Resolve the thread

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
- If any code changed, run the quality gate now and report PASS/FAIL.
- Do **not** commit, push, or request re-review unless the user asks.

## Notes and edge cases

- **Outdated threads** (`isOutdated: true`): still walk through them. The reviewer's intent may already be addressed — confirm by reading the current code, then either reply "addressed in <commit/refactor>" and resolve, or treat like any other thread.
- **Multiple comments in one thread**: read the whole conversation before summarizing; the last reply often narrows the ask.
- **Threads authored by the current user**: still walk through them (the user may have left TODOs for themselves).
- **Pagination**: if `hasNextPage` is true, fetch the next page with `cursor` before iterating.
- **Suggested-change blocks** (` ```suggestion `): if the reviewer included one and the user picks Apply, use that exact diff.
- Caveman-mode chat output applies during the walkthrough; replies posted to GitHub use normal prose.
