# Challenge — Execution Guide

Fire 2 independent opus subagents in parallel to stress-test a plan or implementation. Both agents challenge whether the changes keep the architecture healthy, expandable, and maintainable — and whether they fix root causes vs patch symptoms.

The reviewers are first-class plugin agents:
- `brian:architectural-reviewer` — coupling, cohesion, historical coherence, expandability
- `brian:root-cause-reviewer` — iterative-deepening RCA, defect class identification, sibling-instance search

Their system prompts live in `plugins/brian/agents/`. This skill orchestrates context assembly, parallel invocation, and synthesis. **The orchestrator owns the I/O contract** (Reuse Contract sections, Finding Anchor format, INSUFFICIENT CONTEXT semantics, defect-class enum, re-run sections). Agent files keep methodology, dimensions, examples, and per-agent verdict enums only.

> Scope: this skill intentionally violates the `prompting` skill's CRITICAL
> rule "Deterministic split — code computes all numbers; LLM interprets only".
> Rationale: the orchestrator is the sole consumer of any quantitative state
> here (no cross-process handoff). Verbal discipline + a human-readable run
> file is sufficient for single-process loops. The prompting rule still
> binds for any agent shipped for external consumers.

---

## Step 0: Run Setup

Compute a run file path and initialize it. Persistence survives compaction and gives every round a forensic trail.

```
run_file=/tmp/claude-challenge/$(date -u +%Y%m%dT%H%M%SZ)-$(openssl rand -hex 3).md
mkdir -p /tmp/claude-challenge
printf "# Challenge Run — $(date -u +%FT%TZ)\n- Mode: <implementer|review-only>\n- Target: <plan path | git ref>\n\n" > "$run_file"
```

Print `$run_file` so the user can re-open it later.

---

## Round Lifecycle

All round artifacts (context, agent returns, synthesis, dispositions) are appended to `$run_file` as `## Round N` subsections. No per-round directory; no separate files.

If a Step 3 retry fetches missing context, the re-launched agent's output replaces the prior `### Architectural Review` / `### Root-Cause Review` block under the current `## Round N` heading and the synthesis notes the prior attempt. If both agents fail twice, append `### Round N: ABORTED — both agents failed twice` to the run file and skip synthesis (see Step 2 Await protocol for the terminal disposition).

Re-runs (Step 5) read prior `### Synthesis` and `### Round N Changes` sections from the run file and inject them as `## Prior Round Findings` + `## Round N Changes` into the next round's Step 2 contract. Review-only mode never re-runs (no loop, no escalation banner).

---

## Step 1: Determine Challenge Target

Identify what to challenge:
- **Plan mode**: challenge the proposed approach before implementation.
- **Implementation mode**: challenge code that was just written or changed.

Gather context:
- If plan: read the plan content or task list verbatim into `## Context`.
- If implementation: capture `git diff <base-ref>...HEAD`. Note `<base-ref>` in the run file's header line.
- Identify affected files/modules — derive from `git diff --name-only` in impl mode; list explicitly in plan mode.

---

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

### Await protocol

After emitting both calls, the loop driver MUST NOT proceed to Step 3 until both agents have returned. Use the harness's task-completion notifications (no polling). Emit at most one status line in the wait window.

On agent error or timeout: retry once with the same prompt. If both retries fail, append `### Round N: ABORTED — both agents failed twice` to the run file. Skip Step 5; jump to Step 6 with `mode = aborted`: chat emits one-line abort + run-file path; AskUserQuestion offers retry / proceed without challenge / rollback. Do NOT silently terminate — the user must reach a terminal disposition. **Do not synthesize a one-agent verdict** — the cross-agent conflict check is load-bearing.

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

Append `### Architectural Review` and `### Root-Cause Review` subsections under the current `## Round N` heading. Wrap each verbatim agent return in a fenced markdown code block so the agent's own `##`/`###` headings stay inert in the run file's outline:

```
### Architectural Review
~~~markdown
{verbatim agent return}
~~~

### Root-Cause Review
~~~markdown
{verbatim agent return}
~~~
```

