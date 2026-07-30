# Kickoff — Task specs

The full spec for each pipeline task registered in Step 0 of `SKILL.md`. Each section below is the canonical Goal / Action / Gate for one task — the target of that task's pointer description. Read the section in full when picking up the task; this file stays the single source of truth for every task's Goal / Action / Gate.

---

**Task 1 — Open the working plan file**

- subject: `Open the working plan file`

> **Goal**: establish the single on-disk artifact every downstream task writes, revises, and reads.
> **Action**: choose the path — the session scratchpad directory when the system prompt names one, otherwise `/tmp` — and name the file `kickoff-plan-<short-requirement-slug>.md`. Create it with the requirement slug as an `# ` heading. Post its absolute path to chat; every later task that says "the working plan file" means this path.
> **Gate**: the file exists on disk and its absolute path is recorded in chat.

---

**Task 2 — Explore (Phase 1 findings)**

<!-- Canonical text — autopilot T1 points at this section's Action; keep the heading stable. -->

- subject: `Explore — gather Phase-1 findings`

> **Goal**: ground the plan in real code.
> **Action**:
> - For **bugs / regressions / "why is X broken"**: invoke `brian:diagnose` via the `Skill` tool to drive root-cause exploration. Treat its output (root cause + defect class + fix-shape suggestion) as **Phase-1 findings**, not as a finished design. The design task (kickoff Task 6 / autopilot T4) still runs and consumes this as input.
> - For everything else: launch up to 3 `Explore` subagents in parallel, each scoped to a specific search area (existing implementations, related components, tests/patterns, etc.). These are scoped lookups — use the Effort-matrix model and reserve heavier models for design.
> **Gate**: concrete file paths, reusable utilities, and existing patterns (or root cause + defect class on the bug path) are written down.

---

**Task 3 — Historian (gather "why" from git + tickets)**

- subject: `Historian — gather prior intent from git history and ticket tracker`

> **Goal**: surface the *why* behind prior changes to the code about to be modified, so the implementer doesn't repeat past failures or invert past decisions blindly.
> **Action**: invoke the `code-historian` subagent via the `Agent` tool with `subagent_type: "brian:code-historian"` (model per the Effort matrix). Pass it:
> - The file paths surfaced in the Explore task (preferred input).
> - The topic / area description as fallback when paths are partial.
> - A focusing question derived from the requirement (e.g. *"why does this module handle X this way?"*).
>
> The agent auto-detects the ticket tracker (Jira / Linear / Bitbucket PRs) from commit-message patterns, remotes, and `CLAUDE.md` — do not hand it a tracker choice.
> **Gate**: historian report is in hand, including a timeline of meaningful commits, linked tickets with verbatim "why" quotes (or an explicit "no tracker / no linked tickets" note), recurring themes, and implications for the current change.

---

**Task 4 — Interrogate (architecture-level only)**

- subject: `Interrogate — close architecture-level ambiguity`

> **Goal**: close any gap that would change the chosen approach.
> **Action**: focus on **architecture- and approach-level** questions only — direction, trade-offs, scope boundaries, integration choices. Trust the Plan agent to handle implementation detail later. Use the report from the Historian task to inform which questions matter — prior failures or constraints surfaced there often *are* the architecture questions.
> - If a question can be answered by exploring the codebase, explore the codebase instead — ask only what the code cannot answer.
> - 1–3 questions max, asked in plain text in a single batch, each with a recommended option placed first and labelled `(Recommended)`.
> - Phrase every question and option in **plain English** — describe the decision and its trade-offs the way you would to a smart non-engineer. Strip jargon, class names, and file paths from the question and option labels; if a technical term is unavoidable, gloss it in the description. Brian should be able to answer from the choice itself without reverse-engineering the codebase.
> - Skip the task entirely (mark completed with a one-line note "no architecture ambiguity") when the requirement is already unambiguous.
> **Gate**: the question round has been answered (or the no-ambiguity note recorded), and remaining unknowns will not change the chosen approach.

---

**Task 5 — Skill scan (the task most often missed)**

<!-- Canonical text — autopilot T3 points at this section's Action steps 1–3; keep the heading stable. -->

- subject: `Skill scan — enumerate and apply`

> **Goal**: ensure every applicable skill informs the plan before designing.
> **Action**:
> 1. Enumerate every skill in the current system reminder's available-skills list, plus any project skills under `.claude/skills/` and `<git-root>/plugins/*/skills/`.
> 2. Write one line per skill: `skill-name: relevant? (yes/no — one-sentence reason)`. Post the list to chat or save it in your working notes.
> 3. Invoke each skill marked relevant, in order, via the `Skill` tool.
> Common matches: `brian:prompting` (LLM prompts/schemas), `claude-api` (Anthropic SDK), design skills (UI), `brian:commit` (later, out of kickoff scope).
> **Gate**: scan written down and every relevant skill applied.

---

**Task 6 — Plan agent (HARD GATE)**

- subject: `Run Plan agent — produce detailed implementation plan`

