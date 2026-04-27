# Challenge — Execution Guide

Fire 2 independent opus subagents in parallel to stress-test a plan or implementation. Both agents challenge whether the changes keep the architecture healthy, expandable, and maintainable — and whether they fix root causes vs patch symptoms.

The reviewers are first-class plugin agents:
- `brian:architectural-reviewer` — coupling, cohesion, historical coherence, expandability
- `brian:root-cause-reviewer` — iterative-deepening RCA, defect class identification, sibling-instance search

Their system prompts live in `plugins/brian/agents/`. This skill orchestrates context assembly, parallel invocation, and synthesis. **The orchestrator owns the I/O contract** (Reuse Contract sections, Finding Anchor format, INSUFFICIENT CONTEXT semantics, defect-class enum, re-run sections). Agent files keep methodology, dimensions, examples, and per-agent verdict enums only.

---

## Step 0: Run Setup

Compute a run id and create the artifact directory. Persistence survives compaction and gives every round a forensic trail.

```
run_id = $(date -u +%Y%m%dT%H%M%SZ)-$(openssl rand -hex 3)
artifact_dir = /tmp/claude-challenge/<run_id>
mkdir -p <artifact_dir>/round-1
```

Initialize `manifest.json`:

```json
{
  "run_id": "<run_id>",
  "started_at": "<iso8601>",
  "mode": null,
  "base_ref": "<git rev-parse for impl, null for plan>",
  "rounds": []
}
```

Print the artifact directory path so the user can re-open it later.

---

## Round Lifecycle

Each round writes a fixed set of files into `<artifact_dir>/round-N/`:

- `context.md` — the assembled user-turn prompt (written before launching agents)
- `architectural.md` — verbatim architectural-reviewer return
- `root-cause.md` — verbatim root-cause-reviewer return
- `synthesis.md` — Step 3 unified report (implementer + review-only)
- `changes.md` — Step 4 Round N Changes block (implementer mode only)
- `pr-review-comments.md` — Step 4 output (review-only mode only)

If a Step 3 retry fetches missing context, the re-launched agent's output overwrites its file (the original is preserved in the synthesis report's prior-attempt note). If both agents fail twice, mark the round aborted in `manifest.json` and skip synthesis.

Re-runs (Step 5) read prior `synthesis.md` + `changes.md` from disk and inject them as `## Prior Round Findings` + `## Round N Changes` into the next round's Step 2 contract. Review-only mode never re-runs (no loop, no escalation banner).

---

## Step 1: Determine Challenge Target

Identify what to challenge:
- **Plan mode**: challenge the proposed approach before implementation.
- **Implementation mode**: challenge code that was just written or changed.

Gather context:
- If plan: read the plan content or task list verbatim into `## Context`.
- If implementation: capture `git diff <base-ref>...HEAD`. Record `<base-ref>` in manifest.
- Identify affected files/modules — derive from `git diff --name-only` in impl mode; list explicitly in plan mode.

---

## Step 1.0: Caller Disposition

Determine whether the caller is the implementer (can Fix/Rebut/Defer findings) or a reviewer (only writes comments). Persist `mode` in `manifest.json`.

**Detection signals**:
- Implementer: working tree has uncommitted changes; HEAD ahead of origin on a non-default branch; user phrasing such as "my plan", "before I push", "I just changed".
- Review-only: diff comes from `gh pr diff` or `git fetch origin pull/<N>/head`; clean working tree on a checked-out PR branch; phrasing like "review this PR", "audit X's branch".

