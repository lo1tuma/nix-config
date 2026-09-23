---
name: flow-plan-refactoring
description: Survey a codebase or a named area for design problems, then turn the findings into an ordered plan of pull-request-sized refactoring steps. Use to start a refactoring session, when a codebase feels hard to change, or when you want a campaign rather than a single cleanup.
metadata:
  short-description: Find and plan a refactoring campaign
---

# Plan Refactoring

Find what is worth changing across a scope, then produce a plan somebody can execute one pull request at a time.

Planning only. Nothing is changed here. `flow-refactor-next` executes the steps.

## Scope

Take the named area, or the whole repository when none is named. State the scope before surveying, and account for what is excluded and why.

Weight the survey toward code that changes often. Run `git log --since="6 months ago" --pretty=format: --name-only` and rank by change frequency. A smell in code nobody touches costs nothing.

## Survey

Read `~/.agent-skill-library/CATALOG.md` and select lenses for the scope. The same set `flow-review-design` uses applies here, plus:

| Question | Lens |
|---|---|
| Which smell is this, and which move fixes it? | `fowler` |
| Is this duplication in shape rather than text? | `same-results-less-code` |
| Should this be one thing or stay several? | `duplication-vs-abstraction` |
| Is the cleanup worth doing at all, and when? | `tidy` |

`simplify-codebase` covers the hand-rolled and shallow-module family at repository scale. Use it as one lens among these rather than as a separate pass.

Fan out one read-only subagent per lens, in parallel, with fresh context. Each returns findings with a location, the claim, the evidence, the named move, and what it makes harder today.

Merge by cause. Drop anything that fails its lens's when-not test, and anything whose cost cannot be stated.

## Plan

Group findings into steps. A step is one coherent change: one smell family, one module, or one replaceable mechanism. It must be small enough to review in one sitting and must leave the repository working.

Order the steps:

1. Preparatory moves first. If a step makes a later step easier, it goes before it.
2. Behaviour-preserving before anything that changes behaviour.
3. Independent steps marked as such, so they can run in parallel worktrees.
4. High-traffic code before code nobody reads.

For each step record: what it fixes, the files, the named move, what must be true before it starts, which steps it unblocks, its risk, and how it will be verified.

State explicitly which findings you are not planning to fix, and why. A campaign that pretends to cover everything gets abandoned.

## Output

Write the plan to a file in the operating system temporary directory, not into the working tree, unless the user asks otherwise. Report the path.

The plan holds the scope, what was excluded, the ranked steps with their dependencies, the findings deliberately left alone, and a status field per step that `flow-refactor-next` updates.

Offer `grill-me` on the plan when it has more than a handful of steps. Then hand over to `flow-refactor-next`.
