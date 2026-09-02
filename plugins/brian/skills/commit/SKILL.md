---
name: commit
description: "Use when committing staged or working-tree changes to git."
disable-model-invocation: false
argument-hint: "[JIRA-TICKET] [focus topic]"
---

# Commit Skill

Commits with a strict `{JIRA} {emoji} {type}(scope): {description}` format and one concern per commit — splitting mixed diffs instead of batching them under a summary message.

## Behavior

1. Auto-stage if nothing staged (`git add`)
2. Analyze `git diff` for changes
3. Detect split opportunities (different concerns/types)
4. Create commit(s): `{JIRA} {emoji} {type}(scope): {description}`

Default: If you're in `interface` repository or its worktree, always skip the commit hooks by using `-n` when committing

## Format

```
{JIRA-TICKET} {emoji} {type}(scope): {description}
```

Types: `feat|fix|docs|style|refactor|perf|test|chore|ci|wip`

Rules:
- Present tense, imperative, <72 chars, omit test mentions unless test-only.

## No batch or summary commits

A "changelog commit" aggregates several changes under one vague message. It defeats `git bisect`, makes a revert take unrelated changes with it, and hides what changed. Before writing a message, check three things against the diff:

- The message names the specific behavior that changed — you can complete "this commit makes ___ work when ___" in concrete terms. If you cannot, the scope is too broad; split further.
- The message carries no count ("5 bugs", "multiple issues"). A count means several concerns; split them.
- The message describes the change, not the session that produced it ("from review", "from the audit").

Illustrative:

<bad_example>
fix(pipeline): 5 critical bugs from 2026-03-30 morning brief review
<reasoning>A count and a session reference, and nothing about what changed — it cannot be bisected or reverted one bug at a time.</reasoning>
</bad_example>

<good_example>
fix(pipeline): prevent null pointer when stage has no artifacts
<reasoning>Names the behavior and the condition; bisectable and safe to revert on its own.</reasoning>
</good_example>

Changes that span several concerns become several commits, one per logical change.

## Emoji Map

| Emoji | Type | When |
|-------|------|------|
| ✨ | feat | New feature |
| 🏷️ | feat | Types |
| 👔 | feat | Business logic |
| 🚸 | feat | UX improvement |
| 🐛 | fix | Bug fix |
| 🩹 | fix | Simple fix |
| 🚑️ | fix | Critical hotfix |
| 🚨 | fix | Linter warnings |
| ✏️ | fix | Typos |
| ♻️ | refactor | Refactoring |
| 🎨 | style | Structure/format |
| 🚚 | refactor | Move/rename |
| ⚰️ | refactor | Dead code |
| 📝 | docs | Documentation |
| ✅ | test | Tests |
| 🔧 | chore | Config |
| ➕ | chore | Add dep |
| ➖ | chore | Remove dep |
| 👷 | ci | CI/CD |
| ⚡️ | perf | Performance |

## Split Rules

Split when: different concerns, different types, different file patterns, too large for single review.

Keep tests with their feature/fix commit. Test-only commits only for test-only changes.

## Bundle Escape Hatch

Split with git alone. Stage whole files, or stage single hunks with `git add -p`. That covers most mixed diffs.

**Bundle when a split needs a file edit.** If you cannot separate the concerns by staging — you would have to change file content to make each commit stand on its own — bundle them into one commit instead. Two cases you will hit often:

- Two iterations of the same session overwrote the same lines. Only the final text exists.
- A piece of logic moved between subsystems mid-session. Neither the old home nor the new home holds a complete version.

Leave the working tree as it is. Do not edit files back into a hypothetical mid-state to satisfy the split rule — that state never compiled and never ran, so it is worse for `git bisect` than the bundle.

You decide this yourself. Do not ask the caller for permission to bundle.

In the bundled message, name the *coherent design decision*, not the steps and not the fact that you bundled. The Changelog-Commit rules above still apply: no counts, no session references, name the specific behavior that changed.