**Default on ambiguity**: review-only (writing comments is reversible; running disposition logic on someone else's code is not). When the caller is interactive, ask once via `AskUserQuestion`; otherwise default.

**Dispatch table** (later steps reference this binding; no later step re-checks mode):

| Mode | Step 4 procedure | Step 5 loop | Step 6 terminal |
|---|---|---|---|
| implementer | Round N Changes (Fix / Rebut-cite / Rebut-judgment / Defer) | enabled | proceed / manual review / rollback |
| review-only | Write `pr-review-comments.md` | skipped | post via Bitbucket MCP / copy to clipboard / done |

---

## Step 1.5: Domain Knowledge Harvest (5-stage pipeline)

Gather project-specific knowledge so agents review against documented patterns, not just general principles. Pipeline produces `{knowledge_context}` for Step 2.

### Stage 1 — Collect

Walk all sources, build a candidate list `[{source, path, name, description}]`:

- **Project skills** (deduped by name, in priority order):
  - `.claude/skills/*/SKILL.md`
  - `plugins/*/skills/*/SKILL.md` (catches plugin marketplaces)
  - `<git-root>/.claude/skills/*/SKILL.md`
- **User skills** (only if relevant per Stage 2 score):
  - `~/.claude/plugins/marketplaces/*/plugins/*/skills/*/SKILL.md`
- **Project rules sources** (separate from skill blocks; assembled into a Project Rules Block):
  - `<git-root>/CLAUDE.md`, `<git-root>/.claude/CLAUDE.md`, `~/.claude/CLAUDE.md`
  - Any `*/CLAUDE.md` whose directory is an ancestor of an affected file (monorepo support)
  - `<git-root>/AGENTS.md`, `<git-root>/CONTRIBUTING.md` (skip `README.md` — too noisy by default)

### Stage 2 — Score

For each skill candidate compute:

```
relevance = (path-overlap-with-affected-files * 3)
          + (name-mention-in-context-or-paths * 2)
          + (description-domain-match * 1)
```

### Stage 3 — Rank

Stable sort skill candidates by relevance descending.

### Stage 4 — Trim

Keep the top 5 skill candidates after ranking. Discard the rest.

### Stage 5 — Assemble

Compose each kept skill as a Skill Context Block (max 200 words each):

```
### Skill: {name}
**Domain**: {what area this covers}
**Patterns to verify**: {documented patterns the diff/plan should follow}
**Constraints/Gotchas**: {rules that could be violated — review criteria}
**Deep-dive paths**: {file paths agents can Read for more context}
```

Assemble blocks until the aggregate `{knowledge_context}` reaches 1500 words. On overflow drop the lowest-ranked **whole** block; never truncate mid-block. CLAUDE.md / AGENTS.md / CONTRIBUTING.md content goes into a separate Project Rules Block (not subject to the 5-skill trim, capped at 500 words).

If the pipeline yields zero blocks: `"No project-specific skills or CLAUDE.md found. Review using general software engineering principles only."`

---

## Step 2: Launch Both Reviewers in Parallel

Invoke `brian:architectural-reviewer` and `brian:root-cause-reviewer` via the `Agent` tool. Both calls MUST be emitted as **two tool-use blocks in the same assistant message** so they run concurrently. Each call uses `model: "opus"` and `run_in_background: true`.

The orchestrator-injected contract goes into the user-turn `prompt` field. Identical for both agents:

```
## Output Contract

Every finding MUST start with a structured Finding Anchor on its own line:

  Finding Anchor: defect_class=<CATEGORY>; file=<repo-relative-path>; line=<N | "cross">; summary=<one-sentence canonical issue>

defect_class enum (closed list):
  Missing Validation | Missing Abstraction | Implicit Assumption |
  State Synchronization Gap | Error Handling Gap | Boundary Violation |
  Resource Lifecycle | Concurrency Hazard | Configuration Drift |
  API Contract Violation

Confidence calibration: every finding ends with a confidence tag — [HIGH] / [MEDIUM] / [LOW].

Abstinence rule (INSUFFICIENT CONTEXT): if you cannot assess a dimension with the provided data, output `INSUFFICIENT CONTEXT — [what's missing, what you'd need to read/verify]` for that dimension and move on. Do NOT speculate.

## Context
{plan text OR git diff}

## Affected Files
{list of repo-relative paths}

## Project Domain Knowledge
{knowledge_context from Step 1.5}
```

On re-runs (round 2+), append two more sections (read from `round-{N-1}/synthesis.md` and `round-{N-1}/changes.md`):

```
## Prior Round Findings
{merged HIGH/MEDIUM finding_ids and anchors from prior rounds}

## Round N Changes
{disposition block from prior Step 4}
```

When the contract injection includes Prior/Changes blocks, agent job order shifts to verify-first: (a) verify each prior finding by `finding_id`, (b) call out rebuttals that don't hold, (c) check whether fixes introduced new issues, (d) only then look for net-new findings.

If gaps were resolved between attempts (Step 3 retry), append:

```
## Resolved Gaps
{the missing context that was fetched, formatted for that agent}
```

### Await protocol

After emitting both calls, the loop driver MUST NOT proceed to Step 3 until both agents have returned. Use the harness's task-completion notifications (no polling). Emit at most one status line in the wait window.

On agent error or timeout: retry once with the same prompt. If both retries fail, mark the round aborted in `manifest.json` and stop. **Do not synthesize a one-agent verdict** — the cross-agent conflict check is load-bearing.

Do not re-embed agent-definition content in the prompt.

---

## Step 3: Synthesize Results

Each agent uses its own verdict enum — map them into the final report's enum:

| Agent | Positive | Concerning | Fundamental issue |
|---|---|---|---|
| `architectural-reviewer` | ✅ PASS | ⚠️ CONCERNS | ❌ RETHINK |
| `root-cause-reviewer` | ✅ SYSTEMATIC | ⚠️ PARTIAL FIX | ❌ PATCH-ONLY |
| Final `Overall Verdict` | PASS | REVISE | RETHINK |

After both agents complete:

### 3.0 Persistence

Write `round-N/architectural.md` and `round-N/root-cause.md` (verbatim agent returns). If a retry happens (3.1 below), overwrite with the retry output and note the prior attempt in `synthesis.md`. Failures after retry abort the round.

### 3.1 INSUFFICIENT CONTEXT gate (pre-verdict)

Count `INSUFFICIENT CONTEXT` dimensions across both agents.

- If the gap is **closable** (file path / ticket / grep pattern reachable from the orchestrator): fetch the missing context (`Read` the file, `WebFetch` the ticket, run the grep), then re-launch **only the affected agent** with an extra `## Resolved Gaps` block. Cap at 1 retry per round. After retry, re-run 3.0 and re-evaluate the gate.
- If the gap is **non-closable** OR remains unresolved after retry: verdict is capped at `REVISE` regardless of finding count. Cannot `PASS` with unresolved gaps. The "Insufficient Context Areas" section in the report becomes a top-level callout, not a footnote.

### 3.2 Finding-id computation (deterministic)

For each Finding Anchor emitted by either agent:

```
defect_slug   = lowercase(defect_class).replace(' ', '-')
hash_input    = file + "|" + summary
finding_id    = "<agent>-<defect_slug>-" + sha1(hash_input)[:8]
finding_label = file + ":" + line     # human-readable; allowed to drift
```

Where `<agent>` is `arch` or `rca`. Store `{finding_id → {anchor, label, confidence, severity}}` in `manifest.json` for the current round.

### 3.3 Merge / dedupe / prioritize

1. Collect both verdicts and confidence levels.
2. **Discard `[UNVERIFIED]` and `[LOW]` findings** unless they represent a potentially critical concern worth flagging.
3. Merge overlapping concerns by anchor similarity (same `file` + same `defect_class`, or matching `finding_id`). When merging, list both source `finding_id`s.
4. Prioritize by severity × confidence: `[HIGH]` blockers first, then `[MEDIUM]`.
5. **Detect cross-agent conflicts** — if architectural-reviewer says "good abstraction" but root-cause-reviewer says "over-abstraction hides the root cause", surface this explicitly with both sides cited.
6. **False Consensus Check** — if both agents reached positive verdicts (PASS + SYSTEMATIC) AND neither has any `[MEDIUM]+` concerns:
   - Note: "Both agents agree this is clean. Applying extra scrutiny."
   - Re-examine the 3 highest-risk areas of the diff/plan for anything both agents may have normalized or overlooked.
   - If something is found, add it as a new finding with tag `[CONSENSUS-BLIND-SPOT]`.
   - Otherwise note: "False consensus check completed — agreement appears genuine."

### 3.4 Render the unified report

Write to `round-N/synthesis.md` and present:

```
## Challenge Report — Round N

### Architectural Fitness: {verdict}
{[HIGH] and [MEDIUM] findings only, with finding_label and evidence citations}

### Systematic Resolution: {verdict}
{[HIGH] and [MEDIUM] findings only, with causal chains}

### Cross-Agent Conflicts
{any disagreements between the two reviewers — both sides explicit}

### False Consensus Check
{result — "N/A" if agents disagreed}

### What the Changes Do Well
{consolidated strengths from both agents}

### Action Items
1. ❌ [HIGH] {finding_label} — {finding_id} — {description} — {suggestion}
2. ⚠️ [MEDIUM] {finding_label} — {finding_id} — {description} — {suggestion}
...

### Skill Compliance
{findings against project skills / CLAUDE.md rules — "N/A" if none}

### Insufficient Context Areas
{dimensions either agent could not assess — top-level callout if any remain after retry}

### Overall Verdict: {PASS | REVISE | RETHINK}
- PASS: no [HIGH] AND no [MEDIUM] concerns
- REVISE: one or more [MEDIUM]+ concerns with clear fix paths
- RETHINK: any [HIGH] concern indicating fundamental issue

(Verdict capped at REVISE if any unresolved INSUFFICIENT CONTEXT — see 3.1.)
```

---

## Step 4: Critically Address Findings (Round N)

Branch on `mode` from Step 1.0. No later step re-checks mode.

### 4a. Implementer mode

Treat the Step 3 report as a hostile audit, not a list of suggestions. Default disposition is "the reviewer is right" — flip that only with evidence.

For every `[HIGH]` and `[MEDIUM]` finding (including `[CONSENSUS-BLIND-SPOT]`), pick exactly one of four dispositions:

1. **Fix** — modify the plan or diff so the finding no longer applies. State what changed and where (`file:line` for impl, plan section for plan mode).
2. **Rebut (cite)** — explain why the finding is wrong, with concrete evidence: file references, prior decisions in git history, constraints the reviewer didn't see, or domain rules from Step 1.5. A rebuttal without citable evidence does not count — convert to Fix.
3. **Rebut (judgment)** — eligible only when EITHER the original reviewer's finding `Classification` is `Tradeoff Point` OR the concern's scope is naming / style / local readability. Requires:
   - Explicit tradeoff statement (`accepting X cost for Y benefit`)
   - Acknowledgment of the reviewer's point as legitimate before overriding
   - On a `[HIGH]` JUDGMENT rebuttal: sibling-instance check — grep for other places the same judgment was made; document the consistency.
   - There is no fixed percentage cap; misuse is caught by the next round's reviewer pass (see Step 5).
4. **Defer** — the finding is real but genuinely out of scope. Requires a follow-up reference (ticket, task, or `/schedule` agent). "Out of scope" is not a synonym for "hard."

Hard rules:
- Do NOT silently drop findings.
- Do NOT mark a finding "addressed" by restating the same approach the reviewer flagged in different words.
- Cross-agent conflicts from Step 3 must be resolved (pick a side with evidence) before proceeding.

Produce a **Round N Changes** block (write to `round-N/changes.md`):

```
### Round N Changes
- F1 [HIGH] {finding_id} — {one-line finding}: FIXED — {what changed, where}
- F2 [MEDIUM] {finding_id} — {one-line finding}: REBUTTED-CITE — {evidence: file:line / git ref / domain rule}
- F3 [MEDIUM] {finding_id} — {one-line finding}: REBUTTED-JUDGMENT — {tradeoff: accepting X for Y; siblings: ...}
- F4 [MEDIUM] {finding_id} — {one-line finding}: DEFERRED — {ticket / follow-up reference}
```

Append dispositions to `manifest.json`.

### 4b. Review-only mode

Skip Fix/Rebut/Defer entirely. The caller is not the implementer — they leave comments.

Render every `[HIGH]` and `[MEDIUM]` finding as a PR-review comment in `round-N/pr-review-comments.md`:

```
**[HIGH]** {file}:{line} — {description}

{suggestion, including code snippet if available}

<!-- finding_id: {finding_id} -->
---
```

Mark the round `terminal: true` in `manifest.json`. Skip Step 5 entirely; jump to Step 6.

---

## Step 5: Re-Challenge Loop (implementer mode only)

Re-run the challenge to verify changes hold. Keep looping until the plan/impl would pass a fresh round with no new HIGH/MEDIUM findings. Skipped in review-only mode.

1. **Increment round**: `mkdir -p <artifact_dir>/round-{N+1}`. Re-launch both reviewers (Step 2) with the contract injection PLUS:

   ```
   ## Prior Round Findings
   {merged HIGH/MEDIUM finding_ids and anchors from all prior rounds — read from manifest}

   ## Round N Changes
   {Round N Changes block read from round-{N}/changes.md}
   ```

   The reviewers' verify-first behavior is enabled by these sections (see Step 2).

2. **Disposition rule enforcement**: instruct both reviewers to flag `[HIGH] Disposition rule violation` for any of:
   - `REBUTTED-JUDGMENT` used outside the eligibility filter (not a Tradeoff Point AND not naming/style/local readability).
   - `REBUTTED-JUDGMENT` of a `[HIGH]` without a documented sibling-instance check.
   - `DEFERRED` without a follow-up reference.

3. **Re-synthesize** (Step 3) to produce a Round N+1 report. Persist artifacts.

4. **Termination check** — exit the loop when ANY of:
   - **Overall Verdict = PASS** → go to Step 6.
   - **Round 3 reached** without PASS → exit, transition to Step 6 with escalation. Do not silently continue past round 3.
   - **Diminishing returns** (finding_id keyed):
     - ≥60% of round-{N+1} `[HIGH]/[MEDIUM]` finding_ids appeared in round-N, OR
     - any `finding_id` marked FIXED in `round-{N}/changes.md` reappears in `round-{N+1}/synthesis.md`.
     This signals the design is incompatible with the constraints — exit and surface honestly rather than grind further.

   Otherwise (new or remaining HIGH/MEDIUM findings, fixable) → return to Step 4 as Round N+1.

Each round MUST produce a Round N Changes block, even if it consists only of rebuttals. Track round-over-round verdict progression (e.g., `RETHINK → REVISE → PASS`) in the manifest.

---

## Step 6: Final Report

Write `<artifact_dir>/final-report.md` and present.

### Salient escalation banner (implementer mode only)

If the loop exited at round 3 OR via diminishing returns, the **first line** of `final-report.md` MUST be:

```
🛑 HUMAN REVIEW REQUIRED — DO NOT MERGE WITHOUT MANUAL VERIFICATION
Reason: <round-3-cap | diminishing-returns>
Unresolved [HIGH]: N, Unresolved [MEDIUM]: M
```

`N` and `M` are derived from the manifest by counting findings whose latest disposition is **not** `FIXED`. Counts come from disposition tracking, not re-derived from finding_ids — decouples M6 from finding_id stability.

### Report body

- **Verdict progression**: `Round 1: {verdict} → Round 2: {verdict} → ...`
- **Final unified report** from the last round (Step 3 format).
- **Round Changes log**: all Round N Changes blocks in order — what was fixed, rebutted, deferred across iteration.
- **Deferred findings**: consolidated list with follow-up references.
- **Escalation notes** (only if escalated): why convergence didn't happen and what the user should decide.
- **Artifact directory**: print `<artifact_dir>` so the user can re-open the trail.

### Terminal action

Use `AskUserQuestion`. Options vary by mode and escalation:

- **implementer + non-escalated PASS**: `proceed` / `manual review` / `roll back`.
- **implementer + escalated**: `manual review` / `roll back` / `accept risk and proceed (explicit confirmation required)`. No silent default.
- **review-only**: `post comments via Bitbucket MCP` / `copy to clipboard` / `done`.
