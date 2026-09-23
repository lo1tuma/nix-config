---
name: flow-delivery-plan
description: Turn an agreed concept into ordered milestones, each sized for one plan, grill and implement cycle. Use once a concept document is settled and the work needs to be sequenced into deliverable pieces.
metadata:
  short-description: Turn a concept into ordered milestones
---

# Delivery Plan

Cut a settled concept into milestones that can be built one at a time.

## Before cutting

Read the concept document. Do not plan around open questions: if something material is still open, name it and send it to `flow-deep-dive` first.

## Sizing

A milestone is one plan, one grilling, one implementation, one pull request or a short series. If it needs more, it is two milestones.

Every milestone must leave the system working and be worth having on its own. A milestone that only makes sense once a later one lands is not a milestone, it is half of one.

Prefer a thin path through the whole concept over a complete layer of it. A vertical slice proves the concept; a finished layer proves nothing until the layer above exists.

## Ordering

1. What the rest depends on goes first, including anything that would be expensive to change later.
2. The riskiest assumption goes early, while changing course is still cheap.
3. Independent milestones are marked as such.
4. Anything that can be deferred without blocking the rest goes last, and may never be needed.

## Per milestone

Record the outcome in one sentence, which part of the concept it delivers, what must exist before it starts, what it unblocks, how you will know it works, and the parts of the concept it deliberately leaves out.

Point each milestone back at the section of the concept document it comes from, so the reasoning stays reachable without copying it.

## Output

Write the delivery plan next to the concept document, following the same committed or untracked decision that document made.

State the sequence, the milestones with their dependencies, what is deferred, and what would cause the plan to be recut.

Then work milestones one at a time: `/plan` for the milestone, `flow-code-design`, `grill-me`, `flow-implement-plan`. Revisit this plan when a milestone teaches you something that changes the order.
