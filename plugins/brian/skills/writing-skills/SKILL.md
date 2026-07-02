---
name: writing-skills
description: Principles and vocabulary for writing and editing skills that make an agent's behaviour predictable.
disable-model-invocation: true
---

# Writing Skills

A skill wrangles determinism out of a stochastic system. **Predictability** — the agent taking the same _process_ every run, not producing the same output — is the root virtue; every lever below serves it.

Bold terms are defined in [`references/glossary.md`](references/glossary.md).

## Invocation

Two choices, each spending a different cost:

- **Model-invoked** — omit `disable-model-invocation` and write the description as trigger phrasing ("Use when…"). Pick it only when the agent itself, or another skill, must reach the skill unaided; you pay **context load** for the always-loaded description.
- **User-invoked** — set `disable-model-invocation: true`; the description becomes a human-facing one-line summary. Zero context load, but you spend **cognitive load**: the human is the index that must remember it exists. When user-invoked skills outgrow memory, add a **router skill** that names them and when to reach each.

A **description** does two jobs: say what the skill is, and list the **branches** that trigger it. Front-load the **leading word**; one trigger per branch (synonyms renaming one branch are **duplication**); cut identity already in the body.

## Information hierarchy

Rank content by how immediately the agent needs it, and push each piece as far down as it will go:

1. **Steps** — the primary tier; end each on a **completion criterion**: make it _checkable_, and where it matters _exhaustive_, or you invite **premature completion**. A demanding criterion also drives thorough **legwork**.
2. In-skill **reference** — consulted on demand; often a legitimately flat peer-set, not a smell.
3. Disclosed reference — pushed behind a **context pointer**, loaded only when the pointer fires (a sibling like this glossary, through fully **external reference** that lives outside the skill).

**Progressive disclosure** is the move down this ladder; **branching** is the test — inline what every branch needs, disclose what only some reach. A context pointer's _wording_, not its target, decides whether the agent reaches the material. **Co-locate** what's read together: a concept's rules and caveats under one heading.

## Granularity

Each split spends one of the two loads, so split only when the cut earns it:

- **By invocation** — split off a model-invoked skill when a distinct **leading word** should trigger it, or another skill must reach it.
- **By sequence** — split a run of **steps** when the **post-completion steps** tempt the agent to rush the one in front of it. Hiding them encourages more **legwork** — but it only works across a real context boundary (a user-invoked hand-off or subagent dispatch); an inline call clears nothing.

## Pruning

- **Single source of truth** — keep each meaning in one authoritative place, so changing behaviour is a one-place edit.
- **Relevance** — check every line still bears on what the skill does.
- **No-ops** — hunt sentence by sentence; when a sentence changes nothing versus the model's default, delete it whole rather than trim it. Be aggressive.

## Leading words

A **leading word** is a compact concept already in the model's pretraining (e.g. _lesson_, _fog of war_, _tracer bullets_) that the agent thinks with while running the skill. Repeated as a token, it accrues a distributed definition and anchors a region of behaviour in the fewest tokens — in the body it anchors execution, in the description it anchors invocation. Refactor restatements into one word ("fast, deterministic, low-overhead" → a _tight_ loop). Prefer a pretrained word over a coined one, which recruits no priors. Give each skill **one** dominant leading word and name it before shipping; if you cannot name it, the skill has no spine.

## Prose craft

Sentence-level moves that make a skill read as one deliberate voice rather than a checklist. Each is a positive directive, applied while drafting:

- **Defining constraint** — open every skill with one plain declarative sentence stating what it does differently from the model's default (`diagnose` reaches bedrock instead of stopping at the first plausible cause). Write it as prose in the first line of the body, never under a `The constraint:` label.
- **It's working if** — where a skill has crisp tells, add a short checkable list of observable signals that it fired: a leading word reappearing in the trace, an artifact written to disk, a gate the agent refused to cross. These are how a reader confirms the skill ran, not just that it was loaded.
- **Refusal at the branch** — when a skill exists to prevent one specific rush, write the refusal as a short imperative at the exact step where the agent is tempted, tied to the leading word ("no red loop, no Phase 2"). Put it at the branch, not buried in a reference file the agent reaches only after the temptation has passed.

## Failure modes

Diagnose a misbehaving skill by symptom (each defined in the glossary); the cure is the action:

- **Premature completion** — sharpen the completion criterion first; only if it is irreducibly fuzzy _and_ you observe the rush, split to hide the **post-completion steps** — and only across a real context boundary (an inline model-invoked call clears nothing).
- **Duplication** — collapse the repeated meaning back to one **single source of truth**.
- **Sediment** — prune the stale layers, then keep a pruning discipline so they stop accruing.
- **Sprawl** — disclose reference and split by branch or sequence.
- **No-op** — cut the line; if it is a weak leading word (_be thorough_), strengthen it (_relentless_) instead.

---

*Distilled from [writing-great-skills](https://github.com/mattpocock/skills) by Matt Pocock.*
