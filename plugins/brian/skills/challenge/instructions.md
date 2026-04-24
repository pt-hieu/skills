# Challenge — Execution Guide

Fire 2 independent opus subagents in parallel to stress-test a plan or implementation. Both agents challenge whether the changes keep the architecture healthy, expandable, and maintainable — and whether they fix root causes vs patch symptoms.

The reviewers are first-class plugin agents:
- `brian:architectural-reviewer` — coupling, cohesion, historical coherence, expandability
- `brian:root-cause-reviewer` — iterative-deepening RCA, defect class identification, sibling-instance search

Their system prompts live in `plugins/brian/agents/`. This skill orchestrates context assembly, parallel invocation, and synthesis.

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

## Step 2: Launch Both Reviewers in Parallel

Invoke `brian:architectural-reviewer` and `brian:root-cause-reviewer` via the `Agent` tool. Both calls MUST be emitted as two tool-use blocks in the **same assistant message** (not sequential messages) so they run concurrently. Each call uses `model: "opus"` and `run_in_background: true`.

The `prompt` parameter of each call is identical and contains only the three dynamic sections below — the methodology, review dimensions, output format, and examples all live in the agent definitions:

```
## Context
{paste the plan OR git diff here}

## Affected Files
{list affected files/modules}

## Project Domain Knowledge
{knowledge_context}
```

Do not re-embed any agent-definition content in the `prompt`.

---

## Step 3: Synthesize Results

Each agent uses its own verdict enum — map them into the final report's enum:

| Agent | Positive | Concerning | Fundamental issue |
|---|---|---|---|
| `architectural-reviewer` | ✅ PASS | ⚠️ CONCERNS | ❌ RETHINK |
| `root-cause-reviewer` | ✅ SYSTEMATIC | ⚠️ PARTIAL FIX | ❌ PATCH-ONLY |
| Final `Overall Verdict` | PASS | REVISE | RETHINK |

After both agents complete:

1. Collect both verdicts and confidence levels.
2. **Discard `[UNVERIFIED]` and `[LOW]` findings** — do not include them in the report unless they represent a potentially critical concern worth flagging.
3. Merge overlapping concerns (deduplicate) — if both agents flagged the same area, combine their evidence.
4. Prioritize by severity × confidence: ❌ `[HIGH]` blockers first, then ⚠️ `[HIGH/MEDIUM]` concerns.
5. **Detect conflicts between the two agents** — if architectural-reviewer says "good abstraction" but root-cause-reviewer says "over-abstraction hides the root cause", surface this explicitly.
6. **False Consensus Check** — If both agents reached positive verdicts (PASS + SYSTEMATIC) AND neither has any `[MEDIUM]+` concerns:
   - Flag this explicitly: "Both agents agree this is clean. Applying extra scrutiny."
   - Re-examine the 3 highest-risk areas of the diff for anything both agents may have normalized or overlooked.
   - If nothing new is found, note: "False consensus check completed — agreement appears genuine."
   - If something is found, add it as a new finding with tag `[CONSENSUS-BLIND-SPOT]`.
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

---

## Step 4: Present the Report

Use `AskUserQuestion` to present the report and ask whether to proceed, revise, or rethink.
