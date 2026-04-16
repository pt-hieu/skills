# Challenge — Execution Guide

Fire 2 independent opus subagents in parallel to stress-test a plan or implementation. Both agents challenge whether the changes keep the architecture healthy, expandable, and maintainable — and whether they fix root causes vs patch symptoms.

---

## Step 1: Determine Challenge Target

Identify what to challenge:
- **Plan mode**: challenge the proposed approach before implementation
- **Implementation mode**: challenge code that was just written or changed

Gather context:
- If plan: read the plan content or task list
- If implementation: run `git diff` against the base branch to capture all changes
- Identify the affected areas of the codebase

---

## Step 1.5: Discover Project Domain Knowledge

Gather project-specific knowledge so agents review against documented patterns, not just general principles. Works for any project.

### Actions

1. **Find skills**: Glob `.claude/skills/*/SKILL.md` from the working directory. If none found, check parent directories up to git root.
2. **Filter by relevance**: Read each `SKILL.md` frontmatter (`name`, `description`). Keep a skill if:
   - Affected files touch an area the skill describes
   - Skill name appears in import paths, directory names, or component names in the diff
   - Skill constraints apply to the type of change (e.g., state management skill + new state logic)
3. **Read relevant skills**: For each relevant skill, read its instruction file and key references. Compress into a Skill Context Block (max 200 words each):
   ```
   ### Skill: {name}
   **Domain**: {what area this covers}
   **Patterns to verify**: {documented patterns the diff should follow}
   **Constraints/Gotchas**: {rules that could be violated — these become review criteria}
   **Deep-dive paths**: {file paths agents can Read if they need more context}
   ```
4. **Read project CLAUDE.md**: Check for `.claude/CLAUDE.md` or `CLAUDE.md` at project root. Extract rules/conventions relevant to affected code into a Project Rules Block.
5. **Assemble `{knowledge_context}`**: Combine all Skill Context Blocks + Project Rules Block. If nothing found, use: `"No project-specific skills or CLAUDE.md found. Review using general software engineering principles only."`

---

## Step 2: Launch 2 Opus Subagents in Parallel

Both agents run in background with `model: opus` and `run_in_background: true`.

### Agent 1: Architectural Fitness Reviewer

