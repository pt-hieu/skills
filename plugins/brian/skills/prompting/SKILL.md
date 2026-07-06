---
name: prompting
description: "Use when creating or improving LLM agent prompts, designing structured output schemas, or diagnosing vague, overconfident, or hallucinated agent outputs."
---

# Prompting

Applies research-backed prompting techniques — conflict detection, confidence calibration, chain-of-verification, citation, hallucination prevention — instead of intuition when writing or fixing LLM agent prompts and structured-output schemas.

Research synthesis from papers and industry sources on effective LLM prompting for reliable agent systems. To cite the evidence behind a technique, read `references/research-sources.md`.

---

## Quality Checklist (Severity Tiers)

### CRITICAL — block if missing
- **Deterministic split** — code computes all numbers; LLM interprets only. This is independent of prose-vs-structured output and always binds.
- **Prose-first communication** — prefer free prose whenever an LLM or human reads the output; reserve schemas for non-LLM consumers that parse the fields. See *Prose-First vs. Structured Output* for the rationale.
- **Abstinence rule** — `INSUFFICIENT DATA` output when data is missing or unverifiable
- **Conflict detection** — explicit protocol to enumerate and resolve contradictory signals

### IMPORTANT — degrades quality without
- **Specific role** — expert role with domain + methodology, not generic "you are helpful"
- **Few-shot examples** — 2-4 `<good_example>` / `<bad_example>` blocks with `<reasoning>`
- **Confidence calibration** — per-dimension confidence, not single vague score
- **Pro/con balance** — always require counter-argument to prevent confirmation bias

### NICE-TO-HAVE — improves polish
- **Data citation** — each claim cites which tool/field it came from
- **Output constraints** — length limits + structured format = fewer speculative statements

---

## Core Architecture Principle

**Separate computation from reasoning.** Single highest-impact technique (MIT thesis: tool-augmented computation achieves 100% accuracy vs LLM arithmetic).

```
Code layer:  All arithmetic, lookups, thresholds, ratios, scores, aggregations
LLM layer:   Qualitative judgment, narrative, recommendations, synthesis

Flow: Raw Data → Code (compute metrics, scores, deltas) → Structured Context → LLM (interpret)
```

**Rule:** Never let the LLM compute numbers that code can compute deterministically. Pre-compute everything possible and pass structured results to the LLM.

---

## Prose-First vs. Structured Output

**Default to prose for anything an LLM or a human reads.** Free natural-language prose carries judgment, nuance, and uncertainty better than a rigid field list, and it does not drift: there is no schema for the producer and consumer to fall out of sync on.

**Reserve structured output (Literal/Enum schemas) for true machine-to-machine handoffs** — where a *non-LLM* consumer parses the value and branches on it. An enum tag read only by another LLM (or a human) buys rigidity without buying determinism, and invites the failure mode below.

**The failure mode prose avoids:** when you force an LLM's output into a rigid schema that another LLM or a human consumes, the two sides drift — a consumer ends up parsing a field the producer renamed or stopped emitting, and the producer hallucinates fields to satisfy a contract no one reads. (Documented in this codebase: a stale `finding_id` contract left agents "verifying by a never-injected field," commit `6652d78`.) Prose has no such contract to drift.

**This is orthogonal to the deterministic split** above: code still computes every number; the LLM still interprets. Prose-first governs only *how the LLM's qualitative output is shaped* — as prose, not as a schema — when the reader is an LLM or a human.

When assembling a prompt from the standard blocks (expert role, conflict detection, confidence calibration, pro/con, abstinence, citation, CoVe, structured/prose output, few-shot, objectivity), read `references/template-blocks.md`.

---

## Strict vs. Flexible Declarations

Use this table when designing output. **The consumer type is the deciding column** — reach for an enum only when a non-LLM downstream actually parses the value (rationale in *Prose-First vs. Structured Output*):

