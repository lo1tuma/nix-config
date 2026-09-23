---
name: flow-refactor-next
description: Execute the next step of a refactoring plan as its own pull request, verifying the finding still holds, applying the named move in small steps with tests green between them, and marking the step done. Use to work through a plan from flow-plan-refactoring, one step or continuously.
metadata:
  short-description: Execute the next refactoring step
---

# Refactor Next

Take one step from the plan and land it as a reviewable pull request.

## Select

Read the plan and take the first step whose blockers are all done. Take a named step instead when the user gives one.

Re-check the finding against current HEAD before touching anything. Earlier steps move the code, and a finding that no longer holds is marked obsolete in the plan rather than implemented. Say so and move to the next step.

## Prepare

Start in a fresh worktree branched off a freshly fetched base branch. Name the branch after the change, with no tool or ticket prefix.

Confirm the safety net. Identify the tests covering the code. When coverage is missing, write characterization tests first, in their own commit, and say that this happened.

## Execute

Read the move's mechanics from `fowler` in `~/.agent-skill-library/` and follow them as written, one small step at a time, running the tests between steps. Do not improvise the mechanics, that is what makes the move safe.

When the step needs a shape that does not exist yet, run `flow-code-design` for that shape first, then implement it.

- Structure and behaviour never mix in one commit.
- One catalog move per commit, tests green at each one.
- If a step breaks the tests, it was too big. Revert and take a smaller one.
- If a test breaks on a refactor that changed no behaviour, the test was testing the implementation. Rewrite it against the contract or delete it, and say which.
- Never weaken an assertion to get green.
- Hold the scope. Anything the step does not need is a follow-up, recorded in the plan, not a change.

## Finish

1. Run the check command CI runs.
2. Run `flow-review-design` on the diff and apply what it finds.
3. Read the whole diff for scope creep.
4. Open the pull request under the repository's guidelines and the shared pull request rules. The description says why the step exists and the shape of the change, never the verification.
5. Update the step's status in the plan, along with anything learned that changes a later step.

## Continuous mode

When asked to work through the plan rather than one step, repeat the cycle one pull request at a time. Independent steps may run in parallel worktrees when the plan marks them independent.

Stop and report when a step's finding no longer holds, when a step needs a decision the plan does not contain, when the check command fails for a reason outside the step, or when the plan is exhausted.

Never merge, and never start a step that depends on an unmerged one.
