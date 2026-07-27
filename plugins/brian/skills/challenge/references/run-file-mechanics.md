# Run-File Mechanics — persistence, re-run injection, extraction

Read this when persisting a round's artifacts, on any re-run round (Step 5), or on the aborted-round path. Persistence survives compaction and gives every round a forensic trail.

## Round Lifecycle

All round artifacts (context, agent returns, synthesis, dispositions) are appended to `$run_file` as `## Round N` subsections. No per-round directory; no separate files.

If a Step 3 retry fetches missing context, the re-launched agent's output replaces its prior block under the current `## Round N` heading and the synthesis notes the prior attempt. If both fixed reviewers fail twice, append `### Round N: ABORTED — both fixed reviewers failed twice` to the run file and skip synthesis (see Step 2 Await protocol for the terminal disposition; auxiliary-agent failures degrade the round instead).

Re-runs (Step 5) read prior `### Synthesis` and `### Round N Changes` sections from the run file and inject them as `## Prior Round Findings` + `## Round N Changes` into the next round's Step 2 contract. Review-only mode never re-runs (no loop, no escalation banner).

## Step 3.0 — Persist agent returns

Append one subsection per panel agent under the current `## Round N` heading. Wrap each verbatim agent return in a fenced markdown code block so the agent's own `##`/`###` headings stay inert in the run file's outline:

```
### Architectural Review
~~~markdown
{verbatim agent return}
~~~

### Root-Cause Review
~~~markdown
{verbatim agent return}
~~~

### Fact Check            <- plan mode only
~~~markdown
{verbatim agent return}
~~~

### Bespoke Critic — {aspect}   <- when one launched
~~~markdown
{verbatim agent return}
~~~
```

Crux rounds persist `### Crux Brief`, `### Crux — {panelist}`, and `### Crux Decision` instead — shapes in `references/crux-round.md`.

Use `~~~` (tilde) fences so any ` ``` ` triple-backtick code blocks inside the agent's output don't terminate the wrapper.

If a retry happens (Step 3.1), replace the affected agent's block with the retry output and note the prior attempt in the synthesis. Failures after retry abort the round (see Step 2 Await protocol).

## Step 3.3a — Persist verbose synthesis

Runs only after 3.1 resolves (retries complete or aborted) and before the chat render (3.3b). On the aborted-round path (both fixed reviewers failed twice): skip both 3.3a and 3.3b; emit only one line to chat: `Round N: ABORTED — both fixed reviewers failed twice. See <run_file>.`

Append `### Synthesis` under the current `## Round N` heading using this template:

```
### Synthesis

#### Architectural Fitness: {verdict}
{high- and medium-severity findings only, with file:line and evidence citations — drawn from architectural-reviewer's findings}

#### Systematic Resolution: {verdict}
{high- and medium-severity findings only, with causal chains — drawn from root-cause-reviewer's findings}

#### Factual Accuracy: {verdict}
{plan mode only — claim discrepancies and falsified premises from plan-fact-checker. Omit subsection in impl mode.}

#### Bespoke Critic — {aspect}: {verdict}
{high- and medium-severity findings only. Omit if no critic launched.}

#### Cross-Agent Conflicts
{any disagreements between the two reviewers — both sides explicit. Omit subsection if none.}

#### False Consensus Check
{result. Omit subsection if agents disagreed.}

#### What the Changes Do Well
{consolidated strengths from the whole panel. Omit subsection if none.}

#### Action Items
1. ❌ HIGH {file:line} — {one-sentence issue} — {one-sentence fix}
2. ⚠️ MEDIUM {file:line} — {one-sentence issue} — {one-sentence fix}
...

#### Insufficient Context Areas
{dimensions either agent could not assess — top-level callout if any remain after retry. Omit subsection if none.}

#### Overall Verdict: {PASS | REVISE | RETHINK}
- PASS: no high- AND no medium-severity concerns
- REVISE: one or more medium-or-higher concerns with clear fix paths
- RETHINK: any high-severity concern indicating fundamental issue

(Verdict capped at REVISE if any unresolved INSUFFICIENT CONTEXT — see Step 3.1.)
```

## Step 5 — Re-run section extraction grammar

When building the round N+1 contract injection:

- `## Prior Round Findings`: concatenate the `### Synthesis` subsection from EVERY prior round in chronological order, separated by `--- Round K ---` markers. (Round 2 → R1's synthesis only; Round 3 → R1+R2 syntheses concatenated. Verbal duplication is acceptable; agents re-deduplicate.)
- `## Round N Changes`: the most recent prior round's `### Round N Changes` subsection only.

Section extraction: anchor on the `### Synthesis` and `### Round N Changes` H3 headings (NOT the `## Round N` H2 — agent returns are fenced per Step 3.0 but extraction grammar is keyed off our own H3 sentinels for safety). Read content from the H3 heading to the next H3 heading at the same level, or to EOF.
