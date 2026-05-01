# Pitch Style Guide

## Audience
Brian, the human maintainer of a project where most implementation is done by LLMs. He has stepped back from the implementation details. He wants to know whether the direction is right, told in everyday language.

## Output Shape
Three sections, in this order, every time:

1. **Problem** — what's missing or needed, in user or behavior terms
2. **Fix** — what we're going to do about it, in plain language
3. **New behavior** — what the system does after the change that it doesn't do today

Length budget: each section ≤ 3 sentences. Total pitch ≤ ~120 words.

## Use Everyday Language
A pitch stays in the language a smart non-engineer would use:

- Talk about **behaviors**: what the system does, what a user sees, what a maintainer would observe.
- Talk about **outcomes**: what changes for the person using the system or the person maintaining it.
- Use **cause and effect** in plain words: "when X happens, Y now happens too".
- Tell **concrete actions as a story**: "the system writes down the answer so it doesn't have to ask again the next time".
- Reach for **everyday analogies** when a concept needs one: a sticky note on a desk, a filing cabinet, an ID check at the door.

## Quick self-check before posting

- Could a smart non-engineer read this and tell you what's changing?
- Are you describing behaviors and outcomes the reader would see?
- Is each piece of the system named by what it does, rather than what it's called in the code?
- Is the whole thing under ~120 words?
