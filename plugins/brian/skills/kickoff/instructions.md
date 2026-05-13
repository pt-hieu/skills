# Kickoff — Execution Guide

Deterministic pipeline for taking a new requirement from intake to a green-lit, pitched plan ready for implementation.

**Execution model**: instead of trying to remember an 11-step pipeline in-prompt, the agent's **first action** is to register every step as a task via `TaskCreate`. The `TaskList` then becomes the working memory — nothing gets skipped, because skipping shows up as a pending task. The agent picks up tasks in ID order, marks `in_progress` before starting, marks `completed` only when the task's gate passes.

## Hard rules

- **Step 0 is mandatory and runs first.** Register all kickoff tasks before doing any planning work. If `TaskList` already contains kickoff tasks for this requirement, skip Step 0 and resume from the lowest-ID pending task.
- Work tasks in ID order. Each task's description contains its **Goal / Action / Gate** — advance only when the gate passes.
- When a gate cannot be passed, leave the task `in_progress`, post one line to chat explaining the blocker, and wait.
- The skill-scan task must be executed even when no skill applies — write down the scan output before completing it.
- Treat this skill as the source of truth for the workflow — when CLAUDE.md drifts, follow this skill until they reconcile.

## Effort matrix

Set spawned-subagent models per task. The harness exposes the model via the `Agent` tool's `model` parameter.

| Task | Subagent | Effort | Model |
| --- | --- | --- | --- |
| 2 Explore | `Explore` (×1–3) | low | `haiku` |
| 2 Diagnose (bug path) | `brian:diagnose` | medium | `opus` |
| 3 Historian | `code-historian` | medium | `sonnet` |
| 6 Plan | `Plan` (×1) | high | `opus` |
| 8 Challenge | reviewer subagents | medium | `opus` |
| 10 Protocol-injector | `protocol-injector` | trivial | `haiku` |

For the Challenge task, the `brian:challenge` orchestrator spawns its reviewers on `opus` — keep that, but request **medium thinking effort** for those subagents so they stay focused without burning the budget.

---

## Step 0 — Register the pipeline as tasks (FIRST ACTION)

- **Goal**: turn the pipeline into a checklist the harness enforces.
- **Action**: in a single message, call `TaskCreate` once per task below, in order. Use the **subject** and **description** verbatim — the description carries the Goal / Action / Gate the agent needs to execute that task. After creation, call `TaskUpdate` to wire `addBlockedBy` so each task is blocked by the previous one (1←2←3…←11). Then call `TaskList`, claim Task 1, and begin.
- **Gate**: `TaskList` shows tasks 1–11 in `pending`, dependencies wired, and Task 1 is claimed `in_progress`.

### Tasks to register

Register each entry below as one `TaskCreate` call. Copy the description verbatim — it is what future-you will read when picking up the task.

---

**Task 1 — Enter plan mode**

- subject: `Enter plan mode`
- description:
  > **Goal**: ensure planning happens in plan mode.
  > **Action**: when already in plan mode, continue. Otherwise call the `EnterPlanMode` tool.
  > **Gate**: plan mode is active.

---

**Task 2 — Explore (Phase 1 findings)**

- subject: `Explore — gather Phase-1 findings`
- description:
  > **Goal**: ground the plan in real code.
  > **Action**:
  > - For **bugs / regressions / "why is X broken"**: invoke `brian:diagnose` via the `Skill` tool to drive root-cause exploration. Treat its output (root cause + defect class + fix-shape suggestion) as **Phase-1 findings**, not as a finished design. The Plan-agent task still runs and consumes this as input.
  > - For everything else: launch up to 3 `Explore` subagents in parallel, each scoped to a specific search area (existing implementations, related components, tests/patterns, etc.). Use `model: "haiku"` — these are scoped lookups; reserve heavier models for design.
  > **Gate**: concrete file paths, reusable utilities, and existing patterns (or root cause + defect class on the bug path) are written down.

---

**Task 3 — Historian (gather "why" from git + tickets)**

