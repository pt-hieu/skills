# Autopilot — Execution Guide

Take a requirement to an open PR autonomously, with no human input mid-run. Register the pipeline as a TaskList (the working memory), work tasks in ID order, and advance only when each task's **Goal / Action / Gate** passes.

## Hard rules

- Check the clean-tree precondition, then register all autopilot tasks before doing any planning work. If `TaskList` already contains autopilot tasks for this requirement, skip registration and resume from the lowest-ID pending task.
- Work tasks in ID order. Advance only when the gate passes.
- The skill-scan task (T3) must be executed even when no skill applies — write down the scan output before completing it.
- **Never work on master/main — T7 creates the feature branch before any edit.**
- **Never call `AskUserQuestion`, `EnterPlanMode`, or `ExitPlanMode`, never wait for pre-implementation approval, and never invoke a skill/agent that will.** (This is why T6 drives the reviewer agents directly rather than invoking `brian:challenge`, which ends in an `AskUserQuestion`.)
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

---

## Step 0 — Precondition check, then register the pipeline as tasks (FIRST ACTION)

- **Goal**: refuse to start on a dirty tree, then turn the pipeline into a checklist the harness enforces.
- **Precondition (before any task registration)**: run `git status --porcelain`. It MUST be empty. **If the working tree is dirty, halt with a chat summary** — emit one line: *"autopilot needs a clean tree; commit or stash your existing changes first"* — and stop. Do not register tasks. (Prevents pre-existing edits being swept into the autopilot branch / commit / PR.)
- **Action**: once the tree is clean, in a single message call `TaskCreate` once per task below (T1–T12), in order. Use the **subject** and **description** verbatim. After creation, call `TaskUpdate` to wire `addBlockedBy` so each task is blocked by the previous one (1←2←3…←12). Then call `TaskList`, claim Task 1, and begin.
- **Gate**: working tree was clean, `TaskList` shows tasks T1–T12 in `pending`, dependencies wired 1←…←12, and Task 1 is claimed `in_progress`.

### Tasks to register

Register each entry below as one `TaskCreate` call. Copy the description verbatim — it is what future-you will read when picking up the task.

---

**T1 — Explore (Phase-1 findings) + prior intent**

- subject: `Explore — gather Phase-1 findings and prior intent`
- description:
  <!-- VERBATIM COPY of kickoff Task 2 — edit both in lockstep. -->
  > **Goal**: ground the work in real code.
  > **Action**:
  > - For **bugs / regressions / "why is X broken"**: invoke `brian:diagnose` via the `Skill` tool to drive root-cause exploration. Treat its output (root cause + defect class + fix-shape suggestion) as **Phase-1 findings**, not as a finished design. The design task (kickoff Task 6 / autopilot T4) still runs and consumes this as input.
  > - For everything else: launch up to 3 `Explore` subagents in parallel, each scoped to a specific search area (existing implementations, related components, tests/patterns, etc.). These are scoped lookups — use the Effort-matrix model and reserve heavier models for design.
  > <!-- END VERBATIM COPY of kickoff Task 2. -->
  >
  > **Prior intent (inline)**: run `git log` / `git blame` on the touched paths to surface why prior changes were made. **Conditional escalation** — if the touched paths show non-trivial history (≥~5 commits OR any merge commits) AND a T2 assumption would cite prior intent, spawn `code-historian` via the `Agent` tool (`subagent_type: "brian:code-historian"`, `model: "sonnet"`) scoped to those paths to pull the tracker "why" before T2 finalizes. Preserve the historian's `Paths inspected:` line (or per-path commit anchors) — T6 reuses it.
  > **Gate**: concrete file paths, reusable utilities, and existing patterns (or root cause + defect class on the bug path) are written down, **plus a prior-intent note** (inline git findings, and the historian report if escalation fired).

---

**T2 — Assumptions ledger**

