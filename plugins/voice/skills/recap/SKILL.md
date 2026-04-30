---
name: recap
description: "Use as the final step of plan-mode work, immediately before calling ExitPlanMode on a non-trivial plan, to post a plain-language, jargon-free recap of the plan as a chat reply so the user can course-correct before implementation. Also triggers on explicit requests: \"recap\", \"summarize the plan in plain language\", \"explain what we're about to do without jargon\"."
---

# Recap

A plain-language summary of a plan, posted as a chat reply right before `ExitPlanMode`, so the user can make final course corrections before any code is written. The audience is the human maintainer who has stepped back from the details, and the recap stays in everyday language.

## When to Use
- Final step of the plan-mode workflow on a non-trivial plan, immediately before `ExitPlanMode`
- Explicit user requests: "recap", "summarize the plan in plain language", "explain what we're about to do without jargon"

## Output Shape

1. **Problem** — what's broken, missing, or needed, described in behavior or user terms
2. **Fix** — what we're going to do about it, in plain language
3. **New behavior** — what the system will do once this lands that it doesn't do today

## Hard Rules
- Output goes to chat as a reply.
- Use everyday language: behaviors, outcomes, what changes for a user or maintainer.
- Describe behavior and outcomes; let the plan file carry the mechanism.
- Each section ≤ 3 sentences. Total recap ≤ ~120 words.

See `references/style-guide.md` for the full language guide and worked examples.
