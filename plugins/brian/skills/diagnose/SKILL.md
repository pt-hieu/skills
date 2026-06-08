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
Interactive diagnose spawns the `code-historian` subagent (model: sonnet) at methodology §2 to surface verbatim commit/ticket "why" quotes that strengthen alternative-framing generation in §1 and bedrock citation in §4. Expect a ~10–30s latency bump on the first turn. The historian output feeds reasoning only — it does not appear in the Output Contract.

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
- An orchestrator (e.g. `/challenge`) injects its own Output Contract — that contract supersedes this one.

## Core Principle
Stop at the first plausible cause → you're patching. Keep asking "why does THIS exist?" until you hit bedrock: an explicit design decision, an external constraint, a missing abstraction, or circular reasoning back to an earlier node. A root cause you cannot reproduce is a hypothesis, not a conclusion — surface it as such.

## Instructions
See `references/methodology.md` for the full framework: problem framing, root cause trace (iterative deepening), reproduction gate, defect class identification, validation tests, sibling search, and self-challenge.

## Used By
- `challenge` skill — **post-plan callsite** (sees `## Prior intent` on disk if kickoff ran upstream); methodology §2 skip-clause may fire when PROVENANCE + COVERAGE hold. The Systematic Resolution Reviewer (Agent 2) applies this methodology to audit whether a fix targets root cause or symptom.
- `kickoff` skill, Task 2 bug path (`kickoff/instructions.md:55`) invokes `brian:diagnose` via the `Skill` tool — **pre-plan callsite** (the `## Prior intent` artifact does not yet exist on disk because Task 7 hasn't run); skip-clause cannot fire; double-spawn with kickoff Task 3's historian is **accepted by design** because Task 2's diagnose-invoked historian scopes to the symptom paths, while Task 3 scopes to the broader design surface — different consumers, different scopes. See methodology §2's "Ordering caveat" paragraph for the canonical wording.
