---
name: flow-deep-dive
description: Take one open topic of an existing concept and resolve it in a dedicated session, then fold the answer back into the concept document. Use when a concept is agreed in outline but one area needs to be worked out properly before it can be planned.
metadata:
  short-description: Deep-dive one open topic of a concept
---

# Deep Dive

Resolve one topic properly. Everything else in the concept stays untouched.

## Start

Read the concept document first. Name the single topic being resolved and the question that closes it. If the topic turns out to be several questions, say so and pick one, because a deep dive that covers three things resolves none.

State what the rest of the concept assumes about this topic. Those assumptions are the constraints, and breaking one means the concept changes, not just this section.

## Work

Go deep rather than broad. Read the actual code, run things, and check how the project already solves adjacent problems before proposing anything new.

Select lenses from `~/.agent-skill-library/CATALOG.md` for what the topic is about. Data shape and types, module boundaries, error semantics, patterns, and security all have lenses. Read the ones that apply.

Where the topic has competing answers, lay them out with their trade-offs and pick one. Where it depends on something unknown, say what would settle it and what you assume meanwhile.

Attack the answer before accepting it. Dispatch a reviewer with fresh context to argue the other side, and use `grill-me` on what survives.

## Fold back

Append the resolution to the concept document in place, under its own heading. Update anything elsewhere in the document that the answer contradicts, and say what you changed.

Record: the question, the answer, the alternatives and why they lost, the assumptions it rests on, and what would invalidate it.

If the answer breaks one of the concept's assumptions, stop and say so rather than quietly adjusting the concept around it.
