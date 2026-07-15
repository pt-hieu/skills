---
name: challenge
description: "Use before finalizing a significant plan, after complex implementation changes, before PRs touching core architecture, or when uncertain whether a solution is systematic enough."
---

# Challenge

Fire independent opus subagents in parallel to stress-test a plan or implementation. The panel challenges whether the changes keep the architecture healthy, expandable, and maintainable — whether they fix root causes vs patch symptoms — and, in plan mode, whether the plan's own factual claims and load-bearing premises actually hold.

The two fixed reviewers are first-class plugin agents, launched on every run:
- `brian:architectural-reviewer` — coupling, cohesion, module depth, historical coherence, expandability, side effects
- `brian:root-cause-reviewer` — iterative-deepening RCA, defect class identification, sibling-instance search

Plan mode adds a third fixed agent:
- `brian:plan-fact-checker` — verifies every file:line, count, path, and version claim the plan makes against the actual repo and installed toolchain

The orchestrator may also add up to 2 wildcard lenses (deployment risk, strategy red-team) when the target warrants — trigger judgment and lens prompts live in `references/wildcard-lenses.md` (read it at Step 2 whenever the target touches deployment topology or external systems, or is a strategy/rollout document rather than a code diff).

The fixed reviewers' and fact-checker's system prompts live in `plugins/brian/agents/`; wildcard lenses and the crux-round panel are prompt templates in this skill's `references/`. This skill orchestrates context assembly, parallel invocation, and synthesis. **The orchestrator owns the I/O contract** (Reuse Contract sections, Finding Anchor format, INSUFFICIENT CONTEXT semantics, Premise Audit section, re-run sections, and the crux-round mini-contract in `references/crux-round.md`). Agent files keep methodology, dimensions, examples, and their per-agent closing-judgment keywords only.

