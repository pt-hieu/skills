---
name: challenge
description: "Use before finalizing a significant plan, after complex implementation changes, before PRs touching core architecture, or when uncertain whether a solution is systematic enough."
---

# Challenge

`challenge` puts a plan or an implementation in front of a panel of independent reviewers and turns every concern that survives into a **tension**: a decision the user makes, with options and a recommendation. The orchestrator fixes, rebuts, defers, and accepts nothing on its own.

The panel challenges whether the changes keep the architecture healthy, expandable, and maintainable, whether they fix root causes or patch symptoms, and, for a plan, whether its factual claims and critical premises hold.

## The result

- **Every tension is in front of the user** in one chat turn, in the shape under "Tensions", and the turn closes there. Nothing is applied until the user answers.
- **Every direction the user gives is applied as given**, including one that differs from your recommendation or that you did not offer. A decision the user has made is not re-argued.
  - *Implementer*: the plan section or the code is changed, and you state what changed and where (plan section, or `file:line`).
  - *Review-only*: each direction becomes a PR review comment, written to the run file per `references/templates.md`, with an offer to post via Bitbucket MCP or copy to clipboard.
  - A direction that leaves something unfixed on purpose is recorded with the reason the user gave, so the run file shows a decision and not an omission.
- **The run file holds the whole trail**: the working-tree snapshot, each reviewer's verbatim return, the synthesis, the tensions as rendered, and the directions applied. Persistence survives compaction. `references/run-file-mechanics.md` has the section shapes; read it before the first append.
- **The closing chat turn** follows `references/templates.md`.

The run file is created before anything else, and its path is printed so the user can re-open it:

```
run_file=/tmp/claude-challenge/$(date -u +%Y%m%dT%H%M%SZ)-$(openssl rand -hex 3).md
mkdir -p /tmp/claude-challenge
printf "# Challenge Run — $(date -u +%FT%TZ)\n- Mode: <implementer|review-only>\n- Target: <plan path | git ref>\n\n" > "$run_file"
{ printf "## Working-Tree Snapshot\n~~~\n"; git status --porcelain; printf "~~~\n\n"; } >> "$run_file"
```

## Target and caller

**Target.** A plan is challenged before implementation: its text or task list goes into `## Context` verbatim, and the affected files are listed explicitly. An implementation is challenged as `git diff <base-ref>...HEAD`, with `<base-ref>` noted in the run file's header and the affected files taken from `git diff --name-only`.

**Caller.** The caller is the implementer, who can act on the user's directions directly, or a reviewer, whose output is PR comments. The mode changes only what happens to the directions; the tensions are the same in both. Decide it once, note it in the run file's header for the human reader, and hold it in working memory for the rest of the run.

- Implementer signals: the working tree has uncommitted changes; HEAD is ahead of origin on a non-default branch; phrasing such as "my plan", "before I push", "I just changed".
- Review-only signals: the diff comes from `gh pr diff` or `git fetch origin pull/<N>/head`; a clean working tree on a checked-out PR branch; phrasing like "review this PR", "audit X's branch".
- When the signals are ambiguous, the mode is review-only, because writing comments is reversible and editing someone else's code is not. An interactive caller is asked once in plain text.

## The panel

All panel agents are launched as tool-use blocks in one assistant message, each with `run_in_background: true`, so they run concurrently. Synthesis waits for every one of them to return.

- `brian:architectural-reviewer`, `model: "opus"`, on every run: coupling, cohesion, module depth, historical coherence, expandability, side effects.
- `brian:root-cause-reviewer`, `model: "opus"`, on every run: iterative-deepening RCA, defect class identification, sibling-instance search.
- `brian:plan-fact-checker`, `model: "sonnet"`, for a plan: verifies every file:line, count, path, and version claim against the repo and the installed toolchain. Claim verification is mechanical exploration, and opus is kept for the judgment-heavy reviewers.
- **A bespoke critic**, at most one, written for this target.

The fixed agents' system prompts live in `plugins/brian/agents/` and hold their methodology, dimensions, examples, and closing keywords. This skill owns the I/O contract: the Output Contract sections, the Finding Anchor format, the INSUFFICIENT CONTEXT semantics, and the Premise Audit section.

### The bespoke critic

The standing panel buys breadth. This slot buys depth on one aspect of *this* target, and you write the critic, so its subject is whatever the target puts at risk, named in your own words and not drawn from a list. The question that decides it: **which critical aspect of this target will the standing panel only skim, where being wrong is expensive?**

