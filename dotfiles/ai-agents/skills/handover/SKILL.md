---
name: handover
description: Turn the current session into a compact handover note for a fresh agent. Use when the user wants a continuation brief, restart context, or a document for the next session.
metadata:
  short-description: Create a compact continuation note
---

# Handover

Create a continuation note for another agent to pick up the work.

## Destination

- Save the note in the operating system temporary directory, not in the current workspace.

## Content

- Summarize the current state, active goal, key decisions, pending work, and important context.
- Add a `Suggested skills` section when relevant.
- If the user gives a focus for the next session, tailor the note to that focus.

## Constraints

- Do not restate information already preserved well in other artifacts such as plans, issues, decision-records, commits, or diffs.
- Reference existing artifacts by path or URL instead.
- Redact secrets, credentials, and personal data.
- Keep it compact and practical.
