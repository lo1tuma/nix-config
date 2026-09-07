---
name: worktree
description: Start work in a fresh git worktree under ~/projects/.worktrees, branched off a freshly fetched base branch, so parallel Claude and Codex sessions on one repository never share a working tree. Use when the user prefixes a prompt with /worktree, or asks to work in a worktree, in isolation, or alongside other running sessions.
metadata:
  short-description: Work in a fresh isolated worktree
---

# Worktree

Set up an isolated worktree, then carry out the rest of the prompt inside it.

Requires a git repository at the launch directory. If there is none, say so and stop.

## Base branch

Resolve it. Never assume `main`.

1. `git remote set-head origin --auto`, then read `git symbolic-ref --short refs/remotes/origin/HEAD`. The local ref silently goes stale when the remote default branch changes, and this repairs it.
2. If the repository's own instructions name a different base, those win.

## Setup

Do this before anything else in the prompt.

1. `git fetch origin <base>`.
2. Name the branch after the change, following the global branch rules.
3. `mkdir -p ~/projects/.worktrees/<repository>`
4. `git worktree add -b <branch> ~/projects/.worktrees/<repository>/<branch, slashes replaced by dashes> origin/<base>`
5. Enter it with the `EnterWorktree` tool, passing `path`. Never pass `name`, which would create a second worktree in the wrong place.

Branch from `origin/<base>`, never from local `HEAD`. A clean base is the whole point, and the launch directory usually holds another session's uncommitted work.

Report the worktree path and the base branch it came from, then continue.

## Location

Always `~/projects/.worktrees`, never the operating system temporary directory. macOS autocleans temp directories and uncommitted work there is lost.

Nest one directory per repository so two repositories can carry the same branch name.

These worktrees outlive the session on purpose, and `ExitWorktree` cannot delete a worktree entered by path. Remove one only when the user asks.

## Rest of the prompt

Whatever follows `/worktree` is the real task.

- Plain text: carry it out in the worktree.
- Another skill, as in `/worktree /simplify-codebase`: once the worktree is ready, invoke that skill with the `Skill` tool, passing on anything that followed its name.
- Nothing: report that the worktree is ready and stop.