This skill deliberately holds quantitative state verbally (deviating from the `prompting` skill's deterministic-split rule) — the rationale and the one concrete formula it defends live together in `references/domain-harvest.md`.

## Step 0: Run Setup

Compute a run file path and initialize it. Persistence survives compaction and gives every round a forensic trail.

```
run_file=/tmp/claude-challenge/$(date -u +%Y%m%dT%H%M%SZ)-$(openssl rand -hex 3).md
mkdir -p /tmp/claude-challenge
printf "# Challenge Run — $(date -u +%FT%TZ)\n- Mode: <implementer|review-only>\n- Target: <plan path | git ref>\n\n" > "$run_file"
{ printf "## Working-Tree Snapshot (Step 0)\n~~~\n"; git status --porcelain; printf "~~~\n\n"; } >> "$run_file"
```

The snapshot is the baseline for Step 6's working-tree hygiene check (experiment leftovers show up as paths new since Step 0).

Print `$run_file` so the user can re-open it later. All round artifacts append to it as `## Round N` subsections — for the full persistence, re-run injection, and extraction mechanics, read `references/run-file-mechanics.md` (needed at every persistence point and on every re-run round).

## Step 1: Determine Challenge Target

Identify what to challenge:
- **Plan mode**: challenge the proposed approach before implementation.
- **Implementation mode**: challenge code that was just written or changed.

Gather context:
- If plan: read the plan content or task list verbatim into `## Context`.
- If implementation: capture `git diff <base-ref>...HEAD`. Note `<base-ref>` in the run file's header line.
- Identify affected files/modules — derive from `git diff --name-only` in impl mode; list explicitly in plan mode.

## Step 1.0: Caller Disposition

Determine whether the caller is the implementer (can Fix/Rebut/Defer findings) or a reviewer (only writes comments). Note the mode in the run file's header line — human-facing only. Mode is bound in the orchestrator's working memory at Step 1.0; later steps NEVER re-parse the header line to re-derive mode.

**Detection signals**:
- Implementer: working tree has uncommitted changes; HEAD ahead of origin on a non-default branch; user phrasing such as "my plan", "before I push", "I just changed".
- Review-only: diff comes from `gh pr diff` or `git fetch origin pull/<N>/head`; clean working tree on a checked-out PR branch; phrasing like "review this PR", "audit X's branch".

**Default on ambiguity**: review-only (writing comments is reversible; running disposition logic on someone else's code is not). When the caller is interactive, ask once via `AskUserQuestion`; otherwise default.

**Dispatch table** (later steps reference this binding; no later step re-checks mode):

| Mode | Step 4 procedure | Step 5 loop | Step 6 terminal |
|---|---|---|---|
| implementer | Round N Changes (Fix / Rebut-cite / Rebut-judgment / Defer) | enabled | proceed / manual review / rollback |
| review-only | Append `### PR Review Comments` to run file | skipped | post via Bitbucket MCP / copy to clipboard / done |

## Step 1.5: Domain Knowledge Harvest

Before Step 2, run the 5-stage Domain Knowledge Harvest to produce `{knowledge_context}` — read and execute `references/domain-harvest.md` (fires on every round; it also carries the relevance-formula deviation rationale).

## Step 2: Launch the Reviewer Panel in Parallel

Compose the panel:

- **Always**: `brian:architectural-reviewer` and `brian:root-cause-reviewer`, each with `model: "opus"`.
- **Plan mode**: add `brian:plan-fact-checker` with `model: "sonnet"` (claim verification is mechanical exploration; reserve opus for the judgment-heavy reviewers).
- **Wildcard lenses** (0–2): when the target touches deployment topology or external systems, or is a strategy/rollout document, read `references/wildcard-lenses.md` and launch the lenses it selects.

All calls MUST be emitted as **tool-use blocks in the same assistant message** so they run concurrently, each with `run_in_background: true`.

The orchestrator-injected contract goes into the user-turn `prompt` field. Identical for every panel agent:

```
## Output Contract

Every finding MUST start with a structured Finding Anchor on its own line:

  Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>

Name the defect class in plain words — a short phrase describing the underlying defect (e.g. "missing validation — external input to a DB query"), not a label from a fixed list. Keep the `defect_class` field on every anchor: synthesis merges findings by `(file, defect_class)`, so the phrase is load-bearing.

Confidence: state each finding's confidence and its basis in plain prose within the finding body (high when you verified it against cited code; low when it rests mostly on the diff). Do not append a tag.

Abstinence rule (INSUFFICIENT CONTEXT): if you cannot assess a dimension with the provided data, output `INSUFFICIENT CONTEXT — [what's missing, what you'd need to read/verify]` for that dimension and move on. Do NOT speculate.

## Context
{plan text OR git diff}

## Affected Files
{list of repo-relative paths}

## Project Domain Knowledge
{knowledge_context from Step 1.5}
```

**In plan mode**, append the `## Premise Audit` section to every panel agent's contract — read `references/premise-audit.md` for the block to inject and its rationale.

On re-runs (round 2+), append two more sections (read from the run file per Step 5):

```
## Prior Round Findings
{concatenated ### Synthesis subsections from every prior round, separated by --- Round K --- markers}

## Round N Changes
{the most recent prior round's ### Round N Changes subsection}
```

When the contract injection includes Prior/Changes blocks, agent job order shifts to verify-first: (a) verify each prior finding, (b) call out rebuttals that don't hold, (c) check whether fixes introduced new issues, (d) only then look for net-new findings.

If gaps were resolved between attempts (Step 3 retry), append:

```
## Resolved Gaps
{the missing context that was fetched, formatted for that agent}
```

Do not re-embed agent-definition content in the prompt.

**Before deleting or renaming any Output Contract field**, run the Contract Audit in `references/contract-audit.md` first — it greps every copy of the contract (reviewer agents plus sibling skills) so a token rename touches them all in the same commit.

### Await protocol

After emitting the calls, the loop driver MUST NOT proceed to Step 3 until every launched agent has returned. Use the harness's task-completion notifications (no polling). Emit at most one status line in the wait window.

On agent error or timeout: retry once with the same prompt. Failure handling splits by agent class:

- **Fixed reviewers** (`architectural-reviewer`, `root-cause-reviewer`): if both fail twice, append `### Round N: ABORTED — both fixed reviewers failed twice` to the run file. Skip Step 5; jump to Step 6 with `mode = aborted`: chat emits one-line abort + run-file path; AskUserQuestion offers retry / proceed without challenge / rollback. Do NOT silently terminate — the user must reach a terminal disposition. **Do not synthesize a one-agent verdict** — the cross-agent conflict check between the two fixed reviewers is load-bearing.
- **Auxiliary agents** (`plan-fact-checker`, wildcard lenses): a twice-failed auxiliary agent degrades the round instead of aborting it — append `### {agent}: FAILED — degraded round` to the run file, note the gap in the synthesis's Insufficient Context Areas, and cap the round's verdict at `REVISE` (an unverified claims inventory is an unresolved gap, same as Step 3.1).

## Step 3: Synthesize Results

Each agent closes with a plain-language judgment sentence containing exactly one named keyword. Read that keyword — do not infer a verdict from the overall tone — and map it onto the final report's verdict:

| Agent | Keyword in its closing sentence | Positive | Concerning | Fundamental issue |
|---|---|---|---|---|
| `architectural-reviewer` | `pass` / `concerns` / `rethink` | pass | concerns | rethink |
| `root-cause-reviewer` | `systematic` / `partial` / `patch-only` | systematic | partial | patch-only |
| `plan-fact-checker` (plan mode) | `accurate` / `discrepancies` / `unsound` | accurate | discrepancies | unsound |
| wildcard lenses (when launched) | `pass` / `concerns` / `rethink` | pass | concerns | rethink |
| Final `Overall Verdict` | (orchestrator-owned) | PASS | REVISE | RETHINK |

A positive-column keyword contributes a PASS-leaning signal, a concerning-column keyword a REVISE-leaning signal, and a fundamental-issue keyword a RETHINK-leaning signal; combining across the whole panel, the worst signal governs the final verdict. (The `✅`/`⚠️`/`❌` display columns in the chat templates are cosmetic and map directly off these keywords.)

After all panel agents complete:

### 3.0 Persist agent returns

Append `### Architectural Review` and `### Root-Cause Review` verbatim under the current `## Round N` heading, tilde-fenced — plus `### Fact Check` in plan mode and `### Wildcard — {lens}` per launched lens. Full mechanics in `references/run-file-mechanics.md`.

### 3.1 INSUFFICIENT CONTEXT gate (pre-verdict)

Count `INSUFFICIENT CONTEXT` dimensions across all panel agents.

- If the gap is **closable** (file path / ticket / grep pattern reachable from the orchestrator): fetch the missing context (`Read` the file, `WebFetch` the ticket, run the grep), then re-launch **only the affected agent** with an extra `## Resolved Gaps` block. Cap at 1 retry per round. After retry, re-run 3.0 and re-evaluate the gate.
- If the gap is **non-closable** OR remains unresolved after retry: verdict is capped at `REVISE` regardless of finding count. Cannot `PASS` with unresolved gaps. The "Insufficient Context Areas" section in the report becomes a top-level callout, not a footnote.

### 3.2 Merge / dedupe / prioritize

1. Collect every panel agent's closing keyword and read each finding's confidence from its prose.
2. **Discard unverified and low-confidence findings** (confidence judged from the finding's prose) unless they represent a potentially critical concern worth flagging.
3. Merge overlapping concerns by anchor similarity: same `file` AND the same underlying `defect_class`. `defect_class` is now a plain-words phrase, so judge sameness by *meaning* — two findings on the same file are the same finding only when they describe the same underlying defect class. A structural issue and a missing test on the same file are distinct defect classes; do NOT merge them (this preserves the non-collapse guarantee). When merging genuine duplicates, note both source agents.
4. Prioritize by severity × confidence, both judged from the prose: high-severity blockers first, then medium.
5. **Detect cross-agent conflicts** — if architectural-reviewer says "good abstraction" but root-cause-reviewer says "over-abstraction hides the root cause", surface this explicitly with both sides cited.
6. **False Consensus Check** — if every panel agent closed positive (all positive-column keywords) AND none raised any concern they described as medium-or-higher severity:
   - Note: "The whole panel agrees this is clean. Applying extra scrutiny."
   - Re-examine the 3 highest-risk areas of the diff/plan for anything the panel may have normalized or overlooked.
   - If something is found, add it as a new finding with tag `[CONSENSUS-BLIND-SPOT]`.
   - Otherwise note: "False consensus check completed — agreement appears genuine."

The merged finding list is held verbally for the duration of one synthesis pass; that's all that's needed.

### 3.3 Render the unified report

Synthesis goes two places: appended verbatim to the run file (forensic, 3.3a), and rendered compactly in chat (user-facing, 3.3b). 3.3a runs only after 3.1 resolves; 3.3b runs only after 3.3a is appended.

- **3.3a** — append `### Synthesis` to the run file using the template and gating in `references/run-file-mechanics.md`.
- **3.3b** — render the compact chat synthesis per `references/templates.md`, projecting from the same merged finding list (fields are NOT re-derived).

On the aborted-round path (both fixed reviewers failed twice): skip both 3.3a and 3.3b; emit only `Round N: ABORTED — both fixed reviewers failed twice. See <run_file>.`

## Step 4: Critically Address Findings (Round N)

Branch on `mode` from Step 1.0. No later step re-checks mode. Use the exact render blocks in `references/templates.md` (4a for implementer, 4b for review-only).

### 4a. Implementer mode

Treat the Step 3 report as a hostile audit, not a list of suggestions. Default disposition is "the reviewer is right" — flip that only with evidence.

For every high- and medium-severity finding (severity judged from the prose, including any `[CONSENSUS-BLIND-SPOT]`), pick exactly one of five dispositions:

1. **Fix** — modify the plan or diff so the finding no longer applies. State what changed and where (`file:line` for impl, plan section for plan mode).
2. **Rebut (cite)** — explain why the finding is wrong, with concrete evidence: file references, prior decisions in git history, constraints the reviewer didn't see, or domain rules from Step 1.5. A rebuttal without citable evidence does not count — convert to Fix.
3. **Rebut (judgment)** — eligible only when EITHER the original reviewer described the finding as a tradeoff point (architectural-reviewer names tradeoff points explicitly in its prose) OR the concern's scope is naming / style / local readability. Requires:
   - Explicit tradeoff statement (`accepting X cost for Y benefit`)
   - Acknowledgment of the reviewer's point as legitimate before overriding
   - On a high-severity JUDGMENT rebuttal: sibling-instance check — grep for other places the same judgment was made; document the consistency.
   - There is no fixed percentage cap; misuse is caught by the next round's reviewer pass (see Step 5).
4. **Defer** — the finding is real but genuinely out of scope. Requires a follow-up reference (ticket, task, or `/schedule` agent). "Out of scope" is not a synonym for "hard."
5. **Escalate (crux)** — the finding is a design gap, not a defect: resolving it requires a design decision that reshapes the plan, and the next round would be design work, not more review. Eligibility test, both required:
   - **Verdict-driving**: this finding is what holds the round at REVISE/RETHINK.
   - **Non-disposable**: writing the Fix line would mean inventing a design on the spot — there is no known fix to point at.

   Record the disposition as `ESCALATED-CRUX — {the crux stated as a decision question}`; the next round becomes a crux round (Step 5). Budget rules and the round's full mechanics live in `references/crux-round.md`.

Hard rules:
- Every finding gets exactly one recorded disposition — a finding with no disposition line is a contract violation.
- A "Fix" disposition must change the approach the reviewer flagged; restating the same approach in different words counts as no disposition.
- Cross-agent conflicts from Step 3 must be resolved (pick a side with evidence) before proceeding.

Append the **Round N Changes** block to the run file under the current `## Round N` heading; the forensic record allows multi-line dispositions, the chat render is one line per finding (hard cap). Both templates in `references/templates.md`.

### 4b. Review-only mode

Skip Fix/Rebut/Defer entirely. The caller is not the implementer — they leave comments. Append `### PR Review Comments` (verbose, with code snippets) to the run file, then render the compact chat view — both per `references/templates.md`. Append `### Review-only round — terminal` to the run file. Skip Step 5 entirely; jump to Step 6.

## Step 5: Re-Challenge Loop (implementer mode only)

Re-run the challenge to verify changes hold. Keep looping until the plan/impl would pass a fresh round with no new HIGH/MEDIUM findings. Skipped in review-only mode.

**Crux branch**: when the most recent `### Round N Changes` contains an `ESCALATED-CRUX` disposition, the next round is a **crux round** — read and execute `references/crux-round.md` instead of items 1–3 below. A crux round consumes a round against the round-3 cap; its outcome re-enters this loop per that reference's re-entry rules.

1. **Increment round**. Re-launch the panel (Step 2) with the contract injection PLUS `## Prior Round Findings` and `## Round N Changes` — build them per the extraction grammar in `references/run-file-mechanics.md`. The reviewers' verify-first behavior is enabled by these sections (see Step 2).
2. **Disposition rule enforcement**: instruct the fixed reviewers to flag a high-severity Disposition rule violation finding for any of:
   - `REBUTTED-JUDGMENT` used outside the eligibility filter (not a tradeoff point AND not naming/style/local readability).
   - `REBUTTED-JUDGMENT` of a high-severity finding without a documented sibling-instance check.
   - `DEFERRED` without a follow-up reference.
3. **Re-synthesize** (Step 3) to produce a Round N+1 report. Append artifacts to the run file.
4. **Termination check** — exit the loop when ANY of:
   - **Overall Verdict = PASS** → go to Step 6.
   - **Round 3 reached** without PASS → exit, transition to Step 6 with escalation. Do not silently continue past round 3.
   - **Diminishing returns**: the orchestrator reads the prior round's findings and, if findings rhyme across rounds (same file/defect-class re-surfacing by similar prose, or any finding marked FIXED in the prior `### Round N Changes` reappears in the new `### Synthesis`), exits and surfaces honestly rather than grinding further.

   Otherwise (new or remaining HIGH/MEDIUM findings, fixable) → return to Step 4 as Round N+1.

Each round MUST produce a Round N Changes block, even if it consists only of rebuttals. Track round-over-round verdict progression (e.g., `RETHINK → REVISE → PASS`) verbally for Step 6.

## Step 6: Final Report

The run file IS the final report. Chat emits a single turn using the Step 6 template in `references/templates.md` (verdict progression, panel marks, escalation banner with crux recommendation, overflow fallback).

### Working-tree hygiene check (plan mode, before the chat turn)

Panel agents that ran premise-audit or crux-round experiments were instructed to work in the scratchpad only. Verify: run `git status --porcelain` and compare against the same snapshot captured at Step 0. Any path new since Step 0 is an experiment leftover — remove it after confirming it matches experiment artifacts (paths that already existed at Step 0 stay untouched), and note the cleanup in the run file.

### Terminal action

Use `AskUserQuestion`. Options vary by mode and escalation:

- **implementer + non-escalated PASS**: `proceed` / `manual review` / `roll back`.
- **implementer + escalated**: `manual review` / `roll back` / `accept risk and proceed (explicit confirmation required)`. No silent default.
- **review-only**: `post comments via Bitbucket MCP` / `copy to clipboard` / `done`.
- **aborted** (both fixed reviewers failed twice): `retry challenge` / `proceed without challenge` / `roll back`.