| Field | Consumer | Strictness | Rationale |
|-------|----------|-----------|-----------|
| `action` / `decision` | non-LLM automation | **STRICT** | Code branches on the exact value |
| `confidence` (HIGH/MEDIUM/LOW) | depends | **STRICT only when a non-LLM parses it**; for an LLM/human consumer, prose confidence + its basis is sufficient | Drift risk for no gain unless a machine parser reads it |
| `reasoning` / `thesis` | LLM / human | **PROSE** | Qualitative judgment |
| `key_risk` / `counter_argument` | LLM / human | **PROSE, but mandatory** | Must genuinely challenge the thesis — required content, not a rigid field |
| `conflicts_identified` | depends | **STRICT list only for a non-LLM**; otherwise enumerate in prose | Must enumerate, not summarize |

**Rule:** The consumer type decides. A field parsed by non-LLM code → `Literal`/`Enum` with exact values. A field read by an LLM or a human → prose with descriptive guidance.

---

## Anti-Hallucination Verification Chain

Apply this chain for any agent producing actionable outputs:

1. **DATA FRESHNESS** — check timestamps match expected recency; reject stale data
2. **COMPLETENESS** — fewer than 3 sources → downgrade confidence automatically
3. **RED FLAGS** — missing fields, zero values, unchanged data over expected change periods → flag explicitly
4. **VERIFICATION (CoVe)** — re-read each claim, trace to a specific provided field
5. **ABSTINENCE** — if >30% claims unverifiable → output `INSUFFICIENT DATA`

This chain should appear as mandatory steps in system prompts for any decision-making agent.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Fix |
|-------------|-------------|-----|
| LLM performs arithmetic | "Semantically coherent but mathematically flawed" | Pre-compute in code |
| Single mega-prompt | Context overload, signals buried | Multi-step pipeline |
| No conflict enumeration | LLM papers over contradictions | Force explicit listing |
| Missing counter-argument | Confirmation bias from training data | Always require KEY RISK / con case |
| Stale parametric knowledge | Model's knowledge is months old | Always inject fresh data via tools |
| Forcing prose into rigid JSON for an LLM/human reader | Contract drift (see *Prose-First vs. Structured Output*) | Use prose; reserve schemas for non-LLM parsers |
| Unbounded rambling output | More words = more speculation | Ask for a short, focused paragraph — brevity, not a schema |
| Vague confidence | "fairly confident" tells you nothing | State confidence AND its basis in plain words (calibrated HIGH/MEDIUM/LOW only when a non-LLM parses it) |
| No abstinence path | Agent generates analysis when data is absent | Explicit INSUFFICIENT DATA output |
| Generic role prompt | "You are a helpful assistant" activates wrong patterns | Specific role with methodology |
| No source attribution | Claims cannot be verified or challenged | Require tool/field citation per claim |

---

## Data Formatting Rules

- Round to meaningful precision: `18.2x` not `18.23456789`
- Always include units: `1,500 units` not `1500`
- Include deltas alongside absolutes: `Score: 82.5 (up 4.2 from previous)`
- Standardize layout across all items for consistency

### Context Layer Structure

Organize input data into clear layers for the LLM:

| Layer | Purpose | Format |
|-------|---------|--------|
| Quantitative | Metrics, scores, computed values | Key values only, not raw data |
| Qualitative | Assessments, reviews, descriptions | Tabular with change deltas |
| Contextual | Environment, constraints, external factors | Bullet-point summaries |

---

## Personality Archetypes

Apply the right personality to match agent responsibility:

| Personality | Best For | Key Behavior |
|-------------|---------|-------------|
| Thorough Investigator | Analysis, synthesis, evaluation agents | Cross-reference multiple angles, show work, cite specifics |
| Skeptical Auditor | Validation, review, quality-check agents | Assume errors exist, check every number |
| Decisive Minimalist | Alert, triage, classification agents | 2-3 sentences max, no hedging |
| Precise Clerk | Extraction, cataloging, registration agents | Extract facts only, never infer |
