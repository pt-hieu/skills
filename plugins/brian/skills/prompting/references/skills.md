# Skills and subagent instructions

A skill exists to make an agent take the same process every run. It does not need to produce the same output, but it should follow the same steps and stop at the same gates. That predictability is the test for every choice below. The rules in `SKILL.md` still apply; this file adds what is specific to skills and subagent instruction files.

## Invocation and description

A skill is invoked in one of two ways, and each has a cost.

- **Model-invoked**: leave out `disable-model-invocation` and write the description as triggers ("Use when…"). The agent, or another skill, can then reach it without help. The cost is context: the description is loaded into every session.
- **User-invoked**: set `disable-model-invocation: true` and write the description as a one-line summary for a person. It costs no context, but the person has to remember that the skill exists. When there are too many user-invoked skills to remember, add a router skill that names them and says when to use each.

A description does two things: it says what the skill is, and it lists the situations that should trigger it. Put the skill's leading word early. Give each situation one trigger, because synonyms for the same situation are repetition. Leave out anything the body already says.

## Information hierarchy

Place each piece of content according to how soon the agent needs it, and push it as far down as it will go:

1. **Steps** come first. End each step on a completion criterion that the agent can check, and make it exhaustive where that matters ("every caller updated", not "update callers"). A vague criterion invites stopping early; a demanding one makes the agent dig further within the step.
2. **Reference in `SKILL.md`**: material the agent consults on demand during every run.
3. **Reference files**: material only some runs need, loaded when a pointer in `SKILL.md` sends the agent there.

A skill that runs long keeps its task list in a file ("keep a checklist in `TASKS.md`; tick each item when it is done and add anything new you find"). Long runs get their context summarised, and a list held only in the conversation is lost with it.

Inline what every run needs and move to a reference file what only some runs reach. Whether the agent follows a pointer depends on its wording: state the condition for opening the file ("when the test fails, read `references/…`"), not "see also". Keep a concept's rules and caveats under one heading instead of scattering them.

## Splitting

Each split has a cost, so split only when the cut pays for it:

- **By trigger**: split off a model-invoked skill when a distinct leading word should trigger it, or when another skill needs to reach it.
- **By unit of work**: when a step covers many independent units (every service in an audit, every module in a migration), dispatch one subagent per unit so each works with a clean context.
- **By sequence**: split a run of steps when seeing the later steps tempts the agent to rush the current one. Hiding them only works across a real context boundary, meaning a hand-off to the user or a subagent dispatch. An inline skill call hides nothing.

## Handoffs

When a skill dispatches a subagent, the sender says what the receiver needs in order to act, including its finish line, and the receiver reads the reply for meaning. The dispatching agent checks the evidence behind a subagent's report before accepting it; a confident summary is not evidence. Both sides are prose, following the "Prose, not contracts" rule in `SKILL.md`. When a receiver really must key off a value, structure and prose can sit in one exchange: key the merge on the fields that must match exactly, and let the receiver read the rest for meaning.

Write each obligation on the side that owns it. When only the actor can tell whether it complied, say so plainly. An obligation that only the actor can check, dressed as an external check, teaches the agent that something downstream is watching when nothing is.

## Shape of a skill

- **Opening sentence**: start the body with one plain sentence saying what the skill does differently from the model's default ("`diagnose` keeps digging past the first plausible cause"). Write it as prose, without a label.
- **One leading word**: give the skill one dominant leading word and name it before shipping. If you cannot name it, the skill has no central idea yet.
- **Refusal at the step**: when a skill exists to prevent one particular rush, put a short refusal at the exact step where the agent is tempted, tied to the leading word ("no red test, no Phase 2"). Placed in a reference file, it is read after the temptation has passed.
- **It's working if**: where the skill has clear signs that it ran, list a few observable ones: the leading word recurring in the agent's reasoning, a file written to disk, a gate the agent refused to cross.

## Size

Every line in `SKILL.md` is read on every run, and every reference file costs a hop. A `SKILL.md` past about 150 lines is a sign to move the parts that only some runs need into references. A reference file under about 20 lines is not worth its hop, so inline it.

## Diagnosing a misbehaving skill

- **Stops to ask when it could continue**: the skill does not say when to keep going. State the stop conditions (see "Say when to stop" in `SKILL.md`).
- **Stops early**: first make the step's completion criterion checkable. Only if it cannot be made sharper and you see the rush happen, split to hide the later steps, across a real context boundary.
- **Repetition**: the same meaning in several places. Keep it in one place and point to it from the others.
- **Stale layers**: lines added over time that no longer apply, because adding feels safe and removing feels risky. Delete them, and check every line against what the skill does now whenever you edit it.
- **Sprawl**: too long even though every line is current and unique. Move rarely needed content into reference files and split by trigger or sequence.
- **No-op**: a line the model would follow anyway. Delete it. If it is a weak leading word (_be thorough_), replace it with a stronger one (_relentless_).

---

*Distilled from [writing-great-skills](https://github.com/mattpocock/skills) by Matt Pocock.*