- subject: `Assumptions ledger — best-judgment calls on every approach-level unknown`
- description:
  > **Goal**: close every architecture-/approach-level ambiguity by making a best-judgment call and recording it — never by asking the human.
  > **Action**: identify the 1–3 architecture-/approach-level decision points (direction, trade-offs, scope boundaries, integration choices), informed by T1's prior-intent note. For **each**, make the best-judgment call and record one ledger entry:
  > `- Assumption: <plain-English decision>. Rationale: <why, citing T1/git/historian evidence>. Confidence: <high|medium|low>. Blast radius if wrong: <low | high (security / data / irreversible)>. Disconfirming check: <the specific evidence I looked for that would have falsified this call, and what I found>. Alternative if wrong: <what the human should change>.`
  >
  > **Calibration rule**: a `high blast radius` assumption rated `high confidence` whose Disconfirming-check field is empty or circular is **downgraded to `medium`** — it does not abort, but sorts higher in the T12 PR ledger so the human's eye lands on it first. (The same agent both makes and rates the call, so an uncalibrated high-blast call routes to the one gate that can catch it: the human at the PR.)
  > **Eligibility gate**: any assumption that is **`low confidence` AND `high blast radius`** makes the task ineligible — **halt with a chat summary** naming the coin-flip decision. If the requirement was unambiguous, record `None — requirement was unambiguous`. Where an assumption resolves scope, the design's Context (T5) states the *resolved* scope and the ledger is the audit trail.
  > **Gate**: every approach-level unknown has a ledger entry with rationale / confidence / blast-radius / disconfirming-check; no `low confidence` × `high blast radius` assumption remains (else autopilot has halted).

---

**T3 — Skill scan (the task most often missed)**

- subject: `Skill scan — enumerate and apply`
- description:
  <!-- VERBATIM COPY of kickoff Task 5 — edit both in lockstep. -->
  > **Goal**: ensure every applicable skill informs the work before designing.
  > **Action**:
  > 1. Enumerate every skill in the current system reminder's available-skills list, plus any project skills under `.claude/skills/` and `<git-root>/plugins/*/skills/`.
  > 2. Write one line per skill: `skill-name: relevant? (yes/no — one-sentence reason)`. Post the list to chat or save it in your working notes.
  > 3. Invoke each skill marked relevant, in order, via the `Skill` tool.
  > <!-- END VERBATIM COPY of kickoff Task 5. -->
  > Common in-pipeline matches: `brian:prompting` (LLM prompts/schemas), `claude-api` (Anthropic SDK), design skills (UI), plus the autopilot-pipeline skills `brian:commit` (T11), `voice:voice` (T12 PR body), and `verify`/`run` (T9 when the change is user-observable).
  > **Gate**: scan written down and every relevant skill applied.

---

**T4 — Design the implementation**

- subject: `Design the implementation — opus general-purpose agent, cross-file consistency required`
- description:
  > **Goal**: produce a detailed implementation design from a focused designer, with explicit cross-file consistency.
  > **Action**: launch **ONE `general-purpose` agent** via the `Agent` tool with `model: "opus"`, high thinking effort. A general-purpose agent has no built-in cross-file synthesis discipline, so the prompt MUST explicitly require: *"Enumerate every file that changes and state, per file, how it stays consistent with the others. Do not return a design until cross-file consistency is explicit."* Hand it:
  > - T1 findings (file paths, traces, reusable utilities; on the bug path include `brian:diagnose` root cause + defect class + suggested fix shape) and the prior-intent note
  > - The T2 assumptions ledger
  > - The requirement and its constraints
  > - The T3 skill-scan output and any skill-derived patterns to follow
  >
  > **Keep the agent's verbatim return** — it is the raw material T5 restructures and gates.
  > **Gate**: a detailed design with **explicit per-file cross-file consistency** is returned from the opus agent. The design must come from that agent — improvising it yourself does not substitute, since no human reviews it before code.

---

**T5 — Structure and gate the design**

