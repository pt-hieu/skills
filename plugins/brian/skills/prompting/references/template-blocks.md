# Prompting — Template Blocks Reference

Full prompt template blocks for copy-paste into agent prompts. Concepts and gates live in `SKILL.md`; this file holds the verbatim block text.

---

### 1. Expert Role Assignment

```
You are a [specific expertise] specializing in [domain].
Your analysis methodology:
1. [Step 1 — what you assess first]
2. [Step 2 — what you cross-reference]
3. [Step 3 — how you resolve conflicts]
4. [Step 4 — how you form final judgment]

Constraints:
- All numerical calculations are pre-computed and provided below; do not perform arithmetic, because a figure you compute cannot be traced to a source.
- Use only the provided data; do not reference external knowledge about current state.
- Flag any data that appears inconsistent or anomalous.
```

### 2. Conflict Detection Protocol

```
## CONFLICT DETECTION
Before writing any recommendation:
1. LIST all signals per item across inputs (e.g., quantitative vs qualitative vs contextual)
2. For each conflict: state it explicitly — "Conflict: metric A suggests X but metric B suggests Y"
3. Resolution priority: [define your hierarchy, e.g., hard data > soft signals > context]
4. If unresolvable: downgrade conviction and note "conflicting signals"
A summary like "on balance" or "taking everything into account" comes after the conflicts are listed, not instead of them
```

### 3. Confidence Calibration Guide

Use a calibrated tag like this **only when a non-LLM parses the confidence value**. When an LLM or a human reads the output, state confidence and its basis in prose instead (see Block 8b) — the prose default is "low" unless the claim is grounded in cited data.

```
## SIGNAL CONFIDENCE
Append confidence tag in the analysis field:
- [HIGH]:   All key indicators align (4/4 or domain-specific threshold)
- [MEDIUM]: Most align, one minor conflict noted explicitly
- [LOW]:    Only 2 indicators align — downgrade recommendation automatically

If a recommendation rests on fewer data points from the provided context than the tag above requires,
downgrade it one level.
```

### 4. Pro/Con Balance Requirement

```
## PRO/CON BALANCE
For every recommendation, the KEY RISK / counter-argument field must be the strongest opposing case:
- POSITIVE recommendation → KEY RISK argues for caution (what could invalidate this)
- NEGATIVE/DEFENSIVE stance → KEY RISK names what opportunity you'd miss
KEY RISK must genuinely challenge the thesis, at its real weight.
This counterbalances systematic confirmation bias documented in LLM outputs.
```

### 5. Abstinence Rule

```
## INSUFFICIENT DATA RULE
If the data needed to support a claim is missing, stale, zero-valued, or unverifiable:
  say so plainly — name what is missing and what evidence would resolve it.
  Reserve the exact tag "INSUFFICIENT DATA — [what's missing, what would be needed]"
  for a pipeline where a downstream consumer branches on that literal string.
Do not infer, extrapolate, or generate plausible-sounding analysis from memory.
A blank / skipped analysis is better than a fabricated one.
Applies to: comparisons, calculations, pattern identifications, any factual claim.
```

### 6. Data Citation Requirement

```
## SOURCE CITATION
For every numerical claim, cite which tool or pre-computed field provided the value:
- Format: "score 42 [tool_get_metrics]" or "ratio 3.2 [pre_computed.analysis]"
- For derived values: show the formula — "ratio = (114-107)/(107-101) = 1.17"
- Mark any inferred/estimated values with [ESTIMATED]
If you cannot attribute a number to a data source, do not include it.
```

### 7. Chain-of-Verification (CoVe)

```
## VERIFICATION STEP
After generating your analysis:
1. Re-read each factual claim
2. For each claim: can you trace it to a specific provided data field?
3. Remove or flag any claim that failed verification with [UNVERIFIED]
4. If most claims are UNVERIFIED: state that this item cannot be supported, and why
```

### 8. Structured Output Schema (Pydantic) — for machine-to-machine handoffs only

Use this **only when a non-LLM consumer parses the output**. When an LLM or a human reads the result, prefer Block 8b (prose) instead — see *Prose-First vs. Structured Output* in `SKILL.md` for why.

```python
from pydantic import BaseModel, Field
from typing import Literal

class AnalysisOutput(BaseModel):
    subject: str
    action: Literal["RECOMMEND", "WATCH", "WAIT", "AVOID"]  # Constrained enum
    confidence: Literal["HIGH", "MEDIUM", "LOW"]
    thesis: str = Field(description="Short qualitative thesis, no numbers")
    pro_case: str = Field(description="Strongest argument for the action")
    con_case: str = Field(description="Strongest counter-argument")
    data_sources_cited: list[str] = Field(description="Tool names or field paths used")
    conflicts_identified: list[str] = Field(description="Any contradictory signals found")
    conflict_resolution: str = Field(description="How conflicts were weighed")
```

### 8b. Prose Output Guidance — for an LLM or human reader (default)

When the consumer is an LLM or a human, ask for prose instead of a schema. Name the content you need, not a field list — the model carries the same information in natural language without a contract to drift.

```
## OUTPUT
Write a short, focused analysis in plain prose. Cover, in your own words:
- the call you're making and why (state your confidence and its basis — high when grounded
  in cited data, low when it rests on thin evidence; no fixed tag required)
- the single strongest argument for it, and the single strongest argument against
- which data you relied on (cite the tool/field inline)
- any contradictory signals you found and how you weighed them
Keep it to a few tight paragraphs. Brevity over a schema — do not pad to fill a structure.
```

Use this whenever the reader is another agent or a person. Drop to Block 8 only when a non-LLM downstream parses exact field values.

### 9. Few-Shot Example Block

```xml
<good_example>
[Your best example of the exact output format you want]

<reasoning>
Good because: [specific reasons — data cited, format correct, conflict resolved]
</reasoning>
</good_example>

<bad_example>
[Common failure mode you want to prevent]

<reasoning>
Bad because: [what's wrong — vague, invented numbers, no conflict handling]
</reasoning>
</bad_example>
```

### 10. Objectivity + Anti-Confirmation-Bias Rules

```
## OBJECTIVITY RULE
If the data shows no clear signal, output WAIT or AVOID rather than stretching marginal evidence; no recommendation is a valid output.
Seek the opposing case before concluding, so the conclusion rests on more than the supporting evidence.
```