Prompt template:
```
You are a senior software architect specializing in evolutionary architecture and modular system design.
Your review methodology:
1. Map the dependency graph of affected modules — identify what depends on what
2. Assess each change against SOLID principles and existing codebase patterns
3. Detect conflicts between local improvements and system-wide architectural direction
4. Form judgment on whether the architecture remains healthy for the next 6 months of evolution

Personality: Skeptical Auditor — assume architectural drift exists, verify every boundary.
Disconfirmation rule: 60%+ of your analysis effort must seek reasons this approach FAILS, not reasons it works. If your first draft has more positives than negatives, you have not looked hard enough.

CONSTRAINTS:
- Use ONLY the provided diff/plan and what you can read from the codebase. Do not assume patterns exist without verifying via Grep/Read.
- Flag any area where you lack sufficient context to judge with: "INSUFFICIENT CONTEXT — [what you'd need to verify]"

## Context
{paste the plan OR git diff here}

## Affected Files
{list affected files/modules}

## Project Domain Knowledge
{knowledge_context}

Use this domain knowledge as ADDITIONAL review criteria. If the diff/plan violates a documented skill pattern or project rule, flag it as a finding with the skill name cited as evidence. If domain knowledge is provided, you MUST check the diff against each listed constraint — do not ignore them.
For skills with deep-dive paths: Read those files if you need to verify whether a pattern applies.

## CONFLICT DETECTION (MANDATORY)
Before writing any finding:
1. LIST all architectural signals per affected module (coupling direction, abstraction level, naming pattern, responsibility scope)
2. For each conflict: state it explicitly — "Conflict: module A's pattern suggests X but this change introduces Y"
3. Resolution priority: existing codebase patterns > theoretical best practices > personal preference
4. If unresolvable: downgrade confidence and note "conflicting signals"
FORBIDDEN: "overall the architecture looks fine" without listing specific signals checked

## HISTORICAL COHERENCE ANALYSIS (MANDATORY — complete before Pre-Mortem)
For each affected file/module, examine recent git history to ensure the proposed changes do not defeat, reverse, or undermine past intentional work:

1. **Gather history**: Run `git log -p --follow -n 20` on each affected file. Focus on commits from the last 3-6 months that touched the same code areas.
2. **Identify past decisions**: Extract intentional architectural or behavioral changes from commit messages and diffs — refactors, pattern introductions, constraint additions, bug fixes, performance improvements, deliberate design choices.
3. **Cross-reference**: For each past decision, check whether the current diff/plan:
   - **Reverts** it (reintroduces code/patterns that were deliberately removed)
   - **Contradicts** it (introduces a pattern the past commit explicitly moved away from)
   - **Undermines** it (weakens a constraint, guard, or invariant that was deliberately added)
   - **Conflicts with its intent** (achieves a goal that is at odds with what the past change was trying to accomplish)
4. **Report format** for each conflict found:
   - **Past commit**: `<hash> — <message summary>` with date
   - **What it did**: one sentence describing the intentional change
   - **How current change defeats it**: specific lines/patterns that conflict
   - **Severity**: CRITICAL (directly reverts), HIGH (contradicts intent), MEDIUM (weakens but doesn't break)
5. If no conflicts found, state: "No historical conflicts — checked N commits across M files. Key past decisions reviewed: [list 2-3 most relevant commits and why they're compatible]"

FORBIDDEN: Skipping this section. FORBIDDEN: Claiming "no conflicts" without citing specific commits reviewed.


Assume it is 6 months from now and this change has caused a production incident or a major refactoring effort. Generate exactly 3 independent failure scenarios:
1. A failure caused by something IN the diff/plan
2. A failure caused by an INTERACTION between this change and existing code
3. A failure caused by a REASONABLE FUTURE CHANGE that this diff makes harder

For each: one sentence describing the failure, one sentence identifying which file/module is the point of failure.
Then use these scenarios to guide your Review Dimensions analysis — prioritize dimensions that relate to your failure scenarios.

## REVIEW ORDER (MANDATORY)
Assess dimensions in this order. Never skip to later items while earlier ones are unexamined:
Historical Coherence → Correctness → Error Handling → Skill Compliance → Side Effects → Coupling → Cohesion → Expandability → Consistency → Abstraction Level

## Review Dimensions

1. **Coupling Analysis**: Do the changes increase coupling between modules? Are dependencies flowing in the right direction? Use Grep to verify import graphs if needed.
2. **Cohesion Check**: Do modified modules still have a single, clear responsibility? Or are concerns bleeding across boundaries?
3. **Expandability**: If someone needed to extend this feature 6 months from now, would these changes make that easier or harder? Identify any dead-ends or rigid patterns.
4. **Consistency**: Do the changes follow existing patterns in the codebase, or do they introduce a new pattern without migrating existing code? Check naming, file structure, abstraction levels.
5. **Abstraction Level**: Are the right abstractions in place? Too many layers? Too few? Leaky abstractions?
6. **Side Effects**: Could these changes break or subtly affect unrelated parts of the system?
7. **Skill Compliance**: If Project Domain Knowledge was provided — does the diff/plan follow the documented patterns and constraints? For each relevant skill: check whether the change violates, correctly applies, or is neutral to the skill's patterns. Cite the skill name + specific constraint in findings. If no domain knowledge was provided, output: "No project skills available — skipped."

## PRO/CON BALANCE (MANDATORY)
For every finding, you MUST also acknowledge what the change does WELL architecturally.
- If the change makes a good architectural decision, say so explicitly with evidence.
- NEGATIVE finding → must name what you'd lose by reverting (the benefit the change provides)
- POSITIVE finding → must name the strongest risk it introduces
Never present concerns as minor footnotes. Genuinely challenge your own findings.

## CONFIDENCE CALIBRATION
For each finding, append a confidence tag:
- [HIGH]: You verified the claim by reading code, checking imports, or grepping patterns (3+ data points)
- [MEDIUM]: Based on diff context + 1-2 verified signals, one minor uncertainty noted
- [LOW]: Based primarily on the diff without broader verification — downgrade severity automatically
If you cannot cite specific files/lines supporting a finding, it must be [LOW].

## SOURCE CITATION
For every claim, cite the evidence:
- Format: "increases coupling [src/module/foo.ts:42 imports from bar]" or "follows existing pattern [verified via Grep: 12 files use same approach]"
- Mark any inferred claims with [INFERRED]

## INSUFFICIENT CONTEXT RULE
If the diff/plan does not provide enough information to assess a dimension:
  output: "INSUFFICIENT CONTEXT — [what's missing, what you'd need to read/verify]"
Do NOT speculate or generate plausible-sounding architectural concerns from general knowledge.
A skipped dimension is better than a fabricated concern.

## Output Format

For each finding:
- **Classification**: Risk | Sensitivity Point | Tradeoff Point
  - Risk: a decision that could cause architectural harm under expected conditions
  - Sensitivity Point: a parameter/decision where small changes cause large quality-attribute swings
  - Tradeoff Point: a decision that simultaneously affects 2+ quality attributes in opposing directions (HIGHEST VALUE — always surface these)
- **Issue**: What's wrong [CONFIDENCE]
- **Evidence**: file:line or grep results that support this claim
- **What it does well**: The architectural benefit this change provides
- **Impact**: What happens if left as-is (6-month view)
- **Suggestion**: Concrete alternative approach with code snippet or diff showing the change. NO abstract-only suggestions — if you cannot write the code, downgrade confidence.

If no concerns found for a dimension, state: "No concerns — [brief evidence why]"

## Verdict
- ✅ PASS — all dimensions checked, no [HIGH] or [MEDIUM] concerns
- ⚠️ CONCERNS — one or more [MEDIUM]+ concerns that should be addressed
- ❌ RETHINK — any [HIGH] concern that indicates fundamental architectural issue

## VERIFICATION STEP
After generating your analysis:
1. Re-read each finding
2. Can you trace every claim to a specific file, line, or grep result?
3. Remove or flag any claim that failed verification with [UNVERIFIED]
4. If >30% of findings are [LOW] or [UNVERIFIED]: note this in your verdict
```

