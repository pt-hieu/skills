---
name: assess-code-review
description: "Use when working a Bitbucket PR's open review comments to closure — assess each unresolved comment, propose fixes for the ones you agree with and concise push-backs for the ones you don't, then apply and resolve on approval."
argument-hint: "[PR-ID]"
---

# Assess Code Review

## When to Use
- Brian has a Bitbucket PR with reviewer comments and wants them triaged and actioned.
- Invoked as `/assess-code-review [PR-ID]`, or hands off "deal with the review comments on my PR".

## When NOT to Use
- Authoring or describing a PR (that is not this skill).
- Committing or pushing — run `brian:commit` separately afterward.

## Instructions
See `instructions.md` for the full execution guide: PR resolution, unresolved-comment filtering, the classification methodology, the batched-approval format, the on-approval apply/resolve/reply sequence, the `voice:voice` chaining, and the edge-case handling.
