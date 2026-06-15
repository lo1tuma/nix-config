---
name: fix-renovate-prs
description: Find open failing Renovate PRs in the current repository, fix small mechanical failures immediately, amend and force-push when appropriate, and ask the user before larger or risky fixes. Use when the user asks to fix Renovate PRs, unblock dependency update PRs, or run a workflow like /fix-renovate-prs.
metadata:
  short-description: Fix failing Renovate PRs
---

# Fix Renovate PRs

## Operating rules

Work one PR at a time. Do not batch edits across PRs.

For each failing Renovate PR:

- Fix small mechanical issues immediately.
- Ask the user before larger, risky, or ambiguous changes.
- Prefer `git commit --amend --no-edit` plus `git push --force-with-lease` for small fixes on Renovate's branch, especially when the PR has one bot commit and automerge depends on keeping the PR shape simple.
- Never use plain `git push --force`.
- Do not change CI, lint, formatter, type, or coverage rules to make a PR pass unless the user explicitly approves that exact change.
- Do not approve, merge, close, or enable automerge unless the user asks.

Small fixes are changes with an obvious local answer:

- formatter or linter autofixes
- import sorting
- lockfile refreshes
- small type or API adjustments directly caused by the updated dependency
- test fixture updates where the dependency's new output is clearly correct

Ask before changes involving:

- behavior changes
- public API changes
- data migrations
- broad refactors
- test expectation changes that encode product behavior
- suppressions, ignore lists, or rule config edits
- multiple plausible fixes
- failures not clearly caused by the dependency update

If the user confirms a larger fix, make only that confirmed fix, push it, then move to the next PR.

## Tools

Always invoke GitHub CLI through `nix-shell`:

```bash
nix-shell -p gh --run 'gh ...'
```

Use `nix-shell -p gh jq --run '...'` when JSON filtering needs `jq`.

Prefer the repository's own toolchain and documented commands. If a required command is not available globally, run it through `nix-shell` instead of assuming machine-local installs.

## Step 1: Check repository policy

Before editing or pushing, read the current repository's contribution and AI policy files if present:

```bash
rg --files -g 'CONTRIBUTING*' -g 'AI_POLICY*' -g 'AGENTS.md' -g 'agents.md' -g '.github/**'
```

If the repository forbids AI assistance for this work, stop and tell the user.

## Step 2: Find open failing Renovate PRs

Identify the current repository:

```bash
nix-shell -p gh --run 'gh repo view --json nameWithOwner,url'
```

List open PRs and filter to Renovate-authored PRs with failed, errored, timed-out, cancelled, or action-required checks:

```bash
nix-shell -p gh jq --run 'gh pr list --state open --limit 100 --json number,title,url,author,headRefName,headRepositoryOwner,headRepository,isCrossRepository,maintainerCanModify,baseRefName,statusCheckRollup,updatedAt | jq ".[]"'
```

Treat these author logins as Renovate unless the repository uses a different configured Renovate account:

- `renovate[bot]`
- `renovate-bot`
- any bot login whose normalized name is exactly `renovate`

For each candidate, inspect failing checks:

```bash
nix-shell -p gh --run 'gh pr checks PR_NUMBER --fail-fast=false'
```

Skip PRs that are only pending or blocked by required review. Report the count before starting.

## Step 3: Prepare a PR worktree

Avoid disturbing the user's current worktree.

For the current PR, create a temporary worktree from the PR head:

```bash
worktree=$(mktemp -d)
branch="renovate-pr-PR_NUMBER-fix"
git fetch origin "pull/PR_NUMBER/head"
git worktree add -B "$branch" "$worktree" FETCH_HEAD
cd "$worktree"
```

If the PR is cross-repository, or the head branch cannot be pushed through `origin`, stop and ask the user how to push before editing.

## Step 4: Diagnose the failure

Read the PR title, body, files, and failing checks:

```bash
nix-shell -p gh --run 'gh pr view PR_NUMBER --json title,body,files,commits,headRefName,baseRefName,url'
nix-shell -p gh --run 'gh pr checks PR_NUMBER --fail-fast=false'
```

Run the failing local command or the closest documented equivalent. Prefer the narrowest useful command first, then the full quality gate before pushing.

If the failure is mechanical and fits the small-fix rules, apply it immediately.

If the failure is larger or ambiguous, present exactly one PR to the user:

- PR number and title
- failing check names
- suspected cause
- proposed fix
- whether the push will amend or add a commit

Wait for explicit confirmation or revised instructions before editing.

## Step 5: Fix and verify

For small lint or formatter failures, run the autofix command first when available. Then inspect the diff and make any obvious follow-up edits needed to restore correctness.

For dependency API or type changes, make the smallest coherent migration. Prefer the updated package's documented migration path when available.

Before pushing, run:

- the originally failing command or closest local equivalent
- the repository's documented full quality gate, if practical

Do not weaken assertions, broaden snapshots, or relax quality rules only to make the check pass.

## Step 6: Commit and push

For small fixes, default to amending:

```bash
git add .
git commit --amend --no-edit
git push --force-with-lease origin HEAD:HEAD_REF_NAME
```

For larger confirmed fixes, use the push strategy confirmed with the user. If unsure, ask before committing.

After pushing, wait for checks or fetch the new check state:

```bash
nix-shell -p gh --run 'gh pr checks PR_NUMBER --watch --fail-fast=false'
```

If checks still fail, continue on the same PR until the remaining failure is fixed, skipped by the user, or clearly blocked.

## Step 7: Clean up and continue

After each PR:

- summarize the fix and push result in one or two sentences
- remove the temporary worktree when no longer needed
- move to the next failing Renovate PR

At the end, report:

- fixed PRs
- PRs skipped or awaiting user input
- PRs still failing and why
