---
name: prompting
description: "Use when writing, revising, or diagnosing prose an LLM reads, or removing prompting written for legacy models."
---

# Prompting

Write prose for an LLM the way you would brief a capable colleague who has none of your context: in sentences, with reasons, and addressed to a reader. Do not write a form to fill in or a list of orders.

The reader is Opus 5.5. It thinks before every reply and keeps going on long, multi-part work, so the prose's job is to hand over the whole task, say what done looks like and when to stop, and supply the context and reasons it cannot infer.

The rules below apply to every piece of prose an LLM reads. Then read the reference for what you are writing, in full, before drafting:

- **A skill or a subagent instruction file**, or one that misbehaves through sprawl, repetition, stale layers, or stopping short: read [`references/skills.md`](references/skills.md).
- **An agent prompt that reasons over data and reports back**, or one whose output is vague, overconfident, or invented: read [`references/prompts.md`](references/prompts.md).

- **Removing outdated instructions from an existing prompt surface** — dated pressure language, thinking and prefill scaffolds, version workarounds, over-scripted steps: read [`references/decruft.md`](references/decruft.md) and follow its steps. It edits files in place and never commits.

A subagent that analyses data is both of the first two; read both.

## Rules for any prose an LLM reads

- **Prose, not contracts.** Write instructions as sentences and ask for output as sentences. A field list, a mandatory literal token, or a required closing line binds two LLMs to a contract that neither of them parses, and it drifts silently when one side stops emitting it. Use a literal token or a schema only when something branches on the exact value: non-LLM code that parses it, or a receiver told to dedupe, merge, or discard by that value. Keep a list of every emitter and consumer of such a value, and change them in the same commit.
- **Name the finish line.** Hand over the whole task at once and say what done looks like in terms the model can check: "the tests pass", "every endpoint is migrated". With a clear finish line it knows when it is done; without one it stops at a plausible point or keeps polishing.
- **Say when to stop.** Tell it to keep going when a step does not need input, and name the few cases where it stops and asks: it cannot continue without the user, or the next action is destructive (deleting data, force-pushing, changing anything outside the repository). A run that stops for confirmation it did not need costs a restart.
- **Give the reason.** A rule stated with its reason extends to cases the rule does not name. A bare rule is either followed too literally or ignored. "Cite the field each number came from, because the reader checks figures against the source" works better than "ALWAYS CITE SOURCES".
- **Name the reader.** Say who reads the output and what they do with it. That sets length and shape better than a word cap, which cuts short the hard cases. Ask for what the reader must act on to come first ("start with what is blocked on me"), because that is what they read first.
- **Write what is.** State each rule as if no other version had ever existed. "No longer", "instead of X", and "don't propose" describe a version the reader never saw, and they put the rejected option in front of it. This also applies when adapting text from elsewhere.
- **Be specific.** Describe the behaviour you want. To steer away from a default, list the exact patterns to leave out: "avoid a generic look" swaps one default for another, while "no cream background, no numbered 01 / 02 / 03 section labels, no pill-shaped buttons" removes them.
- **Plain register.** Write in normal case. Skip pressure words (CRITICAL, MUST, NEVER in capitals), threats, and pleading: current models over-apply emphasised rules. Say things literally, because a metaphor brings in connotations you did not choose.
- **Cut no-ops.** For each sentence, ask whether it changes the model's behaviour compared with what it would do anyway. If not, delete the whole sentence. "Be helpful" and "you are a helpful assistant" are no-ops.
- **Leave thinking to the model.** Opus 5.5 thinks before every reply, so "think carefully", "think step by step", and "think hard" only delay the reply. Do not ask it to reproduce its reasoning in the output either; ask for the explanation the reader needs ("explain why you chose this approach in three sentences"). For a simple question, "answer directly" is enough.
- **Use leading words.** A compact word the model already knows (_relentless_, _tracer bullet_, _bedrock_), repeated where it applies, holds a behaviour in place with few tokens. Reuse the word rather than re-describing the behaviour, and prefer an existing word to a coined one, which the model has no associations for.
- **One source of truth.** State each meaning in exactly one place and point to it from everywhere else. A repeated rule reads as more important than it is, and a change to it needs edits in several places.
- **Examples sparingly.** The model copies an example's length, structure, and topic. Use a few varied examples, marked as illustrative, and only where the shape of the output matters. Do not use them to demonstrate judgment the model already has.

## Finish

Reread the draft as its reader: a model with no context beyond this text. Stop when every sentence either tells it something it needs in order to act or changes what it would do by default, and every rule it must follow carries its reason.
