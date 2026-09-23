---
name: flow-implement-plan
description: Implement an agreed plan in small verifiable commits, self-review the result, and open the pull request. Use after a plan has been designed and grilled, when the outcome is agreed and the work is ready to be built.
metadata:
  short-description: Implement a grilled plan and open the PR
---

# Implement Plan

Build the agreed outcome, verify it, and hand over a reviewable pull request.

The outcome is already decided. Research implementation details rather than asking. Stop only when new evidence invalidates the plan, or before something that cannot be undone.

## Before starting

Read the plan, the repository's contribution guidelines, the neighbouring code, and the check command CI runs.

If the repository forbids AI assistance, stop and say so.

Follow the repository's own patterns over personal preference. Deviate only where the pattern cannot produce the agreed outcome, then apply the deviation consistently in every file you touch and report the rest as follow-up.

Work in a fresh worktree when other sessions may touch this repository.

## While building

Keep `typescript-best-practices` open for TypeScript work. Read `code-structure` and `tidy` from `~/.agent-skill-library/` when structure or cleanup decisions come up.

- Reuse before writing. Existing project code, then the standard library and platform, then a dependency the project already has. Check the project's pinned versions before deciding a built-in is unavailable. Hand-rolled code is the last option, and a new dependency needs approval.
- Names carry domain meaning. No `utils`, `helpers`, `manager`, or implementation details in names.
- No comments. If one feels necessary, reshape the code until it is not. Exceptions are a constraint the code cannot express, and then it names that constraint.
- No optional properties or optional arguments. Pass values explicitly.
- No rule suppression. Fix the code, not the rule.
- Structure and behaviour never change in the same commit. Tidy before the change only when it makes the change easier, otherwise tidy after.

## Tests

- Every input and failure path the change adds or changes gets a test that fails without the change.
- For a refactor, the existing tests pass unchanged before and after.
- Assert observable behaviour against a literal expected value. A test that would still pass if every import returned undefined tests nothing.
- Mock only a boundary you cannot control, never the unit under test.
- Never weaken an assertion to make a failing test pass. If the test is right, fix the code.

## Commits

One concrete change per commit, each leaving the repository working. Prefer baby steps. Match the subject style of `git log --oneline -30`.

Stage explicit repo-relative paths only. Never stage unrelated or untracked files, and leave personal notes untracked.

## Finishing

1. Run the check command CI runs, not only the tests you touched. If it cannot run, say so and label the change unverified.
2. Run `flow-review-design` on your own diff and apply what it finds.
3. Run `no-comments` on the diff.
4. Read the whole diff for scope creep and debug output. Revert what the outcome does not need.
5. Open the pull request following the repository's guidelines and the pull request rules in the shared instructions. Apply the body preflight before posting.

## Report

What changed, the decisions where you chose between workable alternatives, the checks you ran with their results, the abstractions you left out with the condition that would justify adding them, and the follow-ups. Verification belongs in the report, never in the pull request body.
