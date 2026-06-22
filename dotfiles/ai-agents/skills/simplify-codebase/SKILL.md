---
name: simplify-codebase
description: Find and remove unnecessary hand-rolled code, shallow modules, narrow wrappers, and premature abstractions by reusing project code, platform features, runtime APIs, or focused libraries. Use when the user asks to simplify, defactor, deepen modules, replace custom implementations, or reduce codebase complexity without changing behavior.
metadata:
  short-description: Remove needless custom code
---

# Simplify Codebase

## Goal

Reduce code while preserving behavior.

Prefer, in order:

1. Delete code by reusing existing project code.
2. Make existing project code more generic when the shared concept is real.
3. Replace hand-rolled logic with standard library, runtime, framework, platform, or environment features.
4. Replace hand-rolled logic with an existing dependency already in the project.
5. Add a focused third-party library when it removes substantial custom code.
6. Keep hand-rolled code only when it is smaller, clearer, safer, or more domain-specific than the alternatives.

## Operating rules

- Preserve observable behavior unless the user explicitly approves a behavior change.
- Work in small, reviewable steps.
- Do not introduce a new dependency without user approval.
- Do not create a seam unless there are at least two real adapters or a concrete testing need.
- Delete speculative extension points, pass-through wrappers, and one-off indirection when they do not provide leverage.
- Before rejecting a platform, runtime, framework, or standard library feature as unavailable, inspect the project-pinned versions.
- Use newer built-in features when the project already targets versions that support them, even if they are not yet common in older codebases.
- Run the relevant tests or quality gate after each coherent refactor.

## Find candidates

Scan the requested area, or the current diff if no area is named.

Look for:

- hand-rolled parsing, validation, formatting, diffing, date handling, retry, caching, traversal, API-client or collection logic
- duplicate logic with small variations
- wrapper modules whose interface is almost as large as their implementation
- abstractions with only one caller or one adapter
- extracted functions that exist only for tests while the real behavior remains spread across callers
- configuration objects or option bags that expose implementation details
- call chains where understanding one concept requires bouncing through many tiny files
- custom code that mirrors standard library, runtime, framework, platform, or environment features
- custom code kept only because older platform or runtime versions lacked a feature the current project version now provides
- custom code that mirrors a dependency already present in `package.json`

Apply the deletion test:

- If deleting the module makes complexity vanish, it was shallow.
- If deleting the module spreads complexity across callers, it is probably earning its place.

## Choose the refactor

For each candidate, compare these options before editing:

- delete and inline
- replace with existing project code
- deepen one existing module so callers use a smaller interface
- replace with a standard library, runtime, framework, platform, or environment feature
- replace with an existing third-party dependency
- add a focused dependency
- keep the code and document why no simplification is justified

Prefer module deepening when the current code leaks details across callers. A good deepening move shrinks the interface and moves complexity into one implementation.

Prefer deletion when the abstraction only renames, forwards, adapts one thing to itself, or exists for hypothetical future variation.

Prefer platform or runtime features when the custom implementation solves a general problem the environment already owns.

Use project files to determine availability, such as package manifests, lockfiles, toolchain files, CI images, Dockerfiles, Nix files, version managers, compiler options, deployment targets, and framework configuration. If those disagree, use the strictest version that can run the code.

Prefer a library when the custom implementation is generic infrastructure, security-sensitive, standards-driven, or easy to get subtly wrong.

## Implement

Make a full plan but consider splitting the work into multiple PRs which only contain the smallest coherent change (stacked PRs are ok). Create the PRs automatically using the `gh` tool.

When replacing hand-rolled code:

- add characterization tests first if behavior is not already covered
- replace the custom path with the reused project code or library
- remove dead code, obsolete tests, and stale documentation
- keep call sites simple

When deepening a module:

- design the interface around what callers need, not around implementation steps
- hide ordering, validation, normalization, and branching inside the implementation
- test through the interface
- avoid exposing internal seams unless callers truly need them

When deleting an abstraction:

- inline only until the remaining code is clearer
- stop if duplication becomes meaningful
- keep names domain-specific

## Report

Keep the report concise:

- what was removed or replaced
- why the new shape has more leverage or locality
- behavior verification run
- any simplification candidate intentionally left alone