- subject: `Historian — gather prior intent from git history and ticket tracker`
- description:
  > **Goal**: surface the *why* behind prior changes to the code about to be modified, so the implementer doesn't repeat past failures or invert past decisions blindly.
  > **Action**: invoke the `code-historian` subagent via the `Agent` tool with `subagent_type: "code-historian"`, `model: "sonnet"`. Pass it:
  > - The file paths surfaced in the Explore task (preferred input).
  > - The topic / area description as fallback when paths are partial.
  > - A focusing question derived from the requirement (e.g. *"why does this module handle X this way?"*).
  >
  > The agent auto-detects the ticket tracker (Jira / Linear / Bitbucket PRs) from commit-message patterns, remotes, and `CLAUDE.md` — do not hand it a tracker choice.
  > **Gate**: historian report is in hand, including a timeline of meaningful commits, linked tickets with verbatim "why" quotes (or an explicit "no tracker / no linked tickets" note), recurring themes, and implications for the current change.

---

**Task 4 — Interrogate (architecture-level only)**

- subject: `Interrogate — close architecture-level ambiguity`
- description:
  > **Goal**: close any gap that would change the chosen approach.
  > **Action**: focus on **architecture- and approach-level** questions only — direction, trade-offs, scope boundaries, integration choices. Trust the Plan agent to handle implementation detail later. Use the report from the Historian task to inform which questions matter — prior failures or constraints surfaced there often *are* the architecture questions.
  > - 1–3 questions max in a single batched `AskUserQuestion` call.
  > - Skip the task entirely (mark completed with a one-line note "no architecture ambiguity") when the requirement is already unambiguous.
  > **Gate**: remaining unknowns will not change the chosen approach.

---

**Task 5 — Skill scan (the task most often missed)**

- subject: `Skill scan — enumerate and apply`
- description:
  > **Goal**: ensure every applicable skill informs the plan before designing.
  > **Action**:
  > 1. Enumerate every skill in the current system reminder's available-skills list, plus any project skills under `.claude/skills/` and `<git-root>/plugins/*/skills/`.
  > 2. Write one line per skill: `skill-name: relevant? (yes/no — one-sentence reason)`. Post the list to chat or save it in the plan scratch area.
  > 3. Invoke each skill marked relevant, in order, via the `Skill` tool.
  > Common matches: `brian:prompting` (LLM prompts/schemas), `claude-api` (Anthropic SDK), `neon:neon-postgres` (Neon), design skills (UI), `brian:commit` (later, out of kickoff scope).
  > **Gate**: scan written down and every relevant skill applied.

---

**Task 6 — Plan agent (HARD GATE)**

- subject: `Run Plan agent — produce detailed implementation plan`
- description:
  > **Goal**: produce a detailed implementation plan from a focused designer.
  > **Action**: launch ONE `Plan` subagent at high effort (`model: "opus"`). Hand it:
  > - Phase-1 findings (file paths, traces, reusable utilities; on the bug path include `brian:diagnose` root cause + defect class + suggested fix shape)
  > - Historian report (prior intent, recurring themes, implications)
  > - Requirements and constraints
  > - Skill-scan output and any skill-derived patterns to follow
  > - Architecture decisions confirmed in the Interrogate task
  >
  > **Persist the Plan-agent return verbatim before continuing.** As soon as the Plan agent returns, write its full output to the plan file path specified by the plan-mode system prompt (create the file if absent). This is the raw artifact — Task 7 will restructure it into the final sections. Do not advance to Task 7 until the file exists on disk and contains the Plan agent's return.
  > **Gate**: a detailed implementation plan is returned **from the Plan agent** and its verbatim output has been written to the plan file on disk. Only a Plan-agent return clears this gate — coherence in the orchestrator's head does not substitute. Diagnose output is not a Plan-agent substitute. Plan-agent latency (~2–3 min on opus) is the price of catching cross-file synthesis issues.

---

**Task 7 — Write the plan file**