Use `~~~` (tilde) fences so any ` ``` ` triple-backtick code blocks inside the agent's output don't terminate the wrapper.

If a retry happens (3.1 below), replace the affected agent's block with the retry output and note the prior attempt in the synthesis. Failures after retry abort the round (see Step 2 Await protocol).

### 3.1 INSUFFICIENT CONTEXT gate (pre-verdict)

Count `INSUFFICIENT CONTEXT` dimensions across both agents.

- If the gap is **closable** (file path / ticket / grep pattern reachable from the orchestrator): fetch the missing context (`Read` the file, `WebFetch` the ticket, run the grep), then re-launch **only the affected agent** with an extra `## Resolved Gaps` block. Cap at 1 retry per round. After retry, re-run 3.0 and re-evaluate the gate.
- If the gap is **non-closable** OR remains unresolved after retry: verdict is capped at `REVISE` regardless of finding count. Cannot `PASS` with unresolved gaps. The "Insufficient Context Areas" section in the report becomes a top-level callout, not a footnote.

### 3.3 Merge / dedupe / prioritize

1. Collect both verdicts and confidence levels.
2. **Discard `[UNVERIFIED]` and `[LOW]` findings** unless they represent a potentially critical concern worth flagging.
3. Merge overlapping concerns by anchor similarity (same `file` + same `defect_class`). When merging, note both source agents.
4. Prioritize by severity × confidence: `[HIGH]` blockers first, then `[MEDIUM]`.
5. **Detect cross-agent conflicts** — if architectural-reviewer says "good abstraction" but root-cause-reviewer says "over-abstraction hides the root cause", surface this explicitly with both sides cited.
6. **False Consensus Check** — if both agents reached positive verdicts (PASS + SYSTEMATIC) AND neither has any `[MEDIUM]+` concerns:
   - Note: "Both agents agree this is clean. Applying extra scrutiny."
   - Re-examine the 3 highest-risk areas of the diff/plan for anything both agents may have normalized or overlooked.
   - If something is found, add it as a new finding with tag `[CONSENSUS-BLIND-SPOT]`.
   - Otherwise note: "False consensus check completed — agreement appears genuine."

The merged finding list is held verbally for the duration of one synthesis pass; that's all that's needed.

### 3.4 Render the unified report

Synthesis goes two places: appended verbatim to the run file (forensic), and rendered compactly in chat (user-facing). Don't dump JSON, don't write `N/A` for empty sections, don't repeat agent paragraphs verbatim — the orchestrator condenses.

3.4a runs only after 3.1 resolves (retries complete or aborted); 3.4b runs only after 3.4a is appended to the run file.

On the aborted-round path (both agents failed twice): skip both 3.4a and 3.4b; emit only one line to chat:

```
Round N: ABORTED — both agents failed twice. See <run_file>.
```

### 3.4a Persist verbose synthesis (run file)

Append `### Synthesis` under the current `## Round N` heading using the template below.

```
### Synthesis

#### Architectural Fitness: {verdict}
{[HIGH] and [MEDIUM] findings only, with file:line and evidence citations — drawn from architectural-reviewer's findings}

#### Systematic Resolution: {verdict}
{[HIGH] and [MEDIUM] findings only, with causal chains — drawn from root-cause-reviewer's findings}

#### Cross-Agent Conflicts
{any disagreements between the two reviewers — both sides explicit. Omit subsection if none.}

#### False Consensus Check
{result. Omit subsection if agents disagreed.}

#### What the Changes Do Well
{consolidated strengths from both agents. Omit subsection if none.}

#### Action Items
1. ❌ [HIGH] {file:line} — {one-sentence issue} — {one-sentence fix}
2. ⚠️ [MEDIUM] {file:line} — {one-sentence issue} — {one-sentence fix}
...

#### Skill Compliance
{findings against project skills / CLAUDE.md rules. Omit subsection if none.}

#### Insufficient Context Areas
{dimensions either agent could not assess — top-level callout if any remain after retry. Omit subsection if none.}

#### Overall Verdict: {PASS | REVISE | RETHINK}
- PASS: no [HIGH] AND no [MEDIUM] concerns
- REVISE: one or more [MEDIUM]+ concerns with clear fix paths
- RETHINK: any [HIGH] concern indicating fundamental issue

(Verdict capped at REVISE if any unresolved INSUFFICIENT CONTEXT — see 3.1.)
```

