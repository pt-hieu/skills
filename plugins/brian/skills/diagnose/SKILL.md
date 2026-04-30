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

## Output Contract (interactive use)
Run the methodology silently; surface only conclusions.

Default shape (≤ 10 lines + 1 line per cited sibling beyond the first 3):
- One-line root cause
- Defect class (one line, from the closed enum)
- Where the fix lands on the chain
- Sibling instances (file:line list)
- Confidence — only when LOW or contested
- Optional one-line suggestion

Expand to full structured output when:
- The user asks "explain" / "show your work", OR
- An orchestrator (e.g. `/challenge`) injects its own Output Contract — that contract supersedes this one.

## Core Principle
Stop at the first plausible cause → you're patching. Keep asking "why does THIS exist?" until you hit bedrock: an explicit design decision, an external constraint, a missing abstraction, or circular reasoning back to an earlier node.

## Instructions
See `references/methodology.md` for the full framework: problem framing, root cause trace (iterative deepening), defect class identification, validation tests, sibling search, and self-challenge.

## Used By
- `challenge` skill — the Systematic Resolution Reviewer (Agent 2) applies this methodology to audit whether a fix targets root cause or symptom
