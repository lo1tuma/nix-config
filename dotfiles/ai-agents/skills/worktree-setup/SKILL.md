---
name: worktree-setup
description: Create a fresh git worktree from the latest remote base branch and stop without doing project work. Use when the user invokes `$worktree-setup` with an optional topic, or when another skill needs an isolated worktree.
metadata:
  short-description: Create an isolated worktree and stop
---

# Worktree Setup

Create one isolated worktree. Treat the text after `$worktree-setup` only as an
optional topic for naming the branch. Never interpret it as a task to perform.

Require a git repository at the launch directory and an `origin` remote. If
either is missing, report the problem and stop.

## Base branch

Resolve the remote default branch instead of assuming `main`:

1. Run `git remote set-head origin --auto`.
2. Read `git symbolic-ref --short refs/remotes/origin/HEAD` and remove the
   `origin/` prefix.
3. If the repository instructions explicitly name another base branch, use it
   instead.

## Setup

1. Inspect `git status --short` and preserve every existing change.
2. Fetch the resolved base with `git fetch origin <base>`.
3. Choose the branch name:
   - With a topic, derive a concise semantic name in lowercase ASCII kebab-case.
     Omit ticket numbers and tool or agent prefixes.
   - Without a topic, invent two or three whimsical fantasy words in lowercase
     kebab-case. Make them obviously unrelated to software or the repository.
4. Confirm the name does not exist as a local branch, remote branch, or worktree
   path. Choose another name if it collides.
5. Create `~/projects/.worktrees/<repository>` if needed.
6. Run `git worktree add -b <branch> ~/projects/.worktrees/<repository>/<branch> origin/<base>`.

Branch from `origin/<base>`, never local `HEAD`. Do not enter the worktree, edit
files, install dependencies, or perform project work.

When invoked directly, report only the branch name, worktree path, and base
branch, then stop. When composed by `$worktree-run`, return those values to that
workflow instead of ending the calling workflow.

Worktrees live under `~/projects/.worktrees`, never an operating system
temporary directory. They outlive the session. Remove one only when the user
asks.