### 3.4b Render compact synthesis to chat

After 3.4a is appended, render the chat-channel template below. Project from the same merged finding list — fields are NOT re-derived.

```
## Challenge Report — Round N — {VERDICT}{ — confidence: {HIGHER|LOWER}}
arch: {✅|⚠️|❌}  rca: {✅|⚠️|❌}  ·  {H} HIGH, {M} MEDIUM  ·  artifact: <run_file>

### Findings
- ❌ [HIGH] {arch|rca|both} {file:line} — {one-sentence issue, cite skill name inline if a skill rule is violated}. Fix: {one-sentence fix}.
- ⚠️ [MEDIUM] ...

### Conflicts (omit section if none)
- {one-line: both sides cited}

### Strengths (omit section if none, max 3 consolidated bullets)
- {one-line strength}

### Insufficient Context (omit section if none)
- {dimension → what's missing in one line}

(if any [LOW]/[UNVERIFIED] dropped that aren't critical-flagged or consensus-blind-spot:)
Dropped from chat: N low-confidence findings (see run file)
```

Hard rules:
- Source prefix: `arch`, `rca`, or `both` (when merged).
- Skill Compliance: cite skill name inline in the issue sentence; no separate section.
- False Consensus / Debated Findings: no section header in chat — debated findings appear in Findings list with resolved severity; `[CONSENSUS-BLIND-SPOT]` findings appear in Findings like any other.
- Empty sections: omit header entirely (no `N/A`).
- Suppression escape hatch: drop `[LOW]/[UNVERIFIED]` from chat UNLESS 3.3 marked it "critical concern worth flagging" OR the finding has tag `[CONSENSUS-BLIND-SPOT]`. Never silently drop those two classes.

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

Append the **Round N Changes** block to the run file under the current `## Round N` heading. The forensic record (multi-line dispositions allowed) lives in the run file; the chat render is one line per finding — **hard cap**.

Run file (`### Round N Changes` — multi-line allowed):

```
### Round N Changes
- F1 [HIGH] {file:line} — {one-line finding}: FIXED — {what changed, where}
- F2 [MEDIUM] {file:line} — {one-line finding}: REBUTTED-CITE — {evidence: file:line / git ref / domain rule}
- F3 [MEDIUM] {file:line} — {one-line finding}: REBUTTED-JUDGMENT — {tradeoff: accepting X for Y; siblings: ...}
- F4 [MEDIUM] {file:line} — {one-line finding}: DEFERRED — {ticket / follow-up reference}
```

Chat render (one line per finding, hard cap):

```
- F{n} [SEVERITY] {file:line}: {DISPOSITION} — {≤25-word reason}
```

Multi-line disposition prose belongs in the run file only. The chat emits the one-liner.

### 4b. Review-only mode

Skip Fix/Rebut/Defer entirely. The caller is not the implementer — they leave comments.

Append `### PR Review Comments` to the run file with every `[HIGH]` and `[MEDIUM]` finding as a PR-review comment (verbose, includes code snippets):

```
### PR Review Comments

**[HIGH]** {file}:{line} — {description}

{suggestion, including code snippet if available}

---
**[MEDIUM]** {file}:{line} — {description}
...
```

Then render the compact chat view (mirrors 3.4b chat discipline — same defect class):

```
## PR Review Comments — N findings ready
- ❌ [HIGH] {file:line}: {one-sentence issue}
- ⚠️ [MEDIUM] {file:line}: {one-sentence issue}

Full comments with code snippets in: <run_file>
Use Bitbucket MCP to post, or copy from the file.
```

Append `### Review-only round — terminal` to the run file. Skip Step 5 entirely; jump to Step 6.

---

## Step 5: Re-Challenge Loop (implementer mode only)

