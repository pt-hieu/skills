# Crux Round — depth panel on a single escalated finding

Read this when Step 5's crux branch fires (the most recent `### Round N Changes` carries an `ESCALATED-CRUX` disposition). A crux round replaces the normal verify-first re-run: the escalated finding is a design gap, not a defect, so this round does design work — enumerate the realistic resolutions, attack them, decide — instead of reviewing the whole target again.

Budget (enforced at Step 4 where escalation is recorded): one escalated finding per round, one crux round per challenge run, and the crux round consumes a round against the round-3 cap. When two findings both qualify as cruxes, the plan has a bigger problem — surface that to the user directly instead of escalating either.

## 1. Seed brief

Append `### Crux Brief` under the new `## Round N` heading before launching anyone:

```
### Crux Brief

**Crux question**: {the ESCALATED-CRUX decision question, verbatim from the disposition line}

**Established facts** (ground truth — verified in prior rounds; challenge these only with new empirical evidence):
- {each load-bearing fact prior rounds verified or falsified, one line each, with its evidence citation}

**Out of scope**: everything in the plan not implicated by the crux question. Prior-round findings with FIXED/REBUTTED/DEFERRED dispositions stay settled.
```

The Established facts list is what stops the depth panel from re-deriving or re-litigating prior rounds — state prior findings as facts with citations, never as open questions.

## 2. Panel

Launch in one message, each `general-purpose`, `model: "opus"`, `run_in_background: true`. Every prompt = the seed brief verbatim + `## Project Domain Knowledge` from Step 1.5 + the role framing + the output contract in §3.

- **Options architect** — always launched:

  ```
  You are designing the resolution space for the crux question. Enumerate every realistic option (include the do-nothing/retreat option), then build a decision matrix with repo-specific costs: for each option, what changes where (file paths, configs, pipelines), what it costs to build and to operate, what risks it carries, and what it forecloses. Verify feasibility claims against the actual repo and installed toolchain — an option that doesn't survive contact with the code is noted as eliminated, with evidence. Close with your recommendation and the strongest reason you might be wrong.
  ```

- **Red team** — always launched:

  ```
  You are attacking the crux resolution space. For each plausible option (derive them independently; you have the same facts), build the strongest case it fails in practice — hidden costs, second-order effects, the maintenance burden nobody prices in. Separately, steelman the case that every option is worse than retreating or re-scoping the plan. Ground each attack in the repo or verifiable evidence. Close with which option survives your attacks best, or "retreat" if none does.
  ```

- **Empiricist** — launched only when options hinge on empirically checkable claims the Established facts don't already settle:

  ```
  You are running the experiments that discriminate between options for the crux question. Identify the 1-3 checkable claims whose answer changes the decision, run each against the installed toolchain, and report what actually happened with reproduction steps. Run every experiment inside {scratchpad_dir}, keep the repository working tree untouched, and delete your scratch files before returning.
  ```

## 3. Output contract (replaces the Finding Anchor contract for this round only)

Append to every panel prompt:

```
## Output Contract (crux round)

Walk the option set, naming each option in one line (retreat/re-scope counts as an option — include it). For each option, compare its repo-specific cost, its risk, and what it forecloses, grounding every comparison in a citation or experiment. Then say which single option you would pick and why, and name the observation that would change your mind — the evidence that would flip your recommendation.

State confidence and its basis in plain prose. If you cannot ground a comparison, write UNKNOWN — {what you'd need} rather than estimating.
```

## 4. Synthesis and decision

Await the panel per the Step 2 await protocol (a twice-failed options architect or red team aborts the crux round — record `### Round N: CRUX ABORTED` and jump to Step 6 escalated; a twice-failed empiricist degrades: mark its claims UNKNOWN).

Persist each return as `### Crux — {options architect | red team | empiricist}`, tilde-fenced. Then append `### Crux Decision`:

1. Merge the matrices; where the architects and red team disagree on a cell, keep both readings with citations.
2. Pick the winning option: the one whose strongest red-team attack is either refuted by evidence or explicitly acceptable as a stated tradeoff. When the red team's retreat case survives, retreat IS the winning option.
3. Record: the chosen option, the tradeoff accepted in one sentence, the runner-up and why it lost, and the evidence-that-would-change-it lines carried forward verbatim.

## 5. Re-entry

- **A design option won**: amend the plan/impl with the chosen design, then record the original escalated finding's disposition as `FIXED — resolved by crux round: {chosen option}` in this round's `### Round N Changes`. The next round is a normal verify-first round (Step 5 items 1-3); its reviewers check the amendment like any other fix.
- **Retreat/re-scope won**: jump to Step 6 with the escalation banner; the crux recommendation line (templates.md Step 6) carries the retreat recommendation and its grounds. The terminal AskUserQuestion uses the escalated option set.
- **Round-3 cap hit by the crux round itself**: jump to Step 6 escalated, with the crux decision as the recommendation — the user gets a decided recommendation, never a bare "review required".
