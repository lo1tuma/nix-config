---
name: flow-review-design
description: Review a diff or a module for design quality by fanning out lenses as read-only subagents, merging their findings, and ranking what survives. Use when reviewing a pull request, self-reviewing a change before opening one, or judging the design of existing code. Read-only, it proposes changes rather than applying them.
metadata:
  short-description: Review a diff through the design lenses
---

# Review Design

Judge the design of a change. Report findings, change nothing.

This is quality review, not bug hunting. For correctness use the code review tooling the repository already has, and for vulnerabilities use `flow-security-audit`.

## Scope

Default to the diff against the base branch, including the working tree. Accept a named module or path instead.

Read the change as a whole before reading any lens. A finding that ignores what the change is for is noise.

## Lenses

Read `~/.agent-skill-library/CATALOG.md`, then choose the lenses the change actually touches.

| Surface | Lens |
|---|---|
| Structure, cohesion, coupling, interfaces, invariants | `code-structure` |
| Duplicated meaning, wrong frame, speculative generality | `same-results-less-code` |
| Shared abstraction versus duplication | `duplication-vs-abstraction` |
| Module depth and interface size | `functional-designing-deep-modules`, `design-deep-modules` |
| Merge or split a boundary | `module-boundaries` |
| Layers that add nothing | `pass-through-method-wrong-layer-count` |
| Leaked decisions, phase-named modules | `information-hiding-temporal-decomposition` |
| Generality of an interface | `general-vs-special`, `somewhat-general-purpose-interface` |
| Error handling | `error-design`, `define-errors-out-of-existence` |
| Types and illegal states | `principle-type-system-discipline` |
| Scattered conditionals | `principle-model-the-domain` |
| Pattern misuse or over-engineering | `design-patterns` |

## Process

1. **Select lenses.** Name them and say what in the change made each one relevant. A lens chosen because it exists produces findings nobody acts on.
2. **Fan out.** Dispatch one read-only subagent per lens, in parallel, with fresh context. Give each the scope, the lens path, and the finding shape below. Tell it to read the lens first and to apply that lens only.
3. **Merge.** Deduplicate by cause, not by location. Two lenses reaching the same spot raises confidence; two lenses describing one cause is one finding.
4. **Gate.** Drop every finding that fails its own lens's when-not test. Drop anything that is taste rather than cost. If the concrete cost cannot be named, it is not a finding.
5. **Rank** by cost of leaving it, not by how easy it is to describe.

## Finding shape

- `location`: `path:line`
- `lens`: which lens found it
- `claim`: the smell and the principle it violates, in one sentence
- `evidence`: what was read that supports the claim
- `cost`: what this makes harder, concretely
- `move`: the change to make, named
- `checked`: the when-not test that was applied and why it did not apply here
- `confidence`: and what would settle it if low

## Rules

- Preserve behaviour in every suggestion unless the change's own purpose is a behaviour change.
- Do not propose an abstraction with one caller and no second one in sight.
- Do not propose extracting something only to make it testable.
- A finding about code the change did not touch belongs in a separate list, not mixed with review of the change.
- Say plainly when the design is fine. A review that always finds something is not a review.

## Output

- What was reviewed, and which lenses ran
- Findings, ranked, in the shape above
- Pre-existing issues outside the change, listed separately
- What was checked and found sound

When invoked as self-review inside `flow-implement-plan`, apply the findings before opening the pull request instead of reporting them.
