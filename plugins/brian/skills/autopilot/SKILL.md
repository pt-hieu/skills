---
name: autopilot
description: "Autonomous, no-human-in-the-loop sibling of /kickoff: takes a requirement to a PR without entering plan mode."
disable-model-invocation: true
---

# Autopilot — Execution Guide

Autonomous, no-human-in-the-loop sibling of `brian:kickoff`. Takes a requirement all the way to a PR — plan → implement → verify → self-review → commit → PR — without ever entering plan mode, asking a clarifying question, or waiting for plan approval. The PR is the single human review gate.

Register the pipeline as a TaskList (the working memory), work tasks in ID order, and advance only when each task's **Goal / Action / Gate** passes. The per-task specs (T1–T12) live in `references/task-specs.md` — each registered task points at its own section there; re-read that section when you pick the task up.

## Hard rules

- Check the clean-tree precondition, then register all autopilot tasks before doing any planning work. If `TaskList` already contains autopilot tasks for this requirement, skip registration and resume from the lowest-ID pending task.
- Work tasks in ID order. Advance only when the gate passes.
- The skill-scan task (T3) must be executed even when no skill applies — write down the scan output before completing it.
- **Never work on master/main — T7 creates the feature branch before any edit.**
- **Never ask the user a pre-implementation question, never call `EnterPlanMode` or `ExitPlanMode`, never wait for pre-implementation approval, and never invoke a skill/agent that will.** (This is why T6 drives the reviewer agents directly rather than invoking `brian:challenge`, which ends by asking the user to pick a disposition.)
- **Always reach a terminal state.** Never loop past a defined bound and never stall silently. Where a human would normally be consulted, make a best-judgment call and record it (T2).

## Terminal states

Every run ends in exactly one of these — none of them prompt:

- **Normal PR** (T12) — the happy path.
- **`🛑 BLOCKED` draft PR** — work can't be made review-ready (tests won't go green within bound; an unfixable high-severity finding). Open a draft PR titled `🛑 BLOCKED: <reason>`, body leads with the blocker, do **not** mark ready-for-review, post to chat, halt.
- **Chat summary, no PR** — can't safely start or finish plumbing (dirty tree at entry; ineligible coin-flip assumption; no PR tooling). Emit a one-line chat summary, halt.

## Effort matrix

Set spawned-subagent models per task via the `Agent` tool's `model` parameter. The only opus consumers are T4 (Design) and `brian:diagnose` on the bug path; everything else is sonnet/haiku.

| Task | Subagent | Effort | Model |
| --- | --- | --- | --- |
| T1 Explore | `Explore` (×1–3) | low | `haiku` |
| T1 Diagnose (bug path) | `brian:diagnose` (inline via `Skill` tool) | medium | — (runs inline; no model parameter) |
| T1 Historian (conditional) | `brian:code-historian` | low | `sonnet` |
| T4 Design | `general-purpose` (×1) | high | `opus` |
| T6 Review (one round) | `brian:architectural-reviewer` + `brian:root-cause-reviewer` (direct, parallel) | medium | `sonnet` |
| T8 Implement | implementation subagents (×N, optional) | medium | `sonnet` |
| T10 Self-review | `brian:scrutinize` axes | (scrutinize default) | `sonnet` |

## Step 0 — Precondition check, then register the pipeline as tasks (FIRST ACTION)

- **Goal**: refuse to start on a dirty tree, then turn the pipeline into a checklist the harness enforces.
- **Precondition (before any task registration)**: run `git status --porcelain`. It MUST be empty. **If the working tree is dirty, halt with a chat summary** — emit one line: *"autopilot needs a clean tree; commit or stash your existing changes first"* — and stop. Do not register tasks. (Prevents pre-existing edits being swept into the autopilot branch / commit / PR.)
- **Action**: once the tree is clean, in a single message call `TaskCreate` once per task below (T1–T12), in order. Use each task's **subject** verbatim (from `references/task-specs.md`); write each **description** as a one-line pointer at the task's spec: `Execute per § "TN — <title>" of ${CLAUDE_PLUGIN_ROOT}/skills/autopilot/references/task-specs.md — re-read that section and pass its Gate before completing; the always-on Hard rules, terminal states, and effort matrix are in ${CLAUDE_PLUGIN_ROOT}/skills/autopilot/SKILL.md.` (Both files exist, so every registered task is self-contained: its spec section plus the always-on rules.) After creation, call `TaskUpdate` to wire `addBlockedBy` so each task is blocked by the previous one (1←2←3…←12). Then call `TaskList`, claim Task 1, and begin.
- **Gate**: working tree was clean, `TaskList` shows tasks T1–T12 in `pending` with pointer descriptions, dependencies wired 1←…←12, and Task 1 is claimed `in_progress`.