<good_example>
### Coupling Analysis
**Issue**: PaymentService now imports UserPreferences directly, bypassing the existing UserService facade. 3 other modules (OrderService, NotificationService, BillingService) access user preferences through UserService. This creates a second access path. [HIGH]
**Evidence**: src/services/payment.ts:15 adds `import { UserPreferences } from '@/models/user'`. Grep confirms 3 modules use `UserService.getPreferences()` — src/services/order.ts:8, src/services/notification.ts:12, src/services/billing.ts:22.
**What it does well**: Direct access avoids an unnecessary indirection layer and is faster for the payment hot path.
**Impact**: 6 months out, any change to UserPreferences schema requires updating both the facade and the direct import path. Likely source of drift.
**Suggestion**: Add a `getPreferences()` method to PaymentService that delegates to UserService:
```ts
// src/services/payment.ts
- import { UserPreferences } from '@/models/user';
+ import { UserService } from '@/services/user';

class PaymentService {
+   private getPreferences(userId: string) {
+     return UserService.getPreferences(userId);
+   }
}
```
This preserves the single access pattern while keeping payment-specific logic local.

<reasoning>
Good because: cites specific files and line numbers, acknowledges the benefit (performance), quantifies the concern (3 other modules), provides a concrete code diff as alternative.
</reasoning>
</good_example>

<good_example>
### Historical Coherence Analysis
**Past commit**: `a3f8c2d — refactor: extract validation into shared middleware` (2026-01-15)
**What it did**: Moved input validation from individual route handlers into a shared Express middleware to enforce consistent validation at a single boundary.
**How current change defeats it**: The new endpoint in src/routes/upload.ts:28-45 adds inline validation (`if (!req.body.name) return res.status(400)...`) instead of using the shared middleware at src/middleware/validate.ts. This reintroduces the exact pattern the January refactor eliminated.
**Severity**: HIGH — contradicts an intentional architectural decision.
**Evidence**: `git log --all --oneline src/middleware/validate.ts` shows 3 subsequent commits building on the shared validation pattern. Grep confirms 12/13 routes use middleware; only the new route bypasses it.
**Suggestion**: Wire the new route through the existing validation middleware:
```ts
// src/routes/upload.ts
- router.post('/upload', async (req, res) => {
-   if (!req.body.name) return res.status(400).json({ error: 'name required' });
+ import { validateBody } from '@/middleware/validate';
+ router.post('/upload', validateBody(['name', 'file']), async (req, res) => {
```

<reasoning>
Good because: cites the specific past commit, explains what it intended, shows exactly how the current change reverses it, checks that subsequent work built on the pattern, and provides a concrete fix.
</reasoning>
</good_example>

<bad_example>
### Coupling Analysis
**Issue**: The changes increase coupling between modules. [HIGH]
**Impact**: This could cause problems in the future.
**Suggestion**: Consider reducing coupling.

<reasoning>
Bad because: no evidence cited, no specific files or lines, vague impact, generic suggestion with no code snippet or diff, confidence marked HIGH without any verification, no acknowledgment of what the change does well, no ATAM classification.
</reasoning>
</bad_example>

---

### Agent 2: Root Cause & Systematic Resolution Reviewer

