---
name: diagnose
description: "Use when investigating bugs, reviewing fixes, running post-incident analysis, or verifying a fix lands on root cause rather than a symptom."
---

# Diagnose

Systematic root-cause analysis framework. Stops you from patching symptoms by forcing you past the first plausible cause to bedrock.

## When to Use
- Investigating a bug and you notice yourself stopping at the first "obvious" cause
- Reviewing a fix (yours or someone else's) to check whether it targets root or symptom
- Post-incident analysis where you need to identify the defect class and find sibling instances
- Anywhere the 5-whys feels insufficient

## Subagents Used
Interactive diagnose spawns the `code-historian` subagent at methodology §2; its output feeds reasoning only and never appears in the Output Contract.

## Output Contract (interactive use)
Run the methodology silently; surface only conclusions.

Default shape (≤ 11 lines + 1 line per cited sibling beyond the first 3):
- One-line root cause
- Defect class (one line, named in plain words)
- Where the fix lands on the chain
- Reproduction: `path::test name` (failing test or regression test in the diff), or `UNABLE TO REPRODUCE — [reason]`
- Sibling instances (file:line list)
- Confidence — only when LOW or contested
- Optional one-line suggestion

Expand to full structured output when:
- The user asks "explain" / "show your work", OR
- An orchestrator (e.g. `brian:kickoff` / `brian:autopilot` on the bug path) injects its own Output Contract — that contract supersedes this one.

## Core Principle
Keep asking "why does THIS exist?" until you hit bedrock — see `references/methodology.md` for the full bedrock test and reproduction gate.

## Instructions
See `references/methodology.md` for the full framework: problem framing, root cause trace (iterative deepening), reproduction gate, defect class identification, validation tests, sibling search, and self-challenge.
