# Commit Message Instructions

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
