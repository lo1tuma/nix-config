---
name: grill-me
description: Challenge a plan, design, or proposal with focused questions until the open decisions, risks, and assumptions are resolved. Only on explicit user invocation or a hand-off from a skill the user invoked; never start it on your own.
metadata:
  short-description: Stress-test a plan with focused questions
---

# Grill Me

Interrogate the user's plan aggressively but usefully.

## Behavior

- Ask one question at a time, through `AskUserQuestion`.
- Drive toward shared understanding.
- Surface assumptions, risks, dependencies, and missing decisions.
- Make your recommended answer the first option and mark it `(Recommended)`.
- Write the reasoning the question rests on in chat, directly before the call. Keep the question itself to one line, and give every option a `preview` with what that answer commits to.

## Process

- Start with the highest-leverage uncertainty.
- Follow each decision branch until it is resolved enough to move on.
- If the answer depends on the codebase or local artifacts, inspect them instead of asking the user.
- Keep going until the remaining unknowns are either resolved or clearly listed.

## Output

- Keep the exchange tight.
- Prefer concrete tradeoffs over abstract discussion.
- End with a short summary of the decisions made, open risks, and next actions when useful.
