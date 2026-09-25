---
name: flow-code-design
description: Decide the shape of a change before implementing it. Produces two candidate designs, then the chosen types, signatures, module boundaries and error semantics. Use after a plan exists and before implementation, or whenever a change creates or reshapes an interface, a type, or a module boundary.
metadata:
  short-description: Design types and boundaries before coding
---

# Code Design

Decide the shape before writing the code. The output is types, signatures and boundaries, not prose about them.

Run this between planning and grilling. A plan whose design decisions are explicit gets grilled on real trade-offs instead of on gaps.

## Scope

Work from the plan file when one exists, otherwise from the described change. Name the one behaviour the change must deliver before designing anything.

Design only what the change needs. A boundary nobody crosses yet is not a boundary.

## Lenses

Read `~/.agent-skill-library/CATALOG.md`, then read the lenses this change actually touches. Ignore the rest.

| Question | Lens |
|---|---|
| Is there a better shape than the first one? | `design-it-twice` |
| Can the types make the bad states impossible? | `principle-type-system-discipline` |
| Is the domain in a structure or scattered across conditionals? | `principle-model-the-domain` |
| Is this interface at the right level of generality? | `somewhat-general-purpose-interface`, `general-vs-special` |
| Should the module absorb this decision or export it? | `pull-complexity-downward` |
| Can this error stop existing? | `define-errors-out-of-existence` |
| Is this boundary worth having at all? | `design-deep-modules` |
| Does a pattern fit, and is it justified? | `gof-patterns`, then `design-patterns` as the gate |
| Class or function for that pattern? | `implementation-functional-patterns`, then `implementation-design-patterns` |
| Should this be shared or duplicated? | `duplication-vs-abstraction` |

## Process

1. **Sketch the call site first.** Write how a caller uses the thing before writing the thing. If the call site is awkward, the design is wrong and nothing downstream fixes it.
2. **Produce two designs, not one.** They must differ structurally, not in naming. State what each makes easy and what each makes hard. If the second one is a straw man, you have one design and a decoration.
3. **Put the choice to the user.** Ask through `AskUserQuestion`, with a `preview` on each design so they sit side by side and can be annotated. Lead with your recommendation and say what each one costs. The rejected design and its reason go in the output, which is what stops the same debate reappearing in review.
4. **Write the chosen shape as code.** Types, signatures, discriminated unions, error type, module boundaries and their direction. Bodies stay unimplemented.
5. **Check the shape against the lenses you selected.** Each one either passes or changes the design. A lens that fires and gets ignored is noted with the reason.

## Rules

- Prefer the existing shape. Reuse a type, a module or a dependency the project already has before inventing one, and check the project's pinned versions before deciding a built-in is unavailable.
- If the types need a cast, an `any`, or an always-set optional to compile, the shape is wrong. Change the shape rather than the annotation.
- Stop strengthening a type once nothing would otherwise fail at runtime.
- Do not create a seam without two real implementations or a concrete testing need.
- A design that needs a comment to explain when a field combination is valid is too loose. Split it.

## Output

Write the result into the plan's design section when a plan file exists, otherwise return it directly.

- The behaviour being delivered
- The two designs, and why the chosen one won
- The chosen types and signatures
- Module boundaries and dependency direction
- Error semantics: what is defined out of existence, what a caller must handle
- Open questions for grilling

Hand over to `grill-me` next. If grilling changes the shape materially, run this again once.
