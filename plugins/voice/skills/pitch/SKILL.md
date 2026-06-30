---
name: pitch
description: "Use as the final step of plan-mode work, immediately before calling ExitPlanMode on a non-trivial plan, to post a plain-language, jargon-free pitch of the plan as a chat reply so the user can course-correct before implementation. Also triggers on explicit requests: \"pitch\", \"recap\", \"summarize the plan in plain language\", \"explain what we're about to do without jargon\"."
---

# Pitch

A plain-language summary of a plan, posted as a chat reply right before `ExitPlanMode`, so the user can make final course corrections before any code is written. The audience is the human maintainer who has stepped back from the details, and the pitch stays in everyday language.

## Output Shape

1. **Problem** — what's broken, missing, or needed, described in behavior or user terms
2. **Fix** — what we're going to do about it, in plain language
3. **New behavior** — what the system will do once this lands that it doesn't do today

## Hard Rules
- Output goes to chat as a reply.
- Use everyday language: behaviors, outcomes, what changes for a user or maintainer.
- Describe behavior and outcomes; let the plan file carry the mechanism.
- Each section ≤ 3 sentences. Total pitch ≤ ~120 words.

## Before Posting

The pitch is done only when all of these hold:
- A smart non-engineer could read it and tell you what's changing.
- It describes behaviors and outcomes the reader would see, not mechanism.
- Each piece of the system is named by what it does, not what it's called in the code.
- The whole thing is under ~120 words.

See `references/style-guide.md` for the full language guide and worked examples.