Re-run the challenge to verify changes hold. Keep looping until the plan/impl would pass a fresh round with no new HIGH/MEDIUM findings. Skipped in review-only mode.

1. **Increment round**. Re-launch both reviewers (Step 2) with the contract injection PLUS:

   - `## Prior Round Findings`: concatenate the `### Synthesis` subsection from EVERY prior round in chronological order, separated by `--- Round K ---` markers. (Round 2 → R1's synthesis only; Round 3 → R1+R2 syntheses concatenated. Verbal duplication is acceptable; agents re-deduplicate.)
   - `## Round N Changes`: the most recent prior round's `### Round N Changes` subsection only.

   Section extraction: anchor on the `### Synthesis` and `### Round N Changes` H3 headings (NOT the `## Round N` H2 — agent returns are fenced per Step 3.0 but extraction grammar is keyed off our own H3 sentinels for safety). Read content from the H3 heading to the next H3 heading at the same level, or to EOF.

   The reviewers' verify-first behavior is enabled by these sections (see Step 2).

2. **Disposition rule enforcement**: instruct both reviewers to flag `[HIGH] Disposition rule violation` for any of:
   - `REBUTTED-JUDGMENT` used outside the eligibility filter (not a Tradeoff Point AND not naming/style/local readability).
   - `REBUTTED-JUDGMENT` of a `[HIGH]` without a documented sibling-instance check.
   - `DEFERRED` without a follow-up reference.

3. **Re-synthesize** (Step 3) to produce a Round N+1 report. Append artifacts to the run file.

4. **Termination check** — exit the loop when ANY of:
   - **Overall Verdict = PASS** → go to Step 6.
   - **Round 3 reached** without PASS → exit, transition to Step 6 with escalation. Do not silently continue past round 3.
   - **Diminishing returns**: the orchestrator reads the prior round's findings and, if findings rhyme across rounds (same file/defect-class re-surfacing by similar prose, or any finding marked FIXED in the prior `### Round N Changes` reappears in the new `### Synthesis`), exits and surfaces honestly rather than grinding further.

   Otherwise (new or remaining HIGH/MEDIUM findings, fixable) → return to Step 4 as Round N+1.

Each round MUST produce a Round N Changes block, even if it consists only of rebuttals. Track round-over-round verdict progression (e.g., `RETHINK → REVISE → PASS`) verbally for Step 6.

---

## Step 6: Final Report

The run file IS the final report. Chat emits a single turn:

```
## Challenge Complete — {VERDICT progression: R1 → R2 → R3}
arch: {✅|⚠️|❌}  rca: {✅|⚠️|❌}  ·  artifact: <run_file>
{escalation banner if round-3-cap or diminishing-returns}
{last round's compact synthesis (3.4b template)}
{last round's Round N Changes one-liners (4a chat-render format)}
{deferred findings inline if any}
```

### Salient escalation banner (implementer mode only)

If the loop exited at round 3 OR via diminishing returns, prepend:

```
🛑 HUMAN REVIEW REQUIRED — DO NOT MERGE WITHOUT MANUAL VERIFICATION
Reason: <round-3-cap | diminishing-returns>
Unresolved [HIGH]: N, Unresolved [MEDIUM]: M
```

`N` and `M` are the count of findings whose latest disposition is **not** `FIXED`, judged from the run file's `### Round N Changes` blocks.

### Escalated-overflow fallback

If the run is escalated AND the combined chat output would exceed roughly one screenful (~50 lines by visual eyeball, no countable cap), emit ONLY the escalation banner + verdict progression line + artifact path. The synthesis, disposition trail, and deferred list remain in the run file for the user to open.

### Terminal action

Use `AskUserQuestion`. Options vary by mode and escalation:

- **implementer + non-escalated PASS**: `proceed` / `manual review` / `roll back`.
- **implementer + escalated**: `manual review` / `roll back` / `accept risk and proceed (explicit confirmation required)`. No silent default.
- **review-only**: `post comments via Bitbucket MCP` / `copy to clipboard` / `done`.
- **aborted** (both agents failed twice): `retry challenge` / `proceed without challenge` / `roll back`.
