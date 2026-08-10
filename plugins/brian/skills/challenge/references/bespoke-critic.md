# Bespoke Critic — authoring the target-specific adversary

Read this once SKILL.md's Step 2 gate has named an aspect and written it to the run file. The judgment lives there and stays there; reaching this file means the aspect is already chosen, and what remains is writing the critic well.

A bespoke critic is one extra panel agent that goes deep on a single aspect of one target, in the way the standing reviewers go broad across many. Depth is the whole point — a one-sentence version of an angle inside a broad reviewer's prompt misses what a dedicated agent finds.

## Invocation shape

Launch as a `general-purpose` agent in the same message as the standing panel, `model: "opus"`, `run_in_background: true`. Its prompt is the framing you author below, then the full orchestrator contract injection from Step 2 (Output Contract, Context, Affected Files, Project Domain Knowledge, and the plan-mode Premise Audit) verbatim.

Persist the return as `## Bespoke Critic — {aspect}`, tilde-fenced like the standing reviewers' blocks. A twice-failed critic degrades the run per the Step 2 await protocol.

## Authoring the framing

The `prompting` skill governs craft here; this section covers what the challenge panel additionally requires. Four things the framing must carry:

1. **A stance** — a role that wants the plan to fail on the named aspect. The stance is what produces depth; a neutral "review this for X" returns the same altitude the standing panel already covers.
2. **Three to five angles** that decompose the aspect into questions with checkable answers — answers living in the repo, the target's own text, or the toolchain.
3. **A grounding requirement** — verify against the actual repo before asserting, and name the file or command checked.
4. **The closing keyword**, as a hard requirement: close with one judgment sentence containing exactly one of `pass` / `concerns` / `rethink` (Step 3's mapping table parses it, on the architectural reviewer's row). Tell the critic that a plan surviving its strongest attack earns `pass` — absent that line an adversarial stance never closes positive, and the keyword stops carrying information.

Findings also follow the Output Contract already in the injection: Finding Anchors and confidence in prose, exactly like the standing reviewers.

## Worked derivations

Two critics authored for past targets, here to calibrate shape — stance, angle count, grounding — for a critic you derive from *your* target's text. Where a recorded aspect genuinely matches one of these, adapt it; what the framing must serve is the aspect written at Step 2.

### Derived for: a plan sequencing a lint-rule rollout across two repos

Aspect recorded: *how this fails during rollout, given the two repos deploy on their own schedules.* The target text that made it load-bearing was the plan's own claim that PR 2 lands only after PR 1 has baked for a week.

```
You are a release engineer reviewing this change for how it FAILS DURING ROLLOUT, independent of whether the end state is correct. Assume every unit deploys on its own schedule and any two deploys can land in either order.

Work these angles, citing the repo's actual deploy mechanics (pipelines, scripts, environment docs) — verify how deploys really happen before asserting ordering guarantees:

1. Deploy skew — for every pair of units this change touches, describe the system's behavior in the window where one has deployed and the other has not. Both orders. A change that is only correct when two units deploy atomically, on a pipeline that cannot deploy atomically, is a high-severity finding.
2. Sequencing vs merging — plans often treat merge order as deploy order. Check whether the plan's ordering guarantees are enforced by the pipeline or merely by intention.
3. Rollback — for each phase, state how to get back to the prior state. A phase that deletes its own rollback path (removes configs, drops columns, deletes the old code path) before the new path is proven is a finding.
4. Partial-fleet exposure — when only some consumers/environments pick up the change, who sees what?

Emit findings per the Output Contract; use defect classes phrased like "deploy skew — ..." or "missing rollback — ...". Close honestly: if the plan survives your strongest attack, say pass.
```

### Derived for: a migration strategy document justified by a pilot

Aspect recorded: *whether the pilot actually validates the full rollout it is being used to justify.* The target text that made it load-bearing was the document resting its case on a six-month pilot in a single app.

```
You are arguing AGAINST this plan proceeding as written — steelman the retreat case; the orchestrator weighs your argument against the other reviewers, so a soft red team helps no one.

Work these angles, grounding every claim in the repo, the plan's own text, or verifiable evidence:

1. What does the evidence actually validate? If the plan cites a pilot, experiment, or prior success, check what conditions it ran under and whether they hold for the full rollout.
2. End-state honesty — does the plan converge to its stated end state, or to permanent coexistence of old and new? If coexistence, is that cost owned explicitly (completion criteria, kill criteria) or hidden behind "opportunistic" migration?
3. Alternatives forgone — name the 2-3 strongest alternatives (including "do nothing" and "narrower scope") and the plan's implicit answer to each. An alternative the plan never considered is a finding.
4. Reversal economics — if this direction proves wrong in 6 months, what does unwinding cost, and who notices first?

Emit findings per the Output Contract; use defect classes phrased like "unvalidated justification — ..." or "no completion criteria — ...". Close honestly: if the plan survives your strongest attack, say pass.
```
