# Glossary — Writing Skills

Terse definitions for the bold terms in [`SKILL.md`](../SKILL.md). The root virtue is **Predictability**; every term is a lever on it. Grouped by axis; failure modes collected at the end, tagged _failure mode_.

Distilled from Matt Pocock's [writing-great-skills](https://github.com/mattpocock/skills).

## Root

- **Predictability** — the agent behaving the same _way_ every run (same process, not same output); the virtue every other term serves.

## Invocation

- **Model-invoked** — keeps its **description**, so the agent and other skills can reach it; pays **context load**.
- **User-invoked** — description stripped; reachable only by the human typing its name; zero context load.
- **Description** — the machine-readable trigger; its presence makes a skill model-invoked, its absence user-invoked.
- **Context pointer** — a reference in context naming out-of-context material plus the condition for reaching it; its wording, not its target, decides reach.
- **Context load** — the cost a model-invoked skill's always-loaded description imposes on the context window.
- **Cognitive load** — the cost a user-invoked skill imposes on the human, who must remember it exists and when to reach for it.
- **Router skill** — a user-invoked skill that names the other user-invoked skills and when to reach each; cures cognitive load.
- **Granularity** — how finely skills are divided; each cut spends one load. Split by **invocation** (a distinct leading word) or by **sequence** (hide post-completion steps).

## Information hierarchy

- **Information hierarchy** — skill content ranked by how immediately the agent needs it: steps, then in-file reference, then disclosed reference.
- **Steps** — the ordered actions the agent performs; the primary tier when present. Each ends on a completion criterion.
- **Reference** — material consulted on demand; secondary to steps, or the whole content when there are none.
- **External reference** — reference living outside the skill system, invocable by none, pointable by any skill.
- **Completion criterion** — the condition signalling a unit of work is done; _checkable_ resists premature completion, _exhaustive_ drives legwork.
- **Progressive disclosure** — moving reference behind a context pointer so the top stays legible; licensed by branching.
- **Co-location** — keeping a concept's definition, rules, and caveats under one heading rather than scattered.

## Steering

- **Branch** — a distinct way a skill is invoked, so different runs take different paths through it.
- **Leading word** — a compact pretrained concept the agent thinks with; repeated as a token, it anchors behaviour in the fewest tokens. Prefer pretrained over coined.
- **Legwork** — the digging an agent does within a step (reading, exploring, changing); raised by a demanding completion criterion or a leading word.
- **Post-completion steps** — the steps after the current one; visible, they pull the agent into premature completion.
- **Handoff** — one agent dispatching another and reading what comes back; a conversation in prose, since neither side is a parser. Its violation is the **output contract** — a mandatory token, required closing line, or field list imposed on an exchange nothing branches on.

## Pruning

- **Single source of truth** — each meaning in exactly one authoritative place; **duplication** is its violation.
- **Relevance** — whether a line still bears on what the skill does.

## Prose craft

- **Defining constraint** — the one plain declarative sentence opening a skill, stating what it does differently from the model's default; written as prose, never under a `The constraint:` label.
- **It's working if** — a short checkable list of observable signals that a skill fired (a leading word recurring in the trace, an artifact written, a gate refused); confirms the skill ran, not just loaded.
- **Refusal at the branch** — a short imperative placed at the exact step where the agent is tempted to rush, tied to the leading word ("no red loop, no Phase 2"); at the branch, not buried in a reference file.
- **Write what is** — every rule stated as the only rule that ever existed; contrast against a prior version ("no longer", "instead of", "don't propose") is a diff against text the agent never saw.

## Failure modes

- **Premature completion** _(failure mode)_ — ending a step before it is done; needs steps to occur, so a step-less skill that quits early is thin **legwork**, not this. Defence in order: sharpen the criterion, then split (across a real context boundary) to hide post-completion steps.
- **Duplication** _(failure mode)_ — the same meaning in more than one place; costs maintenance and tokens and inflates a meaning's rank.
- **Sediment** _(failure mode)_ — stale layers that accumulate because adding feels safe and removing feels risky; the default without a pruning discipline.
- **Sprawl** _(failure mode)_ — a skill too long even when every line is live and unique; cured by the hierarchy.
- **No-op** _(failure mode)_ — a line the model already obeys by default. Test: does it change behaviour versus the default?
