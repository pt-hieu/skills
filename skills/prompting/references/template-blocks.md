# Prompting — Template Blocks Reference

Full prompt template blocks for copy-paste into agent prompts. See `instructions.md` for blocks 1-3.

---

### 4. Pro/Con Balance Requirement

```
## PRO/CON BALANCE
For every recommendation, the KEY RISK / counter-argument field must be the strongest opposing case:
- POSITIVE recommendation → KEY RISK argues for caution (what could invalidate this)
- NEGATIVE/DEFENSIVE stance → KEY RISK names what opportunity you'd miss
Never present KEY RISK as a minor footnote. It must genuinely challenge the thesis.
This counterbalances systematic confirmation bias documented in LLM outputs.
```

### 5. Abstinence Rule

```
## INSUFFICIENT DATA RULE
If the data needed to support a claim is missing, stale, zero-valued, or unverifiable:
  output: "INSUFFICIENT DATA — [what's missing, what would be needed]"
Do NOT infer, extrapolate, or generate plausible-sounding analysis from memory.
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
If you cannot attribute a number to a data source, do NOT include it.
```

### 7. Chain-of-Verification (CoVe)

```
## VERIFICATION STEP
After generating your analysis:
1. Re-read each factual claim
2. For each claim: can you trace it to a specific provided data field?
3. Remove or flag any claim that failed verification with [UNVERIFIED]
4. If >30% of claims are UNVERIFIED: output "INSUFFICIENT DATA" for this item
```

### 8. Structured Output Schema (Pydantic)

```python
from pydantic import BaseModel, Field
from typing import Literal

class AnalysisOutput(BaseModel):
    subject: str
    action: Literal["RECOMMEND", "WATCH", "WAIT", "AVOID"]  # Constrained enum
    confidence: Literal["HIGH", "MEDIUM", "LOW"]
    thesis: str = Field(description="2-3 sentences, qualitative only")
    pro_case: str = Field(description="Strongest argument for the action")
    con_case: str = Field(description="Strongest counter-argument")
    data_sources_cited: list[str] = Field(description="Tool names or field paths used")
    conflicts_identified: list[str] = Field(description="Any contradictory signals found")
    conflict_resolution: str = Field(description="How conflicts were weighed")
```

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
If data shows no clear signal: output WAIT or AVOID — never stretch marginal evidence.
An output with 0 recommendations is better than forced recommendations.
Confirmation bias: LLMs trained on persuasive text tend to overweight supporting evidence.
Counter it by actively seeking the opposing case before concluding.
SKIP / NO RECOMMENDATION is always a valid output.
```
