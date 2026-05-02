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
| 2.5 Diagnose (bug path) | `brian:diagnose` | medium | `opus` |
| 5 Plan | `Plan` (×1) | high | `opus` |
| 6 Challenge | reviewer subagents | medium | `opus` |

For Step 6, the `brian:challenge` orchestrator spawns its reviewers on `opus` — keep that, but request **medium thinking effort** for those subagents so they stay focused without burning the budget.

---

## Step 1 — Enter plan mode

- **Goal**: ensure planning happens in plan mode.
- **Action**: when already in plan mode, continue. Otherwise call the `EnterPlanMode` tool to enter it directly.
- **Gate**: plan mode is active.

---

## Step 2 — Explore (Phase 1)

- **Goal**: ground the plan in real code.
- **Action**:
  - For **bugs / regressions / "why is X broken"**: invoke `brian:diagnose` via the `Skill` tool to drive root-cause exploration. `brian:diagnose` produces a root cause + defect class + fix-shape suggestion; treat that output as **Phase-1 findings**, not as a finished design. The Plan agent in Step 5 still runs and consumes the diagnose output as input.
  - For everything else: launch up to 3 `Explore` subagents in parallel, each scoped to a specific search area (existing implementations, related components, tests/patterns, etc.).
  - Use `model: "haiku"` for each Explore subagent — these are scoped lookups; reserve heavier models for design.
- **Gate**: concrete file paths, reusable utilities, and existing patterns (or root cause + defect class on the bug path) are in hand.

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

## Step 5 — Plan agent (Phase 2) — HARD GATE

- **Goal**: produce a detailed implementation plan from a focused designer.
- **Action**: launch ONE `Plan` subagent at high effort (`model: "opus"`). Hand it:
  - Phase-1 findings (file paths, traces, reusable utilities; on the bug path this includes the `brian:diagnose` root cause + defect class + suggested fix shape)
  - Requirements and constraints
  - Skill-scan output and any skill-derived patterns to follow
  - Architecture decisions confirmed in Step 3
- **Gate**: a detailed implementation plan is returned **from the Plan agent**. Only a Plan-agent return clears this gate — coherence in the orchestrator's head does not substitute. Diagnose output is not a Plan-agent substitute. Plan-agent latency (~2–3 min on opus) is the price of catching the cross-file synthesis issues challengers will otherwise raise as HIGH findings.

---

## Step 6 — Challenge

- **Pre-flight self-check (MANDATORY)**: before invoking challenge, answer in one line: *"Did the plan I'm about to challenge come from a Plan-agent return, or did I write it myself?"* If self-written, return to Step 5 and run the Plan agent. Challenge tests the plan, not the orchestrator's intuitions.
- **Goal**: catch missed details and weak spots before pitching.
- **Action**: invoke `brian:challenge` on the **Plan-agent output** (revised with Step 3 architecture decisions and skill-scan constraints). Run its spawned reviewer subagents on `opus` at **medium thinking effort** (not high). Revise the plan with each round of feedback until challengers pass or any remaining red flag is explicitly accepted in writing inside the plan file.
- **Gate**: challenge round complete and the plan has been updated.

---

## Step 7 — Write the final plan file

- **Goal**: leave a self-sustained artifact for execution. *The implementer reads this file in a fresh context with zero memory of this conversation; everything they need lives in the file.*
- **Action**: write the plan file specified by the plan-mode system prompt with these sections, in order:
  - **Context** — one continuous narrative covering:
    - the requirement in concrete terms (what the change is),
    - where it came from (ticket id, user ask, bug report, link or quote),
    - why it is being made (the problem solved, the user or business motivation),
    - the Phase-1 findings that justify the chosen approach — inline them. On the bug path include the root cause and defect class from `brian:diagnose`. On the feature path include the existing patterns, call sites, and constraints surfaced by Explore. Write enough that a fresh agent understands the goal and the evidence from this file alone.
  - **Recommended approach** — the chosen path.
  - **Critical file paths** — every file that will change, absolute paths.
  - **Reused utilities** — existing functions, helpers, or patterns this builds on, each with its path.
  - **Verification** — how to confirm the change works end-to-end (commands, manual steps, or test names).
  - **Post-implementation protocol** (verbatim executor contract — keep wording byte-identical when copying):

    > **Post-implementation protocol (kickoff v1)**
    > 1. After implementation is complete, run the `simplify` skill on the diff to prune over-engineering and surface reuse opportunities.
    > 2. Surface the diff and a short summary in chat, then wait for Brian's explicit approval before running `git add`, `git commit`, `git push`, or any PR/MR action.
- **Gate**: re-read the written plan file end-to-end and confirm in chat:
  (a) Context names the requirement source verbatim or by quote (ticket id, user-ask quote, or bug-report link),
  (b) Context inlines at least one Phase-1 finding (root cause + defect class for bugs; a named existing pattern with file path for features),
  (c) Post-implementation protocol block is present byte-identical to the version above, including the `(kickoff v1)` stamp.
  Confirm all three checks pass, then advance to Step 8; fix any that fail first.

  When the protocol block changes in the future, bump `v1 → v2` here in the same commit. Previously written plan files keep their frozen earlier-version copy — the stamp surfaces which revision a plan was generated against.

---

## Step 8 — Pitch

- **Goal**: give the user a plain-language preview before exit.
- **Action**: invoke `voice:pitch` via the `Skill` tool to post the chat-reply pitch.
- **Gate**: pitch is posted.

---

## Step 9 — ExitPlanMode

- **Goal**: hand the plan back for technical-detail review.
- **Action**: call `ExitPlanMode`.