> **Goal**: produce a detailed implementation plan from a focused designer.
> **Action**: launch ONE `Plan` subagent at high effort (model per the Effort matrix). Hand it:
> - Phase-1 findings (file paths, traces, reusable utilities; on the bug path include `brian:diagnose` root cause + defect class + suggested fix shape)
> - Historian report (prior intent, recurring themes, implications)
> - Requirements and constraints
> - Skill-scan output and any skill-derived patterns to follow
> - Architecture decisions confirmed in the Interrogate task
>
> **Persist the Plan-agent return verbatim before continuing.** As soon as the Plan agent returns, write its full output to the working plan file opened in Task 1. This is the raw artifact — Task 7 will restructure it into the final sections. Do not advance to Task 7 until the file contains the Plan agent's return.
> **Gate**: a detailed implementation plan is returned **from the Plan agent** and its verbatim output has been written to the working plan file on disk. This is self-enforced — nothing external can tell the difference between the file holding the Plan agent's actual return and the orchestrator's own paraphrase of what it would have said, so ask honestly: *did the Plan agent return this, or did I write it myself because it felt coherent enough?* Diagnose output is not a Plan-agent substitute. Plan-agent latency (~2–3 min on opus) is the price of catching cross-file synthesis issues.

---

**Task 7 — Write the plan file**

- subject: `Write the plan file`

> **Goal**: leave a self-sustained artifact on disk *before* Challenge runs, so reviewer subagents can read the same artifact the implementer will. *The implementer reads this file in a fresh context with zero memory of this conversation; everything they need lives in the file.*
> **Action**: the working plan file already holds the Plan agent's verbatim return (persisted at the end of Task 6). Restructure that file in place into the sections below, in order — do not discard Plan-agent content; reorganize and enrich it:
> - **Context** — one continuous narrative covering: the requirement in concrete terms; where it came from (ticket id, user ask, bug report, link or quote); why it is being made; the Phase-1 findings that justify the chosen approach — inline them. **The quoted ask must reflect the final agreed scope after interrogation: if interrogation corrected the filename, scope, or approach, quote the corrected version as the requirement and let the rest of Context proceed from that final state.** Bug path: include root cause + defect class from `brian:diagnose`. Feature path: include existing patterns, call sites, and constraints surfaced by Explore.
> <!-- Referenced as PROVENANCE signal in plugins/brian/agents/root-cause-reviewer.md §2 — keep in sync. The historian chain states coverage in prose (see code-historian.md and root-cause-reviewer.md, rewritten to judge coverage by reading rather than matching a heading); this restructure step carries that same prose intent forward instead of pinning it to a literal line. -->
> - **Prior intent** — inline the historian's recurring themes and implications, with commit-hash and ticket-key anchors. Carry forward the historian's own account of which files it inspected and where its "why" came from, in whatever prose form the historian gave it — a reader of this section must be able to tell what was and wasn't looked at. Quote prior decisions verbatim.
> - **Recommended approach** — the chosen path.
> - **Load-bearing premises** — the 2–4 claims the approach's correctness rests on (e.g. "the current config is active", "X wins the CSS cascade", "tool Y supports option Z"), one bullet each in the form `premise — verified by: <the grep/read/command that confirmed it, or "unverified — checkable by: <how>">`. Declaring premises gives Challenge's premise audit a direct target; the Tailwind-class failure mode is an undeclared premise nobody thought to check.
> - **Critical file paths** — every file that will change, absolute paths.
> - **Reused utilities** — existing functions, helpers, or patterns this builds on, each with its path.
> - **Skills to use** — every skill the implementer must invoke during execution, taken from the Skill-scan task's output. List one bullet per relevant skill in the form `skill-name — when to invoke it and what it contributes`. Include skills that apply during implementation (e.g. `brian:prompting`, `claude-api`, design skills) and skills that apply at handoff (e.g. `brian:commit`, `voice:voice` for the PR body). If the scan found no applicable skills, write `None — skill scan returned no matches` so the implementer knows the scan was performed.
> - **Verification** — how to confirm the change works end-to-end: commands, manual smoke checks, and named test runs (referencing tests defined in the Test design section below by quoting their identifier verbatim inside backticks). Verification does NOT redescribe per-behavior test design — that lives in the Test design section. Reference test names here; describe what each pins there.
> <!-- DESIGN-DIMENSION CATALOG: Test design is currently the only post-Challenge design dimension. When a SECOND dimension (rollback / observability / perf-budget / migration) is added, extract a shared "Required design dimensions" catalog rather than adding another parallel section. -->
>
> End the file at **Verification**. The `plan-verifier` subagent appends the post-implementation protocol in Task 10 — leave room for it. Challenge (Task 8) will revise this file in place; that's expected.
> **Gate**: re-read the working plan file end-to-end and confirm in chat:
> (a) Context names the requirement source verbatim or by quote (ticket id, user-ask quote, or bug-report link), and the quoted scope matches the post-interrogation final state (reads as if that scope was always the scope),
> (b) Context inlines at least one Phase-1 finding (root cause + defect class for bugs; a named existing pattern with file path for features),
> (c) Prior intent section is present with commit-hash and/or ticket-key anchors,
> (d) Skills-to-use section lists every skill marked relevant in the Skill-scan task (or explicitly states `None` when the scan found no matches),
> (e) Load-bearing premises section is present and every premise carries a `verified by:` note (or an explicit `unverified — checkable by:` note for Challenge to pick up).
> Confirm all checks pass before completing this task; fix any that fail first.

