# Prompting Reference

Research synthesis from 20+ papers and industry sources on effective LLM prompting for reliable agent systems.

---

## Quality Checklist (Severity Tiers)

### CRITICAL — block if missing
- **Deterministic split** — code computes all numbers; LLM interprets only
- **Structured output** — Pydantic schema with `Literal`/`Enum` for constrained fields
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

## Template Blocks 1–3

### 1. Expert Role Assignment

```
You are a [specific expertise] specializing in [domain].
Your analysis methodology:
1. [Step 1 — what you assess first]
2. [Step 2 — what you cross-reference]
3. [Step 3 — how you resolve conflicts]
4. [Step 4 — how you form final judgment]

CONSTRAINTS:
- All numerical calculations are pre-computed and provided below. Do NOT perform arithmetic.
- Use ONLY the provided data. Do not reference external knowledge about current state.
- Flag any data that appears inconsistent or anomalous.
```

### 2. Conflict Detection Protocol

```
## CONFLICT DETECTION (MANDATORY)
Before writing any recommendation:
1. LIST all signals per item across inputs (e.g., quantitative vs qualitative vs contextual)
2. For each conflict: state it explicitly — "Conflict: metric A suggests X but metric B suggests Y"
3. Resolution priority: [define your hierarchy, e.g., hard data > soft signals > context]
4. If unresolvable: downgrade conviction and note "conflicting signals"
FORBIDDEN: "on balance" or "taking everything into account" without listing conflicts first
```

### 3. Confidence Calibration Guide

```
## SIGNAL CONFIDENCE
Append confidence tag in the analysis field:
- [HIGH]:   All key indicators align (4/4 or domain-specific threshold)
- [MEDIUM]: Most align, one minor conflict noted explicitly
- [LOW]:    Only 2 indicators align — downgrade recommendation automatically

If you cannot cite 3+ data points from the provided context supporting a recommendation,
it must be downgraded one level.
```

*Full template blocks 4–10 (Pro/Con, Abstinence, Citation, CoVe, Structured Output, Few-Shot, Objectivity) → `references/template-blocks.md`*

---

## Strict vs. Flexible Declarations

Use this table when designing output schemas:

| Field | Strictness | Rationale |
|-------|-----------|-----------|
| `action` / `decision` | **STRICT** | Feeds downstream automation |
| `confidence` (HIGH/MEDIUM/LOW) | **STRICT** | Drives downstream logic |
| `reasoning` / `thesis` | **FLEXIBLE** | Qualitative judgment |
| `key_risk` / `counter_argument` | **STRICT template** | Must challenge thesis, not footnote |
| `conflicts_identified` | **STRICT list** | Must enumerate, not summarize |

**Rule:** Fields that feed deterministic downstream code → `Literal` type with exact values. Fields that inform human judgment → `str` with descriptive guidance.

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
| Verbose narrative | More words = more speculation | Constrain output length, use JSON |
| Vague confidence | "fairly confident" tells you nothing | Use calibrated levels: HIGH/MEDIUM/LOW |
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

---

*Research sources with citations → `references/research-sources.md`*
