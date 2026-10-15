---
name: commit
description: "Use when committing staged or working-tree changes to git."
argument-hint: "[focus topic]"
---

# Commit

`commit` commits the working tree as it is, in one commit per concern where staging can separate the concerns and in a bundle where it cannot.

## Done

The run is done when every change in scope is in exactly one commit and the caller has the report.

- **Scope.** When something is staged, the scope is what is staged, because the caller chose it. When nothing is staged, the scope is every working-tree change, including untracked files, minus anything that looks like a secret (`.env`, keys, credentials) or a build artifact. A focus topic narrows the scope to the changes that belong to it, and the rest stays in the working tree.
- **Report.** Each commit's short hash and subject line, then anything left uncommitted and why.

Keep going without asking: grouping, bundling, and messages are your call. Push, amend, or rewrite existing commits only when the caller asks, because those change history other people may already have.

Every commit passes its hooks. In the `interface` repository or any of its worktrees, commit with `-n` to skip the hooks.

## Splitting and bundling

Separate concerns and separate types go in separate commits when staging whole files or hunks can pull them apart, and so does a diff too large to review in one sitting. Tests go in the commit with the feature or fix they cover, so that every commit passes its own tests.

When separating concerns would mean editing file content, bundle them into one commit. An intermediate state rebuilt by hand never compiled or ran, so the bundle is the better commit. Two common cases:

- Two iterations in the same session rewrote the same lines, so the final text is all that exists.
- A piece of logic moved between subsystems mid-session, so neither the old home nor the new home holds a complete version.

A bundle's message names the design decision that ties its changes together, not the steps and not the fact that you bundled.

## Message

```
{emoji} {type}(scope): {description}
```

Type is one of `feat|fix|docs|style|refactor|perf|test|chore|ci|wip`, and the emoji is the gitmoji that fits the change most closely, since a reader scanning `git log` takes in the emoji before the words. Write the description in the imperative present tense ("prevent", not "prevented") and keep the whole line under 72 characters, because longer subjects wrap or get cut in `git log --oneline` and in PR views.

Check each message against its diff:

- It names the specific behavior that changed: you can complete "this commit makes ___ work when ___" in concrete terms. If you cannot, the commit holds more than one concern; split it or bundle it as "Splitting and bundling" describes.
- It has no count ("5 bugs", "multiple issues"); a count lists the concerns and leaves the change unnamed.
- It describes the change, not the session that produced it ("from review", "from the audit"), because a later reader of `git log` never saw that session.
- It names the code change and leaves the tests that cover it unmentioned, unless the commit is all tests.

Illustrative:

<bad_example>
fix(pipeline): 5 critical bugs from 2026-03-30 morning brief review
<reasoning>A count and a session reference, and nothing about what changed.</reasoning>
</bad_example>

<good_example>
fix(pipeline): prevent null pointer when stage has no artifacts
<reasoning>Names the behavior and the condition.</reasoning>
</good_example>