---

**Task 8 — Challenge**

- subject: `Challenge the plan file`

> **Pre-flight self-check (MANDATORY)**: answer in one line: *"Does the working plan file reflect the Plan-agent return, or did I write it myself?"* If self-written, reopen the Plan-agent task and run the Plan agent, then rewrite the plan file. Challenge tests the plan, not the orchestrator's intuitions.
> **Goal**: catch missed details and weak spots before handoff.
> **Action**: invoke `brian:challenge` via the `Skill` tool, passing **the absolute path of the working plan file** so reviewer subagents read the same artifact the implementer will. Revise the **file in place** with each round of feedback.
> **Gate**: challengers pass, or every remaining red flag is explicitly accepted in writing inside the plan file — and the accepting/revising edits are on disk. A completed round with unresolved, unaccepted red flags does not clear this gate.

---

**Task 9 — Design tests**

- subject: `Design the Test design section of the plan file`

> **Goal**: leave the plan file with a concrete, salience-ordered, smell-free Test design section the implementer can drive TDD against. Challenge has finalized the approach; the test design pins the behaviors that approach must protect. (Why this task runs after Challenge, and the accepted trade-off: `references/testability-escape-hatch.md`.)
> **Action**: invoke the `test-designer` subagent via the `Agent` tool with `subagent_type: "brian:test-designer"` (model per the Effort matrix). Pass two arguments:
> 1. **The absolute path of the working plan file** (the same path Challenge revised in Task 8) so the agent reads the same artifact the implementer will.
> 2. **How the requirement arrived**: tell the agent plainly whether Task 2 ran the `brian:diagnose` bug branch — meaning this is a bug or regression, which the orchestrator already knows from Task 2's actual execution — or the feature-exploration branch, meaning this is new feature work. State which, and what follows: on the bug path the agent must design a regression test that pins the diagnosed root cause; on the feature path it designs tests for the new behavior. Clear prose about how the work arrived resolves the ambiguity a rigid field would only paper over.
>
> The agent inserts a `## Test design` section between `## Skills to use` and `## Verification`, edits in place, and touches no other section.
> Read the agent's reply for what it found, not for a status field. If it says the chosen approach itself is untestable (all tests deferred, or no regression test can pin the diagnosed root cause), stop and read `references/testability-escape-hatch.md` before acting — it authorizes the only backward edge in the post-Challenge tail. If it reports any other kind of problem, fix the upstream cause in the plan file and re-invoke the agent on the same path. Keep re-invoking until the agent's reply reads as satisfied with the Test design section it produced.
> **Gate**: `test-designer`'s reply reads as satisfied with the Test design section it produced, and the working plan file contains a `## Test design` section sitting between Skills to use and Verification.

---

**Task 10 — Verify the plan and inject post-implementation protocol**

- subject: `Verify plan coherence and inject post-implementation protocol`

> **Goal**: confirm the working plan file reads as one coherent narrative for a fresh-context implementer, and ensure it ends with the canonical post-implementation protocol block before handoff.
> **Action**: invoke the `plan-verifier` subagent via the `Agent` tool with `subagent_type: "brian:plan-verifier"` (model per the Effort matrix). Pass the absolute path of the working plan file (revised through Challenge). The agent does two things: it verifies the plan tells a single narrative from Context to Verification with no superseded-decision residue (Challenge revises in place, so abandoned-approach scars are the common failure), and it injects the protocol block (idempotent).
> The agent reports findings but does not fix them. Read its reply for meaning: if it flags residue — superseded-decision text, an unreconciled contradiction, anything short of a single coherent narrative — revise the working plan file in place to collapse it back to one narrative, cutting the superseded-decision text and reconciling the contradiction, then re-invoke `plan-verifier` on the same path. Keep re-invoking until its reply reads as confirming the plan is coherent end to end.
> **Gate**: `plan-verifier`'s reply reads as confirming the plan is one coherent narrative, and the reply states plainly which of the three protocol outcomes occurred — the block was injected fresh, was already present, or drift was found and corrected. Spot-check the tail of the working plan file to confirm the `## Post-implementation protocol` block is the final section.

---

**Task 11 — Hand the plan to plan mode**

- subject: `Hand the plan to plan mode`

> **Goal**: move the finished plan onto plan mode's own plan-file handling, then hand it back for technical-detail review.
> **Action**: three calls, in order.
> 1. Call `EnterPlanMode`.
> 2. Read the working plan file and write its contents **verbatim** to the plan file path named by the plan-mode system prompt. Copy the whole file — every section from Context through Post-implementation protocol — with no summarizing, re-ordering, or trimming.
> 3. Call `ExitPlanMode`.
>
> Nothing is authored in this task; it is a transfer. If the plan-mode plan file already has content, replace it wholesale with the working file's contents.
> **Gate**: the plan-mode plan file matches the working plan file end-to-end, and plan mode has been exited.
</content>
</invoke>
