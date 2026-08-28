---
name: challenge
description: "Use before finalizing a significant plan, after complex implementation changes, before PRs touching core architecture, or when uncertain whether a solution is systematic enough."
---

# Challenge

Fire independent opus subagents in parallel to stress-test a plan or implementation. The panel challenges whether the changes keep the architecture healthy, expandable, and maintainable — whether they fix root causes vs patch symptoms — and, in plan mode, whether the plan's own factual claims and critical premises actually hold.

The two fixed reviewers are first-class plugin agents, launched on every run:
- `brian:architectural-reviewer` — coupling, cohesion, module depth, historical coherence, expandability, side effects
- `brian:root-cause-reviewer` — iterative-deepening RCA, defect class identification, sibling-instance search

Plan mode adds a third fixed agent:
- `brian:plan-fact-checker` — verifies every file:line, count, path, and version claim the plan makes against the actual repo and installed toolchain

The panel may also gain one **bespoke critic** — an adversary the orchestrator writes for this particular target, aimed at whichever aspect most deserves depth. Step 2 owns that judgment in full; `references/bespoke-critic.md` carries the authoring guidance, invocation shape, and two worked derivations, opened once the aspect is named.

The fixed reviewers' and fact-checker's system prompts live in `plugins/brian/agents/`; the bespoke critic is authored at runtime under this skill's `references/`. This skill orchestrates context assembly, parallel invocation, synthesis, and the hand-off to the user. **The orchestrator owns the I/O contract** (Output Contract sections, Finding Anchor format, INSUFFICIENT CONTEXT semantics, Premise Audit section). Agent files keep methodology, dimensions, examples, and their per-agent closing-judgment keywords only.

