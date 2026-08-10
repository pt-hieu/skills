# Run-File Mechanics — persistence and section shapes

Read this when persisting the panel's returns, the synthesis, the tension list, or the applied directions, and on the aborted path. Persistence survives compaction and gives the run a forensic trail.

## Run lifecycle

Every artifact appends to `$run_file` as a top-level `##` section, in the order the run produces them: `## Working-Tree Snapshot (Step 0)`, the panel returns, `## Synthesis`, `## Tensions`, and `## Directions Applied` (or `## PR Review Comments` in review-only mode). One file per run; no sub-directories.

If a Step 3.1 retry fetches missing context, the re-launched agent's output replaces its prior block and the synthesis notes the prior attempt. If both fixed reviewers fail twice, append `## ABORTED — both fixed reviewers failed twice` and skip the synthesis (see SKILL.md Step 2's await protocol for the terminal disposition; auxiliary-agent failures degrade the run instead).

## Step 3.0 — Persist agent returns

Append one section per panel agent. Wrap each verbatim agent return in a fenced markdown code block so the agent's own `##`/`###` headings stay inert in the run file's outline:

```
## Architectural Review
~~~markdown
{verbatim agent return}
~~~

## Root-Cause Review
~~~markdown
{verbatim agent return}
~~~

## Fact Check            <- plan mode only
~~~markdown
{verbatim agent return}
~~~

## Bespoke Critic — {aspect}   <- when one launched
~~~markdown
{verbatim agent return}
~~~
```

Use `~~~` (tilde) fences so any ` ``` ` triple-backtick code blocks inside the agent's output don't terminate the wrapper.

If a retry happens (Step 3.1), replace the affected agent's block with the retry output and note the prior attempt in the synthesis. Failures after retry abort the run (see SKILL.md Step 2's await protocol).

## Step 3.3 — Persist the synthesis

Runs only after 3.1 resolves (retries complete or aborted) and before the Step 4 tension render. On the aborted path (both fixed reviewers failed twice): skip it, and emit only one line to chat: `Challenge ABORTED — both fixed reviewers failed twice. See <run_file>.`

Append:

```
## Synthesis

### Architectural Fitness: {verdict}
{high- and medium-severity findings only, with file:line and evidence citations — drawn from architectural-reviewer's findings}

### Systematic Resolution: {verdict}
{high- and medium-severity findings only, with causal chains — drawn from root-cause-reviewer's findings}

### Factual Accuracy: {verdict}
{plan mode only — claim discrepancies and falsified premises from plan-fact-checker. Omit subsection in impl mode.}

### Bespoke Critic — {aspect}: {verdict}
{high- and medium-severity findings only. Omit if no critic launched.}

### Cross-Agent Conflicts
{any disagreements between the two reviewers — both sides explicit, no side picked here. Omit subsection if none.}

### False Consensus Check
{result. Omit subsection if agents disagreed.}

### What the Changes Do Well
{consolidated strengths from the whole panel. Omit subsection if none.}

### Insufficient Context Areas
{dimensions any agent could not assess and that remain open after retry — each one becomes a tension in Step 4. Omit subsection if none.}

### Overall Verdict: {PASS | REVISE | RETHINK}
- PASS: no high- AND no medium-severity concerns
- REVISE: one or more medium-or-higher concerns with clear fix paths
- RETHINK: any high-severity concern indicating fundamental issue

(Verdict capped at REVISE if any unresolved INSUFFICIENT CONTEXT — see SKILL.md Step 3.1.)
```

The synthesis has no Action Items list. Action belongs to the user, and Step 4's `## Tensions` section is where each finding is put to them as a decision.

## Step 4 — Persist the tension list

Append the chat-rendered tension blocks verbatim under `## Tensions`. Verbatim matters: the run file should show the user exactly the decision they were asked to make, in the words they were asked it.

## Step 5 — Persist the directions

Append one entry per tension, in the same numbering Step 4 used:

```
## Directions Applied
1. {tension title} — direction: {what the user chose} — applied: {plan section or file:line changed, or "no change, by decision"}
2. ...
```

A tension the user left as proposed still gets an entry, with the reason they gave. An entry missing from this list reads as work dropped on the floor.