- subject: `Structure and gate the design`
- description:
  > **Goal**: turn T4's raw return into an implementation-ready design and quality-gate it before any code. (T4 generates; you structure and gate.)
  > **Action**: restructure T4's return into the sections below, in order, held in your working context — do not discard T4 content; reorganize and enrich it:
  > - **Context** — the requirement in concrete terms; where it came from (ticket id, user ask, bug report, link or quote); why it is being made; the Phase-1 findings that justify the chosen approach (inline ≥1). **State the requirement at its *resolved* scope** — if a T2 assumption resolved scope/filename/approach, use the resolved version and let Context proceed from that final state. Bug path: include root cause + defect class from `brian:diagnose`. Feature path: include existing patterns, call sites, and constraints surfaced by Explore.
  > - **Assumptions** — the T2 ledger (rationale / confidence / blast-radius / disconfirming-check per entry).
  > - **Recommended approach** — the chosen path.
  > - **Critical file paths** — every file that will change, absolute paths.
  > - **Reused utilities** — existing functions, helpers, or patterns this builds on, each with its path.
  > - **Skills to use** — every skill to invoke during implementation, from the T3 scan; one bullet per skill as `skill-name — when to invoke it and what it contributes`. Include `brian:commit` and `voice:voice`. Write `None — skill scan returned no matches` if the scan found nothing.
  > - **Test plan** — the named tests T8 implements, salience-ordered. Name each test by the imperative phrase it will be given.
  > - **Verification** — commands + named test runs (reference each test by quoting its identifier verbatim inside backticks).
  > **Gate (re-read the structured design, confirm in chat)**:
  > (a) Context states the source and the resolved scope (reads as if that scope was always the scope);
  > (b) Context inlines ≥1 Phase-1 finding (root cause + defect class for bugs; a named existing pattern with file path for features);
  > (c) Assumptions present with rationale / confidence / blast-radius;
  > (d) Skills-to-use complete (or `None`);
  > (e) Test plan names the tests;
  > **(f) bug path only — if T1 ran `brian:diagnose`, the Test plan contains ≥1 test whose stated purpose quotes a substring of the diagnosed root cause** (absent → gate fails).
  > Fix any failing check before completing this task.

---

**T6 — Review the design (one round, reviewer agents driven directly)**

