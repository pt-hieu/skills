---
name: assess-code-review
description: "Use when working a Bitbucket PR's open review comments to closure — assess each unresolved comment, propose fixes for the ones you agree with and concise push-backs for the ones you don't, then apply and resolve on approval."
argument-hint: "[PR-ID]"
---

# Assess Code Review

Pulls the open review comments on a Bitbucket PR and drives them to closure. For each unresolved comment it forms a disposition — AGREE (propose a concrete fix), DISAGREE (draft a concise, fair push-back), or AMBIGUOUS (surface to Brian) — presents ONE batched assessment, and waits for a single approval. On approval it applies the agreed fixes and silently resolves those threads, and posts the push-back replies on the disagreed threads (leaving them unresolved). It stops at working-tree edits — no commit, no push.

## When to Use
- Brian has a Bitbucket PR with reviewer comments and wants them triaged and actioned.
- Invoked as `/assess-code-review [PR-ID]`, or hands off "deal with the review comments on my PR".

## When NOT to Use
- Authoring or describing a PR (that is not this skill).
- Committing or pushing — run `brian:commit` separately afterward.

## Behavior
1. Resolve the target PR: use the `[PR-ID]` argument if given; otherwise auto-detect the open PR whose source branch is the current git branch.
2. Fetch the PR and its comments; consider ONLY unresolved/open comments (skip resolved threads).
3. Classify each open comment: AGREE → concrete fix (file + change), DO NOT edit yet; DISAGREE → concise push-back reply with reasoning; AMBIGUOUS → surface to Brian.
4. Present ONE batched assessment — a per-comment table (comment → disposition → proposed fix / draft reply) — and WAIT for a single approval. Brian may adjust specific rows before approving.
5. On approval: apply each agreed fix to the working tree then resolve that comment silently (no reply); post each push-back reply via `add_comment` (parentId = the comment) and leave those threads unresolved.

## Args
- `[PR-ID]` — optional Bitbucket PR id. If omitted, auto-detect the PR for the current branch.

## Boundaries
- Stops at working-tree edits — never commits, never pushes.
- Never replies on agreed threads; never resolves disagreed threads.
- Push-back replies are drafted through `voice:voice` and authored as Claude Code on behalf of Brian Pham.

## Instructions
See `instructions.md` for the full execution guide: PR resolution, unresolved-comment filtering, the classification methodology, the batched-approval format, the on-approval apply/resolve/reply sequence, the `voice:voice` chaining, and the edge-case handling.