Prompt template:
```
## Methodology (READ FIRST)
Before doing anything else, read /Users/brian.pham/.claude/skills/diagnose/references/methodology.md in full. That file defines your role (principal engineer, skeptical auditor), the disconfirmation rule, constraints, review order, and the complete framework you must apply:
- Problem Framing Challenge
- Conflict Detection
- Root Cause Trace (Iterative Deepening, with Bedrock Test + Removal/Recurrence/Sufficiency validation)
- Defect Class Identification (abstract naming + pattern-based sibling search)
- Completeness, Regression Surface, Test Coverage, Duplication & Reuse
- Pro/Con Balance (per finding)
- Confidence Calibration ([HIGH]/[MEDIUM]/[LOW])
- Source Citation
- Root Cause Self-Challenge (devil's advocate)
- Verification Step (Chain-of-Verification)

Apply EVERY section of that methodology to the context below. Do not skip dimensions. Do not substitute your own shortcuts.

## Context
{paste the plan OR git diff here}

## Affected Files
{list affected files/modules}

## Project Domain Knowledge
{knowledge_context}

Use this domain knowledge to deepen your root cause analysis. When tracing causal chains, check whether the root cause connects to a violation of a documented skill pattern or project rule. When searching for sibling instances, use skill-documented patterns to guide your Grep queries. Cite skill names as evidence when relevant.

## Challenge-Specific Output Format

Render findings using exactly this structure so the challenge synthesis step can merge them with Agent 1's output:

For each finding:
- **Issue**: What's wrong [CONFIDENCE]
- **Causal Chain**: symptom → ... → root cause (show the FULL deepened chain from the methodology's Iterative Deepening — not a one-line summary)
- **Defect Class**: [CATEGORY]: [abstract description]
- **Evidence**: file:line references, grep results, or code snippets
- **What it does well**: The systematic benefit this fix provides (Pro/Con Balance)
- **Suggestion**: How to fix it at a deeper level, with specific locations AND a code snippet or diff showing the fix. NO abstract-only suggestions — if you cannot write the code, downgrade confidence.

If no concerns found for a dimension, state: `No concerns — [brief evidence why]`

## Verdict
- ✅ SYSTEMATIC — fix addresses root cause, sibling instances checked, recurrence prevented
- ⚠️ PARTIAL FIX — fix addresses root cause but misses sibling instances or lacks recurrence prevention
- ❌ PATCH-ONLY — fix targets a symptom; same defect class will recur

If >30% of findings are [LOW] or [UNVERIFIED] after the methodology's Verification Step: note this in your verdict and lean toward ⚠️ or ❌.
```

See `/Users/brian.pham/.claude/skills/diagnose/references/methodology.md` for the worked example of a Root Cause Trace done well (and a bad one) — Agent 2 will read it as part of the methodology.

---

## Step 3: Synthesize Results

After both agents complete:

1. Collect both verdicts and confidence levels
2. **Discard [UNVERIFIED] and [LOW] findings** — do not include them in the report unless they represent a potentially critical concern worth flagging
3. Merge overlapping concerns (deduplicate) — if both agents flagged the same area, combine their evidence
4. Prioritize by severity × confidence: ❌ [HIGH] blockers first, then ⚠️ [HIGH/MEDIUM] concerns
5. **Detect conflicts between the two agents** — if Agent 1 says "good abstraction" but Agent 2 says "over-abstraction hides the root cause", surface this explicitly
6. **False Consensus Check** — If both agents reached positive verdicts (PASS + SYSTEMATIC) AND neither has any [MEDIUM]+ concerns:
   - Flag this explicitly: "Both agents agree this is clean. Applying extra scrutiny."
   - Re-examine the 3 highest-risk areas of the diff for anything both agents may have normalized or overlooked.
   - If nothing new is found, note: "False consensus check completed — agreement appears genuine."
   - If something is found, add it as a new finding with tag [CONSENSUS-BLIND-SPOT].
7. Present a unified challenge report:

```
## Challenge Report

### Architectural Fitness: {verdict}
{[HIGH] and [MEDIUM] findings only, with evidence citations}

### Systematic Resolution: {verdict}
{[HIGH] and [MEDIUM] findings only, with causal chains}

### Cross-Agent Conflicts
{any disagreements between the two reviewers — stated explicitly with both sides}

### False Consensus Check
{result of the false consensus check — "N/A" if agents disagreed, otherwise the outcome}

### What the Changes Do Well
{consolidated list of architectural and systematic strengths identified by both agents}

### Action Items
1. ❌ [HIGH] Description — suggestion (file:line)
2. ⚠️ [MEDIUM] Description — suggestion (file:line)
...

### Skill Compliance
{findings related to project skill patterns or CLAUDE.md rules — "N/A" if no domain knowledge was available}

### Insufficient Context Areas
{dimensions either agent could not assess — what would be needed}

### Overall Verdict: {PASS | REVISE | RETHINK}
- PASS: no [HIGH] concerns, ≤2 [MEDIUM] concerns
- REVISE: one or more [MEDIUM]+ concerns with clear fix paths
- RETHINK: any [HIGH] concern indicating fundamental issue
```

7. Use `AskUserQuestion` to present the report and ask whether to proceed, revise, or rethink.
