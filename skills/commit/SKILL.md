---
name: commit
description: "[User-level skill] Use when committing."
disable-model-invocation: false
argument-hint: "[JIRA-TICKET] [focus topic]"
allowed-tools: Bash(git *)
---

# Commit Skill

## Behavior

1. Auto-stage if nothing staged (`git add`)
2. Analyze `git diff` for changes
3. Detect split opportunities (different concerns/types)
4. Create commit(s): `{JIRA} {emoji} {type}(scope): {description}`

Default: If you're in `interface` repository or its worktree, always skip the commit hooks by using `-n` when committing

## Instructions

See `instructions.md` for format, emoji map, split rules, and the **critical no-batch-commit verification chain**.
