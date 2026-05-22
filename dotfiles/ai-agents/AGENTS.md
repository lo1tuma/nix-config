## Communication

- No prose or AI-slop.
- Friendly.
- Very concise, but precise.

## Tooling

- Prefer `nix-shell`.
- Do not assume `homebrew` or machine-local tools.
- Tools like `gh`: invoke through `nix-shell`.

## Coding

### Naming

- Purpose over mechanics.
- No `helpers` or `utils`.
- No vague catch-all names.
- No abbreviations like `impl`.
- No implementation details in names.
- Prefer effect or domain meaning.
- Bad: `onClick = handleClick()`
- Better: `onClick = incrementCount()`

### Documentation

- If the project has a documentation concept: consider docs for every change or new feature.
- Prefer updating existing docs.
- New docs: only when needed.
- Keep docs concise.
- Document behavior, usage, decisions.
- Usually not implementation details.

### TypeScript

- Avoid optional properties.
- Avoid optional arguments.
- Pass values explicitly.

### Code Quality

- Default: no rule suppression or bypass.
- Scope: suppression comments, config changes, ignore lists.
- Examples: `eslint-disable`, `c8 ignore`, `cspell:disable`.
- No shortcut changes in files like `eslint.config.js` or `.prettierignore`.
- Exception: only with explicit user approval or explicit reporting afterward.
- Do not game the rules.
- Do not worsen code just to satisfy a rule.
- Optimize for rule intent: readability, maintainability, structure.
- Prefer proper refactors over superficial fixes.
- For limits like max-lines: consider abstractions or refactoring patterns, not only file splits.

## Pull Requests

### Conventions

- Read and understand repo contribution guidelines first.
- Follow repo guidelines strictly.
- If the repo forbids AI assistance: hard stop, inform the user.
- Otherwise infer conventions from the repo, git history, and PR history.
- Infer patterns like semantic commits when the convention is clear.

### Title

- Precise.
- Concise.
- Changelog-style.
- Not vague.
- Example: `Fix module A to prevent problem B`.

### Description

- Concise.
- Brief explanation only.
- Proper Markdown.
- No AI-slop.
- No filler like test plans or verification steps unless useful.

## Commits

### Subject

- Expressive.
- Precise.
- No low-value implementation detail already obvious from the diff.

### Body

- Consider by default.
- Omit only when the subject is fully exhaustive.
- Plain text, not Markdown.
- Prefer ASCII.
- ASCII art is acceptable when it clarifies a complicated change.

### Scope

- As small as possible.
- Atomic.
- Always leaves the repo working.
- Prefer baby-step commits.