A critic launches only when both of these hold, and the run file records them:

- **Quoted**: the target's own text that makes the aspect critical. A claim you inferred from the repo's shape belongs to the standing panel; repo shape is a constant across every run and so tells you nothing about this one.
- **Uncovered**: one line on why architectural review, root-cause analysis, and (for a plan) claim-checking will each only skim it. Generic depth is what those three already sell.

The record line is written before any reference is opened, because naming the aspect is the decision and it happens in your words, not against a menu:

```
Bespoke critic: none — {one-line reason}
Bespoke critic: {aspect} — {quote from the target} — {why the standing panel only skims it}
```

With an aspect recorded, `references/bespoke-critic.md` has the authoring guidance and the invocation shape.

### The reviewer prompt

Every panel agent gets the same contract in its user-turn `prompt`, and no agent-definition content is repeated there:

```
## Output Contract

Every finding starts with a Finding Anchor on its own line, because synthesis parses it:

  Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>

Name the defect class in plain words — a short phrase describing the underlying defect (e.g. "missing validation — external input to a DB query"), not a label from a fixed list. Keep the `defect_class` field on every anchor: synthesis merges findings by `(file, defect_class)`, so the phrase is critical.

Confidence: state each finding's confidence and its basis in plain prose within the finding body (high when you verified it against cited code; low when it rests mostly on the diff). Do not append a tag.

For every finding, also state what the target itself proposes at that spot (quote or cite it) and what the realistic alternatives are — the orchestrator turns your finding into a decision the user makes, and a finding with no alternatives named forces the orchestrator to invent them.

Abstinence rule (INSUFFICIENT CONTEXT): if you cannot assess a dimension with the provided data, output `INSUFFICIENT CONTEXT — [what's missing, what you'd need to read/verify]` for that dimension and move on, because the orchestrator fetches what you name and re-runs you, and a guess would be read as a finding.

## Context
{plan text OR git diff}

## Affected Files
{list of repo-relative paths}

## Project Domain Knowledge
{knowledge_context}
```

`{knowledge_context}` is the project's own skills and rules that bear on the affected files, so the panel reviews against documented patterns and not only general principles. `references/domain-harvest.md` defines it.

For a plan, every agent's contract also carries the `## Premise Audit` block from `references/premise-audit.md`.

A reviewer re-launched after a gap was closed gets one more block:

```
## Resolved Gaps
{the missing context that was fetched, formatted for that agent}
```

Before deleting or renaming any Output Contract field, run the Contract Audit in `references/contract-audit.md`: it lists every copy of the contract (reviewer agents plus sibling skills), so a token rename touches them all in the same commit.

### When a reviewer fails or abstains

An agent that errors or times out is retried once with the same prompt.

- **Both fixed reviewers fail twice.** The run file gets `## ABORTED — both fixed reviewers failed twice`, there is no synthesis and no tension list, and chat gets `Challenge ABORTED — both fixed reviewers failed twice. See <run_file>.` followed by a plain-text question: retry, proceed without challenge, or roll back. The user must reach a terminal disposition. A verdict is never synthesized from one fixed reviewer, because the conflict check between the two is the point of having both.
- **An auxiliary agent** (`plan-fact-checker`, the bespoke critic) **fails twice.** The run degrades: `## {agent}: FAILED — degraded run` goes in the run file, the gap goes under the synthesis's Insufficient Context Areas, and the verdict is capped at `REVISE`.
- **A reviewer reports `INSUFFICIENT CONTEXT`.** When the missing context is reachable (a file path, a ticket, a grep pattern), fetch it and re-launch only that agent with a `## Resolved Gaps` block, once. A gap that cannot be closed, or is still open after the retry, caps the verdict at `REVISE` and becomes a tension of its own: an unassessed dimension is a decision the user makes knowingly, not a footnote.

## Verdict

Each agent closes with a judgment sentence containing exactly one named keyword. Read that keyword, not the overall tone:

| Agent | Keyword in its closing sentence | Positive | Concerning | Fundamental issue |
|---|---|---|---|---|
| `architectural-reviewer` | `pass` / `concerns` / `rethink` | pass | concerns | rethink |
| `root-cause-reviewer` | `systematic` / `partial` / `patch-only` | systematic | partial | patch-only |
| `plan-fact-checker` (plan mode) | `accurate` / `discrepancies` / `unsound` | accurate | discrepancies | unsound |
| bespoke critic (when launched) | `pass` / `concerns` / `rethink` | pass | concerns | rethink |
| Final `Overall Verdict` | (orchestrator-owned) | PASS | REVISE | RETHINK |

