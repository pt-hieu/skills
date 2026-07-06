---
name: kickoff
description: "Use when /kickoff is invoked or a new requirement, ticket, or task description is handed off for planning."
---

# Kickoff

Source of truth for Brian's task-intake workflow. Walks a fresh requirement through gated steps so no critical phase (skill scan, challenge, pitch) is skipped.

## When to Use
- The user invokes `/kickoff` on a new requirement, ticket, or task description.

## Instructions
See `instructions.md` for the full pipeline, gates, and effort matrix.

## It's working if
- `TaskList` shows the full pipeline registered and wired before any exploration starts, each task description pointing back to its section in `instructions.md`.
- The plan file exists on disk before Challenge runs — Challenge revises that file, not chat.
- Interrogate questions read in plain English, each with a `(Recommended)` option, and none could have been answered by reading the code.
- The plan file's final section is `## Post-implementation protocol`, injected by plan-verifier — not hand-written.
