---
name: worktree-run
description: Create a fresh git worktree, enter it, and carry out the requested task in isolation. Use when the user invokes `$worktree-run` or asks to perform work in a separate worktree.
metadata:
  short-description: Run a task in an isolated worktree
---

# Worktree Run

Treat everything after `$worktree-run` as the task. Require a task. If none is
present, direct the user to `$worktree-setup` for setup without execution.

Before doing anything else in the task:

1. Derive a concise topic from the task.
2. Compose `$worktree-setup` with that topic. Its direct-invocation stop point
   returns control here after it creates the worktree.
3. Enter the returned path using the environment's worktree mechanism. When
   using `EnterWorktree`, pass `path`, never `name`. Otherwise use the returned
   path as the working directory for every command.
4. Report the worktree path and base branch, then carry out the task there.

For another requested skill, invoke it only after entering the worktree and pass
it the remainder of the task.

Never perform task work in the launch directory. Preserve all changes there.
