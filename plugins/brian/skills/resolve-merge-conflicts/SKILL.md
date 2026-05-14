---
name: resolve-merge-conflicts
description: "Use when resolving Git merge conflicts"
---

# Merge Conflict

## Behavior

1. **Discover** — list unmerged paths and read both sides' commit messages so the resolution is anchored in intent, not just diff text.
2. **Classify** each conflict as content / structural / dependency / semantic.
3. **Resolve** in preference order: auto-merge → combine → synthesize → context-priority → escalate via `AskUserQuestion`.
4. **Verify per type** — markers absent (content), `git ls-files -u` empty (structural), frozen-install passes (dependency), typecheck + targeted tests pass (semantic).
5. **Stop** after resolving and verifying. Hand the staged tree back to the user; the user owns the commit and the push.

## Instructions

See `instructions.md` for the full reference: input/output contract, discovery commands, per-type playbooks, regeneration matrix, verification table, rollback commands, output format, and worked examples.
