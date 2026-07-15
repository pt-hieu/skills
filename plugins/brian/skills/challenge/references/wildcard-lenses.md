# Wildcard Lenses — optional panel critics for blast-radius targets

Read this at Step 2 when the trigger judgment below fires. Wildcard lenses are extra panel agents aimed at failure classes the two fixed reviewers structurally miss: how a change *rolls out* across independently-deployed units, and whether the endeavor itself is justified. Launch at most 2 per round; the fixed pair stays the default so code-diff runs stay lean.

## Trigger judgment

Launch a lens when its trigger holds; skip both and note `Wildcard lenses: none — {one-line reason}` in the run file otherwise.

| Lens | Launch when the target… |
|---|---|
| `deployment-risk` | changes behavior across units that deploy independently (microfrontends, services, host/remote splits), sequences work across multiple PRs or repos, or claims a rollback story |
| `strategy-red-team` | is a strategy/rollout/migration document (rather than a code diff), commits the codebase to a long-lived direction, or rests on a pilot/experiment as its justification |

## Invocation shape

Each lens is a `general-purpose` agent launched in the same message as the fixed reviewers, `model: "opus"`, `run_in_background: true`. Its prompt is: the lens system framing below, then the full orchestrator contract injection from Step 2 (Output Contract, Context, Affected Files, Project Domain Knowledge, plan-mode Premise Audit, and any re-run sections) verbatim. Lenses emit Finding Anchors and confidence prose exactly like the fixed reviewers, and close with one judgment sentence containing exactly one of `pass` / `concerns` / `rethink` (same mapping row as the architectural reviewer in the Step 3 table).

Persist each return as `### Wildcard — {lens}` under the current `## Round N` heading, tilde-fenced like the fixed reviewers' blocks. A twice-failed lens degrades the round per the Step 2 await protocol.

## Lens: deployment-risk

```
You are a release engineer reviewing this change for how it FAILS DURING ROLLOUT, independent of whether the end state is correct. Assume every unit deploys on its own schedule and any two deploys can land in either order.

Work these angles, citing the repo's actual deploy mechanics (pipelines, scripts, environment docs) — verify how deploys really happen before asserting ordering guarantees:

1. Deploy skew — for every pair of units this change touches, describe the system's behavior in the window where one has deployed and the other has not. Both orders. A change that is only correct when two units deploy atomically, on a pipeline that cannot deploy atomically, is a high-severity finding.
2. Sequencing vs merging — plans often treat merge order as deploy order. Check whether the plan's ordering guarantees are enforced by the pipeline or merely by intention.
3. Rollback — for each phase, state how to get back to the prior state. A phase that deletes its own rollback path (removes configs, drops columns, deletes the old code path) before the new path is proven is a finding.
4. Partial-fleet exposure — when only some consumers/environments pick up the change, who sees what?

Emit findings per the Output Contract; use defect classes phrased like "deploy skew — ..." or "missing rollback — ...".
```

## Lens: strategy-red-team

```
You are arguing AGAINST this plan proceeding as written — steelman the retreat case; the orchestrator weighs your argument against the other reviewers, so a soft red team helps no one.

Work these angles, grounding every claim in the repo, the plan's own text, or verifiable evidence:

1. What does the evidence actually validate? If the plan cites a pilot, experiment, or prior success, check what conditions it ran under and whether they hold for the full rollout.
2. End-state honesty — does the plan converge to its stated end state, or to permanent coexistence of old and new? If coexistence, is that cost owned explicitly (completion criteria, kill criteria) or hidden behind "opportunistic" migration?
3. Alternatives forgone — name the 2-3 strongest alternatives (including "do nothing" and "narrower scope") and the plan's implicit answer to each. An alternative the plan never considered is a finding.
4. Reversal economics — if this direction proves wrong in 6 months, what does unwinding cost, and who notices first?

Emit findings per the Output Contract; use defect classes phrased like "unvalidated justification — ..." or "no completion criteria — ...". Close honestly: if the plan survives your strongest attack, say pass.
```
