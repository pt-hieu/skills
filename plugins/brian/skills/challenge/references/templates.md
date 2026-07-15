# Render Templates — chat synthesis, dispositions, final report

Read this when rendering the compact chat synthesis (Step 3.3b), recording dispositions or PR comments (Step 4), or emitting the final report (Step 6). Use these blocks verbatim; project from the merged finding list — do NOT re-derive fields.

## Step 3.3b — Compact chat synthesis

Runs after the verbose synthesis (3.3a) is appended to the run file. Don't dump JSON, don't write `N/A` for empty sections, don't repeat agent paragraphs verbatim — condense.

```
## Challenge Report — Round N — {VERDICT}{ — confidence: {HIGHER|LOWER}}
arch: {✅|⚠️|❌}  rca: {✅|⚠️|❌}{  facts: {✅|⚠️|❌}}{  {lens}: {✅|⚠️|❌}}  ·  {H} HIGH, {M} MEDIUM  ·  artifact: <run_file>

### Findings
- ❌ HIGH {arch|rca|both} {file:line} — {one-sentence issue, cite skill name inline if a skill rule is violated}. Fix: {one-sentence fix}.
- ⚠️ MEDIUM ...

### Conflicts (omit section if none)
- {one-line: both sides cited}

### Strengths (omit section if none, max 3 consolidated bullets)
- {one-line strength}

### Insufficient Context (omit section if none)
- {dimension → what's missing in one line}

(if any low-confidence/unverified findings dropped that aren't critical-flagged or consensus-blind-spot:)
Dropped from chat: N low-confidence findings (see run file)
```

Hard rules:
- The `facts` mark renders in plan mode only; one extra mark per launched wildcard lens, named by the lens.
- Source prefix: `arch`, `rca`, `facts`, a lens name, or `both` (when merged across two sources).
- Skill Compliance: cite skill name inline in the issue sentence; no separate section.
- False Consensus / Debated Findings: no section header in chat — debated findings appear in Findings list with resolved severity; `[CONSENSUS-BLIND-SPOT]` findings appear in Findings like any other.
- Empty sections: omit header entirely (no `N/A`).
- Suppression escape hatch: drop low-confidence/unverified findings from chat UNLESS 3.2 marked it "critical concern worth flagging" OR the finding has tag `[CONSENSUS-BLIND-SPOT]`. Never silently drop those two classes.

## Step 4a — Implementer disposition render

The forensic record (multi-line dispositions allowed) lives in the run file; the chat render is one line per finding — **hard cap**.

Run file (`### Round N Changes` — multi-line allowed, appended under the current `## Round N` heading):

```
### Round N Changes
- HIGH {file:line} — {one-line finding}: FIXED — {what changed, where}
- MEDIUM {file:line} — {one-line finding}: REBUTTED-CITE — {evidence: file:line / git ref / domain rule}
- MEDIUM {file:line} — {one-line finding}: REBUTTED-JUDGMENT — {tradeoff: accepting X for Y; siblings: ...}
- MEDIUM {file:line} — {one-line finding}: DEFERRED — {ticket / follow-up reference}
- HIGH {file:line} — {one-line finding}: ESCALATED-CRUX — {the crux stated as a decision question}
```

(`ESCALATED-CRUX` triggers Step 5's crux branch — at most one per round; see `references/crux-round.md`.)

Chat render (one line per finding, hard cap — multi-line prose stays in the run file):

```
- [SEVERITY] {file:line}: {DISPOSITION} — {≤25-word reason}
```

## Step 4b — Review-only PR comments

Append `### PR Review Comments` to the run file with every high- and medium-severity finding as a verbose PR-review comment (includes code snippets):

```
### PR Review Comments

**HIGH** {file}:{line} — {description}

{suggestion, including code snippet if available}

---
**MEDIUM** {file}:{line} — {description}
...
```

Then render the compact chat view (mirrors 3.3b chat discipline — same defect class):

```
## PR Review Comments — N findings ready
- ❌ HIGH {file:line}: {one-sentence issue}
- ⚠️ MEDIUM {file:line}: {one-sentence issue}

Full comments with code snippets in: <run_file>
Use Bitbucket MCP to post, or copy from the file.
```

## Step 6 — Final report chat turn

The run file IS the final report. Chat emits a single turn:

```
## Challenge Complete — {VERDICT progression: R1 → R2 → R3}
arch: {✅|⚠️|❌}  rca: {✅|⚠️|❌}{  facts: {✅|⚠️|❌}}{  {lens}: {✅|⚠️|❌}}  ·  artifact: <run_file>
{escalation banner if round-3-cap or diminishing-returns or crux-retreat}
{crux recommendation line if a crux round ran}
{last round's compact synthesis (3.3b template)}
{last round's Round N Changes one-liners (4a chat-render format)}
{deferred findings inline if any}
```

When a crux round ran, render its decision as one line directly under the banner (or under the header when not escalated):

```
Crux: {question} → {chosen option} — accepting {tradeoff}. Would change on: {evidence-that-would-change-it}.
```

### Salient escalation banner (implementer mode only)

If the loop exited at round 3 OR via diminishing returns, prepend:

```
🛑 HUMAN REVIEW REQUIRED — DO NOT MERGE WITHOUT MANUAL VERIFICATION
Reason: <round-3-cap | diminishing-returns | crux-retreat>
Unresolved high-severity: N, Unresolved medium-severity: M
```

On `crux-retreat` (the crux round's red-team retreat case won), the crux recommendation line below the banner carries the retreat recommendation and its grounds — the user gets a decided recommendation, never a bare "review required".

`N` and `M` are the count of findings whose latest disposition is **not** `FIXED`, judged from the run file's `### Round N Changes` blocks.

### Escalated-overflow fallback

If the run is escalated AND the combined chat output would exceed roughly one screenful (~50 lines by visual eyeball, no countable cap), emit ONLY the escalation banner + verdict progression line + artifact path. The synthesis, disposition trail, and deferred list remain in the run file for the user to open.
