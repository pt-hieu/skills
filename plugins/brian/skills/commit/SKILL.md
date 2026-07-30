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

## 🔴 CRITICAL: No Batch/Summary Commits

**Anti-pattern name: "Changelog Commit"** — aggregating multiple changes into one vague message. This destroys git bisect usefulness, makes reverts dangerous, and hides what actually changed.

**VERIFICATION (mandatory before writing message):**
1. Re-read the diff. Can you name the *specific behavior* that changed?
2. If the message contains a **count** ("5 bugs", "3 fixes", "multiple issues") → STOP. Split into separate commits.
3. If the message references a **session** ("from review", "from morning brief", "from audit") → STOP. Describe the change, not how you found it.
4. If you cannot complete: "This commit makes ___ work when ___" in concrete terms → the scope is too broad. Split further.

<bad_example>
fix(pipeline): 5 critical bugs from 2026-03-30 morning brief review
<reasoning>Contains a count (5), references a session (morning brief). Tells you nothing about what changed. Cannot git bisect. Cannot safely revert one bug without reverting all 5.</reasoning>
</bad_example>

<bad_example>
fix: resolve multiple issues found during code audit
<reasoning>"Multiple issues" is a count. "Code audit" is a session. Zero information about what behavior changed.</reasoning>
</bad_example>

<bad_example>
chore: address review feedback
<reasoning>References a session (review). Could mean anything. Completely opaque to future readers.</reasoning>
</bad_example>

<good_example>
fix(pipeline): prevent null pointer when stage has no artifacts
<reasoning>Names the specific behavior (null pointer) and the condition (no artifacts). Can verify with git bisect. Safe to revert independently.</reasoning>
</good_example>

<good_example>
fix(auth): refresh token before expiry instead of after
<reasoning>Names what changed (refresh timing) and the before/after behavior. Actionable for reviewers.</reasoning>
</good_example>

**If changes span multiple concerns → split into separate commits, one per logical change. Never lump unrelated fixes into one commit.**

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