The worst signal across the panel governs the verdict. The verdict describes how much of the target is in question; it decides nothing, because every decision goes to the user.

## Synthesis

The merged finding list is what the tensions are rendered from, and the run file's `## Synthesis` section records it.

- **Duplicates.** Two findings are the same finding when they have the same `file` and the same underlying `defect_class`, judged by meaning, since `defect_class` is a plain-words phrase. A structural issue and a missing test on the same file are distinct and stay separate. A merged finding names both source agents.
- **Priority.** Severity and confidence are judged from each finding's prose: high-severity blockers first, then medium.
- **Cross-agent conflicts.** When one reviewer praises what another faults ("good abstraction" against "over-abstraction hides the root cause"), the conflict is carried forward as a tension of its own with both sides cited. The orchestrator does not pick a side.
- **False consensus.** When every agent closed positive and none raised a concern it called medium or higher, re-examine the highest-risk areas of the diff or plan yourself for anything the panel normalized or overlooked. Anything found is a new finding tagged `[CONSENSUS-BLIND-SPOT]`; otherwise the synthesis records that the check ran and the agreement held.

## Tensions

**What becomes a tension**: every high- and medium-severity finding from the merged list, `[CONSENSUS-BLIND-SPOT]` findings included, every cross-agent conflict, and every unresolved INSUFFICIENT CONTEXT gap. Low-confidence findings that no agent tied to a concrete risk get no block; they are one-liners under `Also raised`, so nothing is silently dropped.

One status line, then one block per tension. This shape is canonical and lives nowhere else:

```
## Challenge — {VERDICT} · arch: {✅|⚠️|❌} rca: {✅|⚠️|❌}{ facts: {✅|⚠️|❌}}{ critic: {✅|⚠️|❌}} · {N} tensions · artifact: <run_file>

### {N}. {short title}
➡️ {what the target proposes here — quote the plan section or cite file:line}
🛑 {the tension — what breaks, who raised it (arch / rca / facts / critic), and how sure they are}
？ {Option A — …} / {Option B — …} / {Option C — …} → Recommend {letter}: {one-sentence why}

Also raised (no decision needed unless you want one):
- {low-confidence finding, one line} — {source}

Strengths: {brief, omit if none}
```

- Each block has at least two genuine options. "Leave it as proposed and accept the risk" is a legitimate option, offered with its cost.
- Every block carries a recommendation. Options without a pick push the work back onto the user.
- Recommend against the target when the evidence says so. The recommendation is your judgment, not a summary of what the plan already says.
- Each of the three lines is short enough to read as a decision. Depth lives in the run file.
- On a cross-agent conflict the options are the two reviewers' positions, and the recommendation picks one and cites the evidence that decides it.
- `Also raised` holds low-confidence findings with no concrete risk attached, and nothing else. A finding is never moved there to shorten the list.
- The `facts` mark renders for a plan only, and the `critic` mark when a bespoke critic launched; both map straight off the keyword table. Source attribution and any violated skill name go in the 🛑 line.
- `[CONSENSUS-BLIND-SPOT]` findings render as ordinary blocks, with the tag kept in the title so the user sees where it came from.
- An empty section's header is omitted, never written as `N/A`.

When the panel surfaced nothing worth a decision, say so, note the strengths briefly, and close the run.

## Verify

- The run file has a section for the snapshot, for each launched agent's verbatim return, and for `## Synthesis`, `## Tensions`, and `## Directions Applied` (or `## PR Review Comments`), or it ends at `## ABORTED`.
- Every high- and medium-severity finding, every cross-agent conflict, and every open INSUFFICIENT CONTEXT gap in the synthesis has a tension block, and every block has two or more options and a recommendation.
- Nothing in the target changed between launching the panel and the user's answer.
- `## Directions Applied` has one entry per tension, and each entry's change is in the plan or the code, or is recorded as left by decision.
- The verdict is no better than `REVISE` when any gap stayed open or an auxiliary agent failed.
- For a plan: `git status --porcelain` shows no path that is new since the run file's snapshot. Panel agents run premise-audit experiments in the scratchpad only, so a new path is an experiment leftover; it is removed once it is confirmed to be one, and the cleanup is noted in the run file. Paths in the snapshot stay untouched.