- subject: `Write the plan file`
- description:
  > **Goal**: leave a self-sustained artifact on disk *before* Challenge runs, so reviewer subagents can read the same artifact the implementer will. *The implementer reads this file in a fresh context with zero memory of this conversation; everything they need lives in the file.*
  > **Action**: the plan file already exists on disk with the Plan agent's verbatim return (persisted at the end of Task 6). Restructure that file in place into the sections below, in order — do not discard Plan-agent content; reorganize and enrich it:
  > - **Context** — one continuous narrative covering: the requirement in concrete terms; where it came from (ticket id, user ask, bug report, link or quote); why it is being made; the Phase-1 findings that justify the chosen approach — inline them. Bug path: include root cause + defect class from `brian:diagnose`. Feature path: include existing patterns, call sites, and constraints surfaced by Explore.
  > - **Prior intent** — inline the historian's recurring themes and implications, with commit-hash and ticket-key anchors. Quote prior decisions verbatim.
  > - **Recommended approach** — the chosen path.
  > - **Critical file paths** — every file that will change, absolute paths.
  > - **Reused utilities** — existing functions, helpers, or patterns this builds on, each with its path.
  > - **Skills to use** — every skill the implementer must invoke during execution, taken from the Skill-scan task's output. List one bullet per relevant skill in the form `skill-name — when to invoke it and what it contributes`. Include skills that apply during implementation (e.g. `brian:prompting`, `claude-api`, design skills) and skills that apply at handoff (e.g. `brian:commit`, `voice:pr`). If the scan found no applicable skills, write `None — skill scan returned no matches` so the implementer knows the scan was performed.
  > - **Verification** — how to confirm the change works end-to-end (commands, manual steps, or test names).
  >
  > End the file at **Verification**. The `protocol-injector` subagent appends the post-implementation protocol in the Inject task — leave room for it. Challenge (Task 8) will revise this file in place; that's expected.
  > **Gate**: re-read the written plan file end-to-end and confirm in chat:
  > (a) Context names the requirement source verbatim or by quote (ticket id, user-ask quote, or bug-report link),
  > (b) Context inlines at least one Phase-1 finding (root cause + defect class for bugs; a named existing pattern with file path for features),
  > (c) Prior intent section is present with commit-hash and/or ticket-key anchors,
  > (d) Skills-to-use section lists every skill marked relevant in the Skill-scan task (or explicitly states `None` when the scan found no matches).
  > Confirm all checks pass before completing this task; fix any that fail first.

---

**Task 8 — Challenge**

- subject: `Challenge the plan file`
- description:
  > **Pre-flight self-check (MANDATORY)**: answer in one line: *"Does the plan file on disk reflect the Plan-agent return, or did I write it myself?"* If self-written, reopen the Plan-agent task and run the Plan agent, then rewrite the plan file. Challenge tests the plan, not the orchestrator's intuitions.
  > **Goal**: catch missed details and weak spots before pitching.
  > **Action**: invoke `brian:challenge` via the `Skill` tool, passing **the absolute path of the plan file written in Task 7** so reviewer subagents read the same artifact the implementer will. Run its reviewer subagents on `opus` at **medium thinking effort** (not high). Revise the plan **file in place** with each round of feedback until challengers pass or any remaining red flag is explicitly accepted in writing inside the plan file.
  > **Gate**: challenge round complete and the plan file on disk has been updated.

---

**Task 9 — Pitch**

- subject: `Pitch the plan to Brian`
- description:
  > **Goal**: give the user a plain-language preview before exit.
  > **Action**: invoke `voice:pitch` via the `Skill` tool to post the chat-reply pitch.
  > **Gate**: pitch is posted.

---

**Task 10 — Inject post-implementation protocol**

- subject: `Inject post-implementation protocol into plan file`
- description:
  > **Goal**: ensure the plan file ends with the canonical post-implementation protocol block before handoff.
  > **Action**: invoke the `protocol-injector` subagent via the `Agent` tool with `subagent_type: "protocol-injector"`. Pass the absolute path of the plan file written in Task 7 (and revised through Challenge). The agent is idempotent — it appends the canonical block if absent, or reports `already present` if the block is already there.
  > **Gate**: subagent reports `injected` or `already present`. Spot-check the tail of the plan file to confirm the `## Post-implementation protocol` block is the final section.

---

**Task 11 — ExitPlanMode**

- subject: `ExitPlanMode`
- description:
  > **Goal**: hand the plan back for technical-detail review.
  > **Action**: call `ExitPlanMode`.
  > **Gate**: plan mode exited.
