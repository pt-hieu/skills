---
name: kickoff
description: "Use when /kickoff is invoked or a new requirement, ticket, or task description is handed off for planning."
---

# Kickoff

Kickoff registers Brian's entire planning pipeline as harness-enforced tasks before any planning work starts, so no gate (skill scan, challenge, pitch) can be silently skipped on the way from a fresh requirement to a green-lit, pitched plan.

## Execution model

Instead of trying to remember a 12-task pipeline in-prompt, the agent's **first action** is to register every step as a task via `TaskCreate`. The `TaskList` then becomes the working memory — nothing gets skipped, because skipping shows up as a pending task. Each registered task carries a one-line pointer back to its section in `references/task-specs.md`; that file stays the single source of truth for every task's Goal / Action / Gate. The pipeline prescribes the *process*, not the judgment: within a task, how to satisfy the gate is the agent's call.

## Hard rules

- **Step 0 is mandatory and runs first.** Register all kickoff tasks before doing any planning work. If `TaskList` already contains kickoff tasks for this requirement, skip Step 0 and resume from the lowest-ID pending task.
- Work the lowest-ID unblocked task. Re-read its section in `references/task-specs.md` when picking it up, mark `in_progress` before starting, mark `completed` only when the task's gate passes.
- When a gate cannot be passed, leave the task `in_progress`, post one line to chat explaining the blocker, and wait.
- The skill-scan task must be executed even when no skill applies — write down the scan output before completing it.
- Treat this skill as the source of truth for the workflow — when CLAUDE.md drifts, follow this skill until they reconcile.

## Effort matrix

Set spawned-subagent models per task via the `Agent` tool's `model` parameter.

| Task | Subagent | Effort | Model |
| --- | --- | --- | --- |
| 2 Explore | `Explore` (×1–3) | low | `haiku` |
| 2 Diagnose (bug path) | `brian:diagnose` (inline via `Skill` tool) | medium | — (runs inline; no model parameter) |
| 3 Historian | `brian:code-historian` | medium | `sonnet` |
| 6 Plan | `Plan` (×1) | high | `opus` |
| 8 Challenge | reviewer subagents (spawned by `brian:challenge`) | medium | `opus` |
| 9 Design tests | `brian:test-designer` | medium | `sonnet` |
| 11 Plan-verifier | `brian:plan-verifier` | medium | `sonnet` |

The Challenge row is informational: `brian:challenge` pins its reviewers to `opus` in its own instructions and exposes no per-invocation model or effort knob — invoke it plainly and let it manage its reviewers.

## Step 0 — Register the pipeline as tasks (FIRST ACTION)

- **Goal**: turn the pipeline into a checklist the harness enforces.
- **Action**: in a single message, call `TaskCreate` once per task in the overview below, in order. Use each task's **subject** verbatim; write each **description** as a one-line pointer back to the spec file: `Execute per § "Task N" of <absolute path of references/task-specs.md, sibling of this SKILL.md> — re-read that section and pass its Gate before completing.` Then call `TaskUpdate` to wire `addBlockedBy` where order genuinely matters (`A←B` means B is blocked by A):
  - `1←2←3←4` — Explore feeds the historian; the historian's report informs interrogation.
  - `2←5` — the skill scan needs only the Explore findings, so pick it up while the historian subagent is out.
  - `4←6` and `5←6`, then `6←7←8←9←10←11←12` chained.

  Then call `TaskList`, claim Task 1, and begin.
- **Gate**: `TaskList` shows tasks 1–12 in `pending` with pointer descriptions, dependencies wired, and Task 1 is claimed `in_progress`.

## Pipeline overview (subjects)

The 12 tasks to register. The canonical Gate for every task lives only in `references/task-specs.md` — the hook column below is a memory aid, not the gate's wording; re-read a task's section there when you pick it up.

| # | Subject | Gate hook |
| --- | --- | --- |
| 1 | `Enter plan mode` | plan mode active |
| 2 | `Explore — gather Phase-1 findings` | findings written down |
| 3 | `Historian — gather prior intent from git history and ticket tracker` | historian report in hand |
| 4 | `Interrogate — close architecture-level ambiguity` | question round answered |
| 5 | `Skill scan — enumerate and apply` | scan written, relevant skills applied |
| 6 | `Run Plan agent — produce detailed implementation plan` | verbatim Plan-agent return on disk |
| 7 | `Write the plan file` | re-read checks all pass |
| 8 | `Challenge the plan file` | challengers pass or red flags accepted in writing |
| 9 | `Design the Test design section of the plan file` | `test-designer` PASS, section placed |
| 10 | `Pitch the plan to Brian` | pitch posted |
| 11 | `Verify plan coherence and inject post-implementation protocol` | `plan-verifier` PASS, protocol is final section |
| 12 | `ExitPlanMode` | plan mode exited |

## It's working if
- `TaskList` shows the full pipeline registered and wired before any exploration starts, each task description pointing back to its section in `references/task-specs.md`.
- The plan file exists on disk before Challenge runs — Challenge revises that file, not chat.
- Interrogate questions read in plain English, each with a `(Recommended)` option, and none could have been answered by reading the code.
- The plan file's final section is `## Post-implementation protocol`, injected by plan-verifier — not hand-written.
</content>
