---
name: commit
description: "Use when committing staged or working-tree changes to git."
argument-hint: "[focus topic]"
---

# Commit

`commit` turns a mixed diff into atomic commits — one concern each, every one named for the behavior it changes — where the default is a single commit under a summary message. Atomic is the leading word: a commit that `git bisect` can land on and `git revert` can undo without taking anything unrelated with it.

## Steps

1. **Pick the changes.** If something is staged, commit only what is staged; the caller chose it. If nothing is staged, take every working-tree change, including untracked files, but leave out anything that looks like a secret (`.env`, keys, credentials) or a build artifact, and name what you left out in the report. When a focus topic is given, commit only the changes that belong to it and leave the rest in the working tree.
2. **Read the whole diff** (`git diff --cached`, or `git diff` plus the untracked files), and group the changes by concern: one bug fix, one feature, one rename, one config change. Done when every hunk belongs to exactly one group.
3. **Split by staging.** For each group, stage its files, or its hunks with `git add -p`, and commit it before staging the next. When two groups cannot be separated by staging alone, bundle them (see "Bundling" below).
4. **Report.** List each commit's short hash and subject line, then anything left uncommitted and why.

The run is done when every change picked in step 1 is in exactly one commit. Keep going without asking: grouping, splitting, bundling, and messages are your call. Push, amend, or rewrite existing commits only when the caller asks, because those change history other people may already have.

Commit hooks run. When a hook fails, fix what it reports and create the commit again. In the `interface` repository or any of its worktrees, commit with `-n` to skip the hooks.

## Message

```
{emoji} {type}(scope): {description}
```

Type is one of `feat|fix|docs|style|refactor|perf|test|chore|ci|wip`, and the emoji is the gitmoji that fits the change most closely, since a reader scanning `git log` takes in the emoji before the words. Write the description in the imperative present tense ("prevent", not "prevented") and keep the whole line under 72 characters, because longer subjects wrap or get cut in `git log --oneline` and in PR views.

A message describes one atomic change. Check it against the diff before committing:

- It names the specific behavior that changed: you can complete "this commit makes ___ work when ___" in concrete terms. If you cannot, the commit holds more than one concern; split it.
- It carries no count ("5 bugs", "multiple issues"). A count means several concerns; split them.
- It describes the change, not the session that produced it ("from review", "from the audit"), because a later reader of `git log` never saw that session.
- It mentions tests only when the commit changes nothing but tests.

Illustrative:

<bad_example>
fix(pipeline): 5 critical bugs from 2026-03-30 morning brief review
<reasoning>A count and a session reference, and nothing about what changed — it cannot be bisected or reverted one bug at a time.</reasoning>
</bad_example>

<good_example>
fix(pipeline): prevent null pointer when stage has no artifacts
<reasoning>Names the behavior and the condition; bisectable and safe to revert on its own.</reasoning>
</good_example>

## Grouping

Separate concerns and separate types go in separate commits, and so does a diff too large to review in one sitting. Tests go in the same commit as the feature or fix they cover, so that every commit passes its own tests; a test-only commit holds only test changes.

## Bundling

When separating two concerns would mean editing file content — so that each commit stands on its own — bundle them into one commit instead. Two common cases:

- Two iterations in the same session rewrote the same lines. Only the final text exists.
- A piece of logic moved between subsystems mid-session. Neither the old home nor the new home holds a complete version.

Leave the working tree as it is. An intermediate state rebuilt by hand never compiled and never ran, so it is worse for `git bisect` than the bundle. Bundle without asking the caller.

The bundled message names the design decision that ties the changes together, not the steps and not the fact that you bundled. Every check under "Message" still applies.
