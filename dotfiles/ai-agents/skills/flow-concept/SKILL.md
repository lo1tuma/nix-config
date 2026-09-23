---
name: flow-concept
description: Work out the concept for something large before any plan exists. Proposes two competing concepts, attacks them with independent reviewers, and writes the surviving one to a markdown document. Use when a feature or change is big enough that the shape of the whole thing is the open question.
metadata:
  short-description: Draft and stress-test a large concept
---

# Concept

Decide what to build, and why that shape, before anything is planned or written.

Use this when the task is too large to plan directly. The output is a document that later becomes milestones.

## Destination

Ask once where the document belongs when it is not obvious, and offer the default.

- The repository's documentation folder when the project has one and the concept is part of the product. It gets committed.
- Otherwise an untracked markdown file in the repository, which stays untracked and uncommitted.

Write to that file as you go rather than at the end. The document is the working surface, not a summary of one.

## Process

### 1. Frame

State the problem, who has it, and what the concept must be true for. Name what is explicitly out of scope.

List what is already decided and what is still open. Inspect the codebase for anything you can answer yourself instead of asking.

### 2. Propose two

Produce two concepts that differ structurally, not cosmetically. For each: how it works, the shape of its parts, what it makes easy, what it makes hard, and what it forecloses.

Read `design-it-twice` from `~/.agent-skill-library/` for the discipline, and `design-deep-modules` and `module-boundaries` when the concept is about how the parts divide.

A second option that exists to lose is not a second option. If you cannot make the case for both, say so and produce a real alternative.

### 3. Attack

Dispatch independent reviewers with fresh context, each given the two concepts and a different angle. Use different models where available, since agreement between identical reviewers proves nothing.

Angles worth assigning: does it actually solve the stated problem, what happens at ten times the scale, what does it cost to operate and change, what breaks at its boundaries with the existing system, and what does it make impossible later.

Synthesise into act on, consider, noted, and dismissed, with a note where reviewers disagreed. Disagreement is the interesting part, not a problem to resolve away.

### 4. Choose and record

Pick one. Record why, and why the other lost. Write the open questions that remain as open questions, not as settled defaults.

### 5. Grill

Hand the surviving concept to `grill-me` and keep going until the open decisions are resolved or explicitly deferred with a reason.

## Document shape

Problem and constraints, out of scope, the chosen concept, the rejected alternative with its reason, the reviewer findings that changed it, open questions, and what would invalidate the whole thing.

Keep it concise. Facts and decisions, no padding, no restating the diff of your thinking.

Next: `flow-deep-dive` for any topic still too open, then `flow-delivery-plan`.