This skill deliberately holds quantitative state verbally (deviating from the `prompting` skill's deterministic-split rule) — the rationale and the one concrete formula it defends live together in `references/domain-harvest.md`.

## Step 0: Run Setup

Compute a run file path and initialize it. Persistence survives compaction and gives the run a forensic trail.

```
run_file=/tmp/claude-challenge/$(date -u +%Y%m%dT%H%M%SZ)-$(openssl rand -hex 3).md
mkdir -p /tmp/claude-challenge
printf "# Challenge Run — $(date -u +%FT%TZ)\n- Mode: <implementer|review-only>\n- Target: <plan path | git ref>\n\n" > "$run_file"
{ printf "## Working-Tree Snapshot (Step 0)\n~~~\n"; git status --porcelain; printf "~~~\n\n"; } >> "$run_file"
```

The snapshot is the baseline for Step 5's working-tree hygiene check (experiment leftovers show up as paths new since Step 0).

Print `$run_file` so the user can re-open it later. All artifacts append to it — for the persistence mechanics and section shapes, read `references/run-file-mechanics.md` (needed at every persistence point).

## Step 1: Determine Challenge Target

Identify what to challenge:
- **Plan mode**: challenge the proposed approach before implementation.
- **Implementation mode**: challenge code that was just written or changed.

Gather context:
- If plan: read the plan content or task list verbatim into `## Context`.
- If implementation: capture `git diff <base-ref>...HEAD`. Note `<base-ref>` in the run file's header line.
- Identify affected files/modules — derive from `git diff --name-only` in impl mode; list explicitly in plan mode.

## Step 1.0: Caller Disposition

Determine whether the caller is the implementer (can act on the user's directions directly) or a reviewer (whose output is PR comments). Note the mode in the run file's header line — human-facing only. Mode is bound in the orchestrator's working memory at Step 1.0; later steps NEVER re-parse the header line to re-derive mode.

**Detection signals**:
- Implementer: working tree has uncommitted changes; HEAD ahead of origin on a non-default branch; user phrasing such as "my plan", "before I push", "I just changed".
- Review-only: diff comes from `gh pr diff` or `git fetch origin pull/<N>/head`; clean working tree on a checked-out PR branch; phrasing like "review this PR", "audit X's branch".

**Default on ambiguity**: review-only (writing comments is reversible; editing someone else's code is not). When the caller is interactive, ask once in plain text; otherwise default.

Mode changes only what Step 5 does with the user's directions — implementer edits the plan or code, review-only turns each direction into a PR comment. Step 4 is identical in both modes.

## Step 1.5: Domain Knowledge Harvest

Before Step 2, run the 5-stage Domain Knowledge Harvest to produce `{knowledge_context}` — read and execute `references/domain-harvest.md` (it also carries the relevance-formula deviation rationale).

## Step 2: Launch the Reviewer Panel in Parallel

Compose the panel:

- **Always**: `brian:architectural-reviewer` and `brian:root-cause-reviewer`, each with `model: "opus"`.
- **Plan mode**: add `brian:plan-fact-checker` with `model: "sonnet"` (claim verification is mechanical exploration; reserve opus for the judgment-heavy reviewers).
- **Bespoke critic** (0–1): decide with the gate below.

### Bespoke-critic gate

The standing panel buys breadth. This slot buys depth on one aspect of *this* target, and you write the critic — so its subject is whatever the target puts at risk, named in your own words rather than drawn from a list.

Ask one question: **which critical aspect of this target will the standing panel only skim, where being wrong is expensive?**

Launching wants both prongs, and the run file records them:

- **Quoted** — the target's own text that makes the aspect critical. A claim you inferred from the repo's shape rather than read in the target belongs to the standing panel; repo shape is a constant across every run and so tells you nothing about this one.
- **Uncovered** — one line on why architectural review, root-cause analysis, and (in plan mode) claim-checking will each only skim it. Generic depth is what those three already sell; the aspect earns its critic by being one they pass over.

Write the record line before opening any reference — naming the aspect is the decision, and it happens in your words, not against a menu:

```
Bespoke critic: none — {one-line reason}
Bespoke critic: {aspect} — {quote from the target} — {why the standing panel only skims it}
```

With the aspect recorded, read `references/bespoke-critic.md` to author the critic's prompt and launch it.

### Emission

Once the panel is composed, all calls MUST be emitted as **tool-use blocks in the same assistant message** so they run concurrently, each with `run_in_background: true`.

The orchestrator-injected contract goes into the user-turn `prompt` field. Identical for every panel agent:

```
## Output Contract

Every finding MUST start with a structured Finding Anchor on its own line:

  Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>

Name the defect class in plain words — a short phrase describing the underlying defect (e.g. "missing validation — external input to a DB query"), not a label from a fixed list. Keep the `defect_class` field on every anchor: synthesis merges findings by `(file, defect_class)`, so the phrase is critical.

Confidence: state each finding's confidence and its basis in plain prose within the finding body (high when you verified it against cited code; low when it rests mostly on the diff). Do not append a tag.

For every finding, also state what the target itself proposes at that spot (quote or cite it) and what the realistic alternatives are — the orchestrator turns your finding into a decision the user makes, and a finding with no alternatives named forces the orchestrator to invent them.

Abstinence rule (INSUFFICIENT CONTEXT): if you cannot assess a dimension with the provided data, output `INSUFFICIENT CONTEXT — [what's missing, what you'd need to read/verify]` for that dimension and move on. Do NOT speculate.

## Context
{plan text OR git diff}

## Affected Files
{list of repo-relative paths}

## Project Domain Knowledge
{knowledge_context from Step 1.5}
```

**In plan mode**, append the `## Premise Audit` section to every panel agent's contract — read `references/premise-audit.md` for the block to inject and its rationale.

If gaps were resolved between attempts (Step 3.1 retry), append:

```
## Resolved Gaps
{the missing context that was fetched, formatted for that agent}
```

Do not re-embed agent-definition content in the prompt.

**Before deleting or renaming any Output Contract field**, run the Contract Audit in `references/contract-audit.md` first — it greps every copy of the contract (reviewer agents plus sibling skills) so a token rename touches them all in the same commit.

### Await protocol

After emitting the calls, the loop driver MUST NOT proceed to Step 3 until every launched agent has returned. Use the harness's task-completion notifications (no polling). Emit at most one status line in the wait window.

On agent error or timeout: retry once with the same prompt. Failure handling splits by agent class:

- **Fixed reviewers** (`architectural-reviewer`, `root-cause-reviewer`): if both fail twice, append `## ABORTED — both fixed reviewers failed twice` to the run file. Skip Steps 3 and 4; chat emits one-line abort + run-file path, then asks in plain text: retry / proceed without challenge / roll back. Do NOT silently terminate — the user must reach a terminal disposition. **Do not synthesize a one-agent verdict** — the cross-agent conflict check between the two fixed reviewers is critical.
- **Auxiliary agents** (`plan-fact-checker`, the bespoke critic): a twice-failed auxiliary agent degrades the run instead of aborting it — append `## {agent}: FAILED — degraded run` to the run file, note the gap in the synthesis's Insufficient Context Areas, and cap the verdict at `REVISE` (an unverified claims inventory is an unresolved gap, same as Step 3.1).

## Step 3: Synthesize Results

Each agent closes with a plain-language judgment sentence containing exactly one named keyword. Read that keyword — do not infer a verdict from the overall tone — and map it onto the report's verdict:

| Agent | Keyword in its closing sentence | Positive | Concerning | Fundamental issue |
|---|---|---|---|---|
| `architectural-reviewer` | `pass` / `concerns` / `rethink` | pass | concerns | rethink |
| `root-cause-reviewer` | `systematic` / `partial` / `patch-only` | systematic | partial | patch-only |
| `plan-fact-checker` (plan mode) | `accurate` / `discrepancies` / `unsound` | accurate | discrepancies | unsound |
| bespoke critic (when launched) | `pass` / `concerns` / `rethink` | pass | concerns | rethink |
| Final `Overall Verdict` | (orchestrator-owned) | PASS | REVISE | RETHINK |

A positive-column keyword contributes a PASS-leaning signal, a concerning-column keyword a REVISE-leaning signal, and a fundamental-issue keyword a RETHINK-leaning signal; combining across the whole panel, the worst signal governs the verdict. The verdict describes how much of the target is in question — it does not decide anything, because Step 4 hands every decision to the user.

After all panel agents complete:

### 3.0 Persist agent returns

Append `## Architectural Review` and `## Root-Cause Review` verbatim to the run file, tilde-fenced — plus `## Fact Check` in plan mode and `## Bespoke Critic — {aspect}` when one launched. Full mechanics in `references/run-file-mechanics.md`.

### 3.1 INSUFFICIENT CONTEXT gate (pre-verdict)

Count `INSUFFICIENT CONTEXT` dimensions across all panel agents.

- If the gap is **closable** (file path / ticket / grep pattern reachable from the orchestrator): fetch the missing context (`Read` the file, `WebFetch` the ticket, run the grep), then re-launch **only the affected agent** with an extra `## Resolved Gaps` block. Cap at 1 retry. After retry, re-run 3.0 and re-evaluate the gate.
- If the gap is **non-closable** OR remains unresolved after retry: verdict is capped at `REVISE` regardless of finding count. Cannot `PASS` with unresolved gaps. Surface the gap to the user in Step 4 as its own tension — an unassessed dimension is a decision the user should make knowingly, not a footnote.

### 3.2 Merge / dedupe / prioritize

1. Collect every panel agent's closing keyword and read each finding's confidence from its prose.
2. Merge overlapping concerns by anchor similarity: same `file` AND the same underlying `defect_class`. `defect_class` is a plain-words phrase, so judge sameness by *meaning* — two findings on the same file are the same finding only when they describe the same underlying defect class. A structural issue and a missing test on the same file are distinct defect classes; do NOT merge them (this preserves the non-collapse guarantee). When merging genuine duplicates, note both source agents.
3. Prioritize by severity × confidence, both judged from the prose: high-severity blockers first, then medium.
4. **Detect cross-agent conflicts** — if architectural-reviewer says "good abstraction" but root-cause-reviewer says "over-abstraction hides the root cause", carry the conflict forward as its own tension in Step 4 with both sides cited. The orchestrator does NOT pick a side.
5. **False Consensus Check** — if every panel agent closed positive (all positive-column keywords) AND none raised any concern they described as medium-or-higher severity:
   - Note: "The whole panel agrees this is clean. Applying extra scrutiny."
   - Re-examine the 3 highest-risk areas of the diff/plan for anything the panel may have normalized or overlooked.
   - If something is found, add it as a new finding with tag `[CONSENSUS-BLIND-SPOT]`.
   - Otherwise note: "False consensus check completed — agreement appears genuine."

The merged finding list is held verbally through Step 4; that's all that's needed.

### 3.3 Persist the synthesis

Append `## Synthesis` to the run file using the template in `references/run-file-mechanics.md`. There is no separate compact chat synthesis — Step 4's tension list is the chat render, and it projects from the same merged finding list (fields are NOT re-derived).

On the aborted path (both fixed reviewers failed twice): skip 3.3 and Step 4; emit only `Challenge ABORTED — both fixed reviewers failed twice. See <run_file>.`

## Step 4: Surface Every Tension to the User

This step is the point of the skill. The orchestrator does not fix, rebut, defer, or accept anything on its own. It converts each surviving concern into a decision the user makes.

**What becomes a tension**: every high- and medium-severity finding from the merged list (including `[CONSENSUS-BLIND-SPOT]` findings), every cross-agent conflict, and every unresolved INSUFFICIENT CONTEXT gap. Low-confidence findings that no agent tied to a concrete risk do not get a block — list them as one-liners under `Also raised` so nothing is silently dropped.

Render one status line, then one block per tension — this shape is canonical and lives nowhere else:

```
## Challenge — {VERDICT} · arch: {✅|⚠️|❌} rca: {✅|⚠️|❌}{ facts: {✅|⚠️|❌}}{ critic: {✅|⚠️|❌}} · {N} tensions · artifact: <run_file>

### {N}. {short title}
➡️ {what the target proposes here — quote the plan section or cite file:line}
🛑 {the tension — what breaks, who raised it (arch / rca / facts / critic), and how sure they are}
？ {Option A — …} / {Option B — …} / {Option C — …} → Recommend {letter}: {one-sentence why}

Also raised (no decision needed unless you want one):
- {low-confidence finding, one line} — {source}

Strengths: {max 2 lines, omit if none}
```

Hard rules:

- Each block gets at least two genuine options. "Leave it as proposed and accept the risk" is a legitimate option — name its cost when you offer it.
- A recommendation is mandatory on every block. Options without a pick push the work back onto the user, which is the opposite of what this step is for.
- Recommend against the target when the evidence says so. The recommendation is your judgment, not a summary of what the plan already says.
- Keep each of the three lines to one or two sentences. Depth lives in the run file, not the chat turn.
- On a cross-agent conflict the options are the two reviewers' positions; the recommendation picks one and cites the evidence that decides it.
- Never move a finding into `Also raised` to shorten the list. That line is for low-confidence findings with no concrete risk attached, and nothing else. If the turn runs long, cut strengths and `Also raised` — the decisions are the payload.
- The `facts` mark renders in plan mode only, the `critic` mark when a bespoke critic launched; both map straight off Step 3's keyword table. Source attribution and any violated skill name go in the 🛑 line, never a separate section or prefix.
- `[CONSENSUS-BLIND-SPOT]` findings render as ordinary blocks — keep the tag in the title so the user sees where it came from.
- Omit an empty section's header entirely; never write `N/A`.

If the panel surfaced nothing worth a decision, say so in one line, note the strengths in two at most, and go straight to Step 5.

Append the rendered tension list verbatim to the run file as `## Tensions`, then close the turn and wait. Do not start applying anything until the user answers.

## Step 5: Apply Directions and Close

The user replies with a direction per tension — possibly a different one from what you recommended, possibly an option you did not offer. Take it as given; do not re-argue a decision the user has made.

For each tension, in order:

- **Implementer mode**: make the change the direction calls for — edit the plan section or the code. State what changed and where (plan section, or `file:line`).
- **Review-only mode**: turn the direction into a PR review comment. Append the verbose comments (with code snippets) to the run file as `## PR Review Comments` per `references/templates.md`, then offer to post via Bitbucket MCP or copy to clipboard.

A direction that leaves something unfixed on purpose still gets recorded — write it down with the reason the user gave, so the run file shows the decision rather than an omission.

Append `## Directions Applied` to the run file (one entry per tension: the direction taken, and what it changed), then emit the closing chat turn per `references/templates.md`.

### Working-tree hygiene check (plan mode, before the closing turn)

Panel agents that ran premise-audit experiments were instructed to work in the scratchpad only. Verify: run `git status --porcelain` and compare against the same snapshot captured at Step 0. Any path new since Step 0 is an experiment leftover — remove it after confirming it matches experiment artifacts (paths that already existed at Step 0 stay untouched), and note the cleanup in the run file.
