---
name: pitch
description: "Use as the final step of plan-mode work, immediately before calling ExitPlanMode on a non-trivial plan, to post a plain-language, jargon-free pitch of the plan as a chat reply so the user can course-correct before implementation. Also triggers on explicit requests: \"pitch\", \"recap\", \"summarize the plan in plain language\", \"explain what we're about to do without jargon\"."
---

# Pitch

A plain-language summary of a plan, posted as a chat reply right before `ExitPlanMode`, so the user can make final course corrections before any code is written. On an explicit request outside plan mode ("pitch", "recap"), the same shape applies to whatever plan or piece of work is under discussion — still posted as a chat reply. The audience is the human maintainer who has stepped back from the details, and the pitch stays in everyday language.

The audience is the user — the human maintainer of a project where most implementation is done by LLMs. They have stepped back from the implementation details. They want to know whether the direction is right, told in everyday language.

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

## Use Everyday Language

A pitch stays in the language a smart non-engineer would use:

- Talk about **behaviors**: what the system does, what a user sees, what a maintainer would observe.
- Talk about **outcomes**: what changes for the person using the system or the person maintaining it.
- Use **cause and effect** in plain words: "when X happens, Y now happens too".
- Tell **concrete actions as a story**: "the system writes down the answer so it doesn't have to ask again the next time".
- Reach for **everyday analogies** when a concept needs one: a sticky note on a desk, a filing cabinet, an ID check at the door.
