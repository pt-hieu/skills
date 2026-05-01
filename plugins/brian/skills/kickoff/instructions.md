# Kickoff — Execution Guide

Deterministic pipeline for taking a new requirement from intake to a green-lit, pitched plan ready for implementation. Every step has a **Goal**, an **Action**, and a **Gate**: advance only when the gate passes.

## Hard rules

- Run the steps in order; treat each gate as the entry condition for the next step.
- Pause and tell the user what is blocking when a gate cannot be passed.
- Always perform the skill scan in Step 4, even when no skill applies.
- Treat this skill as the source of truth for the workflow — when CLAUDE.md drifts, follow this skill until they reconcile.

## Effort matrix

Set spawned-subagent models per step. The harness exposes the model via the `Agent` tool's `model` parameter.

| Step | Subagent | Effort | Model |
| --- | --- | --- | --- |
| 2 Explore | `Explore` (×1–3) | low | `haiku` |
| 5 Plan | `Plan` (×1) | high | `opus` |
| 6 Challenge | reviewer subagents | medium | `opus` |

For Step 6, the `brian:challenge` orchestrator spawns its reviewers on `opus` — keep that, but request **medium thinking effort** (not high) for those subagents so they stay focused without burning the budget.

---

## Step 1 — Enter plan mode

- **Goal**: ensure planning happens in plan mode.
- **Action**: when already in plan mode, continue. Otherwise call the `EnterPlanMode` tool to enter it directly.
- **Gate**: plan mode is active.

---

## Step 2 — Explore (Phase 1)

- **Goal**: ground the plan in real code.
- **Action**:
  - For **bugs / regressions / "why is X broken"**: invoke `brian:diagnose` via the `Skill` tool to drive root-cause exploration.
  - For everything else: launch up to 3 `Explore` subagents in parallel, each scoped to a specific search area (existing implementations, related components, tests/patterns, etc.).
  - Use `model: "haiku"` for each Explore subagent — these are scoped lookups; reserve heavier models for design.
- **Gate**: concrete file paths, reusable utilities, and existing patterns are in hand.

---

## Step 3 — Interrogate (high-level, when ambiguity remains)

- **Goal**: close any gap that would change the chosen approach.
- **Action**: focus on **architecture- and approach-level** questions only — direction, trade-offs, scope boundaries, integration choices. Trust the Plan agent to handle implementation-detail questions later. Use judgement on count and timing:
  - 1–3 questions max in a single batched `AskUserQuestion` call.
  - Default placement is here (post-explore) so questions are informed by code evidence; ask earlier when the requirement was clearly unclear from the start.
  - Skip the step entirely when the requirement is already unambiguous at the architecture level.
- **Gate**: remaining unknowns are small enough that they will not change the chosen approach.

---

## Step 4 — Skill scan (the step most often missed)

- **Goal**: ensure every applicable skill informs the plan before designing.
- **Action**:
  1. Enumerate every skill in the current system reminder's available-skills list, plus any project skills under `.claude/skills/` and `<git-root>/plugins/*/skills/`.
  2. Write one line per skill: `skill-name: relevant? (yes/no — one-sentence reason)`.
  3. Invoke each skill marked relevant in order, via the `Skill` tool.
  - Common matches:
    - `brian:prompting` for LLM prompt or schema work
    - `claude-api` for Anthropic SDK code
    - `neon:neon-postgres` for Neon work
    - `design` skills for UI changes
    - `brian:commit` later when committing (out of kickoff scope)
- **Gate**: scan is written down (in the plan file scratch area or a chat block) and every relevant skill has been applied.

---

## Step 5 — Plan agent (Phase 2)

- **Goal**: produce a detailed implementation plan from a focused designer.
- **Action**: launch ONE `Plan` subagent at high effort (`model: "opus"`). Hand it:
  - Phase-1 findings (file paths, traces, reusable utilities)
  - Requirements and constraints
  - Skill-scan output and any skill-derived patterns to follow
  - Architecture decisions confirmed in Step 3
- **Gate**: a detailed implementation plan is returned.

---

## Step 6 — Challenge

- **Goal**: catch missed details and weak spots before pitching.
- **Action**: invoke `brian:challenge` on the plan. Run its spawned reviewer subagents on `opus` at **medium thinking effort** (not high). Revise the plan with each round of feedback until challengers pass or any remaining red flag is explicitly accepted in writing inside the plan file.
- **Gate**: challenge round complete and the plan has been updated.

---

## Step 7 — Write the final plan file

- **Goal**: leave a high-quality artifact for execution.
- **Action**: write the plan file specified by the plan-mode system prompt with sections for:
  - **Context** — why this change is being made
  - **Recommended approach** — only the chosen path, not alternatives
  - **Critical file paths** — what will change
  - **Reused utilities** — existing functions/patterns this builds on (with paths)
  - **Verification** — how to test the change end-to-end

---

## Step 8 — Pitch

- **Goal**: give the user a plain-language preview before exit.
- **Action**: invoke `voice:pitch` via the `Skill` tool to post the chat-reply pitch.
- **Gate**: pitch is posted.

---

## Step 9 — ExitPlanMode

- **Goal**: hand the plan back for technical-detail review.
- **Action**: call `ExitPlanMode`.