- subject: `Review the design — architectural-reviewer + root-cause-reviewer, one direct round`
- description:
  > **Goal**: stress-test the design with two reviewer agents in one round, using no step that would block on a human.
  > **Action**: do **NOT** invoke the `brian:challenge` skill. Spawn `brian:architectural-reviewer` and `brian:root-cause-reviewer` **directly** via the `Agent` tool — both `model: "sonnet"`, both as two tool-use blocks in the **same** message so they run in parallel, **ONE round only**. The review target is plan-mode — no diff exists yet (implementation is T8). Assemble the full agent user-turn; **the reviewer agents' input contracts require all of these or they stall requesting the missing section**:
  > - `## Output Contract` — the Finding Anchor format plus the prose conventions. The Finding Anchor format is:
  >   `Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | "cross">; summary=<one-sentence canonical issue>`
  >   Name the defect class in plain words — there is no enum to load and no SSOT file to read. Each finding states its confidence and basis in plain prose (not a tag), and the `INSUFFICIENT CONTEXT — [...]` abstinence rule applies.
  > - `## Context` — the design's Recommended approach + Assumptions, inline.
  > - `## Affected Files` — the design's Critical file paths, **repo-relative**. This anchors the architectural reviewer's mandatory historical-coherence step on the files the design *will* change.
  > - `## Prior intent` — T1's prior-intent note (git log + any historian output) with a `Paths inspected:` line listing the Critical file paths. This satisfies the root-cause reviewer's PROVENANCE/COVERAGE checks so it records *reusing prior intent* and does NOT self-spawn `code-historian`. Instruct both reviewers explicitly: *do not spawn your own historian — prior intent is supplied inline.*
  > - `## Project Domain Knowledge` — emit a minimal inline block (the touched skill(s)' rules) OR the literal sentinel `No project-specific skills found. Review using general principles only.` Omitting this section fires the agents' "missing required section → request it" branch (a silent stall).
  >
  > **Disposition inline (you own synthesis — no terminal question, no re-challenge loop)**: for each high- and medium-severity finding (severity judged from the reviewer's prose), pick one — **Fix** the design in place, **Rebut** with citable evidence (file ref / git history / domain rule — a rebuttal without citable evidence converts to Fix), or — for a genuinely out-of-scope finding — **note it in the design's Assumptions ledger**.
  > **Gate**: one review round complete; every high-/medium-severity finding dispositioned; design updated; no reviewer stalled on a missing input section.

---

**T7 — Create / switch to a feature branch (before any edit)**

- subject: `Create or switch to a feature branch`
- description:
  > **Goal**: never edit on the repo default branch.
  > **Action**: run `git rev-parse --abbrev-ref HEAD`. If on the repo default (`main` / `master` / `develop`), run `git switch -c <ticket-or-slug>` (derive the name from the ticket id or a short requirement slug). Otherwise stay on the current non-default branch.
  > **Gate**: on a non-default feature branch, working tree still clean (confirm no edits have leaked in).

---

**T8 — Implement (TDD)**

- subject: `Implement against the design Test plan (TDD)`
- description:
  > **Goal**: build the change test-first, in salience order, against the design's Test plan.
  > **Action**: for each named test in the design's Test plan: write it (failing), implement until green, in salience order. Small bounded steps. MAY spawn implementation subagents via the `Agent` tool (`model: "sonnet"`), one per independent unit, each handed the relevant slice of the design + its scope. Edit only the design's Critical file paths + their tests; reuse the named utilities.
  > **Gate**: every Test-plan item has an implemented test, the change is complete, nothing is left unimplemented.

---

**T9 — Verify**

- subject: `Verify — run the design Verification commands and named tests`
- description:
  > **Goal**: confirm the change works end-to-end.
  > **Action**: run the design's **Verification** commands + named test runs verbatim. If the change is user-observable, invoke `verify` / `run` (from the T3 scan) to drive the real app.
  > **Bounded retry**: on failure, return to T8 and fix; **max 3 T8↔T9 cycles**. On the 3rd consecutive red, fire the terminal: **`🛑 BLOCKED` draft PR** — push the WIP branch, open a draft PR titled `🛑 BLOCKED: tests failing`, body leads with the failing output, post to chat, halt. Do not loop past 3.
  > **Gate**: all named tests pass and Verification succeeds (else the bounded-blocked terminal fired).

---

**T10 — Self-review**

- subject: `Self-review — scrutinize the diff`
- description:
  > **Goal**: automated diff review before commit.
  > **Action**: invoke `brian:scrutinize` via the `Skill` tool on the working-tree diff (safe — chat-only, no terminal prompt, no internal loop). Treat findings as a hostile audit. Disposition each:
  > - Medium-severity → **Fix**, **Rebut** with citable evidence, or **Defer** with a follow-up reference recorded into the design's Assumptions ledger (so it surfaces in the PR).
  > - High-severity → **must Fix or Rebut with citable evidence. A high-severity finding may NOT be deferred** (severity floor). A high-severity finding that can be neither fixed nor citably rebutted → fire the terminal: **`🛑 BLOCKED` draft PR** (title leads with the unresolved finding, do not mark ready-for-review, post to chat, halt).
  > One scrutinize pass — do not re-run it after dispositioning. Apply the fixes and proceed to T11. Severity is judged from each finding's prose.
  > **Gate**: no unaddressed high-severity finding; every medium-severity finding dispositioned and ledger-surfaced (or a blocked terminal fired).

---

**T11 — Commit**

- subject: `Commit the change`
- description:
  > **Goal**: commit the autopilot change as one logical commit.
  > **Action**: invoke `brian:commit` via the `Skill` tool to commit the change as one logical commit. Do **not** trigger its interactive split path — autopilot's change is a single logical unit; name the coherent design decision in the message.
  > **Gate**: committed; working tree clean.

---

**T12 — Raise the PR (terminus)**

- subject: `Raise the PR`
- description:
  > **Goal**: open the PR — the single human review gate — with a body that leads with the decisions autopilot made unasked.
  > **Action**:
  > 1. **Pre-draft coherence self-check**: re-read the design end-to-end and confirm Context → Assumptions → Recommended approach → Test plan describe ONE final approach. If T6's in-place revision left residue ("originally…/instead…", two names for one artifact, a superseded approach described as if current), collapse to the final state **before** drafting.
  > 2. Push the branch.
  > 3. Draft the PR body with `voice:voice` (via the `Skill` tool) in plain language. The body **MUST lead with the Assumptions ledger, sorted by blast radius (high-blast-radius first)**, framed *"Decisions I made without asking — flag any that are wrong,"* then a plain-language change summary, then Verification results, then any deferred medium-severity scrutinize findings.
  > 4. Open the PR via the Bitbucket MCP (`mcp__bitbucket__create_pull_request`; in the interface repo use workspace `drovacorp` / repo `interface` / target `master`) or `gh`, detected from the repo remotes / T3 scan.
  > **Fallback (terminal: chat summary)**: if neither PR tool resolves, push the branch and emit to chat the exact manual PR-creation command / compare-URL plus the drafted body, then halt — do not leave a dangling branch silently.
  > **Gate**: PR open (or the manual-PR fallback fired); body leads with the blast-radius-sorted ledger; the PR URL (or compare-URL) is posted to chat. **Terminus.**
