# Autopilot — per-task specs (T1–T12)

Each section below is the full spec for one task — the target of its Step-0 pointer description. Read the section in full when picking up the task, and satisfy its **Goal / Action / Gate** before completing it. The always-on Hard rules, terminal states, and effort matrix live in `SKILL.md`.

---

**T1 — Explore (Phase-1 findings) + prior intent**

- subject: `Explore — gather Phase-1 findings and prior intent`
  > **Goal**: ground the work in real code.
  > **Action**: execute the Explore **Action** exactly as specified in § "Task 2 — Explore (Phase 1 findings)" of `${CLAUDE_PLUGIN_ROOT}/skills/kickoff/references/task-specs.md` — Read that section before launching anything; kickoff owns the canonical text.
  >
  > **Prior intent (inline)**: run `git log` / `git blame` on the touched paths to surface why prior changes were made. **Conditional escalation** — if the touched paths show non-trivial history (≥~5 commits OR any merge commits) AND a T2 assumption would cite prior intent, spawn `code-historian` via the `Agent` tool (`subagent_type: "brian:code-historian"`, `model: "sonnet"`) scoped to those paths to pull the tracker "why" before T2 finalizes. Preserve, in your own words, which files the historian actually inspected and where its account of prior intent came from (commit refs, ticket links) — T6 reuses this account.
  > **Gate**: concrete file paths, reusable utilities, and existing patterns (or root cause + defect class on the bug path) are written down, **plus a prior-intent note** (inline git findings, and the historian report if escalation fired).

---

**T2 — Assumptions ledger**

- subject: `Assumptions ledger — best-judgment calls on every approach-level unknown`
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
  > **Goal**: ensure every applicable skill informs the work before designing.
  > **Action**: execute the skill-scan **Action** (steps 1–3) exactly as specified in § "Task 5 — Skill scan" of `${CLAUDE_PLUGIN_ROOT}/skills/kickoff/references/task-specs.md` — Read that section before scanning; kickoff owns the canonical text (its "Common matches" line is kickoff-flavored; use the list below instead).
  > Common in-pipeline matches: `brian:prompting` (LLM prompts/schemas), `claude-api` (Anthropic SDK), design skills (UI), plus the autopilot-pipeline skills `brian:commit` (T11) and `verify`/`run` (T9 when the change is user-observable).
  > **Gate**: scan written down and every relevant skill applied.

---

**T4 — Design the implementation**

- subject: `Design the implementation — opus general-purpose agent, cross-file consistency required`
  > **Goal**: produce a detailed implementation design from a focused designer, with explicit cross-file consistency.
  > **Action**: launch **ONE `general-purpose` agent** via the `Agent` tool with `model: "opus"`, high thinking effort. A general-purpose agent has no built-in cross-file synthesis discipline, so the prompt MUST explicitly require: *"Enumerate every file that changes and state, per file, how it stays consistent with the others. Do not return a design until cross-file consistency is explicit."* Hand it:
  > - T1 findings (file paths, traces, reusable utilities; on the bug path include `brian:diagnose` root cause + defect class + suggested fix shape) and the prior-intent note
  > - The T2 assumptions ledger
  > - The requirement and its constraints
  > - The T3 skill-scan output and any skill-derived patterns to follow
  >
  > **Keep the agent's verbatim return** — it is the raw material T5 restructures and gates.
  > **Gate**: a detailed design with **explicit per-file cross-file consistency** is returned from the opus agent. The design must come from that agent, not from your own improvisation standing in for it — this is self-enforced (nothing downstream can tell the difference), and it matters precisely because no human reviews the design before code.

---

**T5 — Structure and gate the design**

- subject: `Structure and gate the design`
  > **Goal**: turn T4's raw return into an implementation-ready design and quality-gate it before any code. (T4 generates; you structure and gate.)
  > **Action**: restructure T4's return into the sections below, in order, held in your working context — do not discard T4 content; reorganize and enrich it:
  > - **Context** — the requirement in concrete terms; where it came from (ticket id, user ask, bug report, link or quote); why it is being made; the Phase-1 findings that justify the chosen approach (inline ≥1). **State the requirement at its *resolved* scope** — if a T2 assumption resolved scope/filename/approach, use the resolved version and let Context proceed from that final state. Bug path: include root cause + defect class from `brian:diagnose`. Feature path: include existing patterns, call sites, and constraints surfaced by Explore.
  > - **Assumptions** — the T2 ledger (rationale / confidence / blast-radius / disconfirming-check per entry).
  > - **Recommended approach** — the chosen path.
  > - **Critical file paths** — every file that will change, absolute paths.
  > - **Reused utilities** — existing functions, helpers, or patterns this builds on, each with its path.
  > - **Skills to use** — every skill to invoke during implementation, from the T3 scan; one bullet per skill as `skill-name — when to invoke it and what it contributes`. Include `brian:commit`. If the scan found nothing, say so plainly rather than leaving the section blank — a stated absence is a complete answer here.
  > - **Test plan** — the named tests T8 implements, salience-ordered. Name each test by the imperative phrase it will be given.
  > - **Verification** — commands + named test runs (reference each test by quoting its identifier verbatim inside backticks).
  > **Gate (re-read the structured design, confirm in chat)**:
  > (a) Context states the source and the resolved scope (reads as if that scope was always the scope);
  > (b) Context inlines ≥1 Phase-1 finding (root cause + defect class for bugs; a named existing pattern with file path for features);
  > (c) Assumptions present with rationale / confidence / blast-radius;
  > (d) Skills-to-use complete (or `None`);
  > (e) Test plan names the tests;
  > **(f) bug path only — if T1 ran `brian:diagnose`, the Test plan contains ≥1 test whose stated purpose pins the diagnosed root cause** — judge this by reading: the test must target that cause, not merely a nearby symptom (absent → gate fails).
  > Fix any failing check before completing this task.

---

**T6 — Review the design (one round, reviewer agents driven directly)**

- subject: `Review the design — architectural-reviewer + root-cause-reviewer, one direct round`
  > **Goal**: stress-test the design with two reviewer agents in one round, using no step that would block on a human.
  > **Action**: do **NOT** invoke the `brian:challenge` skill. Spawn `brian:architectural-reviewer` and `brian:root-cause-reviewer` **directly** via the `Agent` tool — both `model: "sonnet"`, both as two tool-use blocks in the **same** message so they run in parallel, **ONE round only**. The review target is plan-mode — no diff exists yet (implementation is T8). Assemble the full agent user-turn; **the reviewer agents' input contracts require all of these or they stall requesting the missing section**:
  > - `## Output Contract` — the Finding Anchor format plus the prose conventions. The Finding Anchor format is:
  >   `Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>`
  >   Name the defect class in plain words — there is no enum to load and no SSOT file to read. Each finding states its confidence and basis in plain prose (not a tag), and the `INSUFFICIENT CONTEXT — [...]` abstinence rule applies.
  > - `## Context` — the design's Recommended approach + Assumptions, inline.
  > - `## Affected Files` — the design's Critical file paths, **repo-relative**. This anchors the architectural reviewer's mandatory historical-coherence step on the files the design *will* change.
  > - `## Prior intent` — T1's prior-intent note (git log + any historian output), written so it plainly states which files were actually inspected and where its account of prior intent came from (commit refs, ticket links), covering the design's Critical file paths. This gives the root-cause reviewer what it needs to judge, by reading, that prior intent has already been gathered, so it records *reusing prior intent* and does NOT self-spawn `code-historian`. Instruct both reviewers explicitly: *do not spawn your own historian — prior intent is supplied inline.*
  > - `## Project Domain Knowledge` — when T3's skill scan surfaced project-specific rules for the touched skill(s), emit a minimal inline block stating them. When the scan found nothing project-specific, say so plainly in this section, in your own words (e.g. state that no project-specific skills applied and the review should proceed on general principles) — a legible statement that the section was considered and came back empty, not a blank. Instruct both reviewers explicitly: a plainly stated absence is a complete answer to this section — only a section that is actually missing (no statement either way) should trigger a request for it.
  >
  > **Disposition inline (you own synthesis — no terminal question)**: for each high- and medium-severity finding (severity judged from the reviewer's prose), pick one — **Fix** the design in place, **Rebut** with citable evidence (file ref / git history / domain rule — a rebuttal without citable evidence converts to Fix), or — for a genuinely out-of-scope finding — **note it in the design's Assumptions ledger**.
  > **Gate**: one review round complete; every high-/medium-severity finding dispositioned; design updated; no reviewer stalled on a missing input section.

---

**T7 — Create / switch to a feature branch (before any edit)**

- subject: `Create or switch to a feature branch`
  > **Goal**: never edit on the repo default branch.
  > **Action**: run `git rev-parse --abbrev-ref HEAD`. If on the repo default (`main` / `master` / `develop`), run `git switch -c <ticket-or-slug>` (derive the name from the ticket id or a short requirement slug). Otherwise stay on the current non-default branch.
  > **Gate**: on a non-default feature branch, working tree still clean (confirm no edits have leaked in).

---

**T8 — Implement (TDD)**

- subject: `Implement against the design Test plan (TDD)`
  > **Goal**: build the change test-first, in salience order, against the design's Test plan.
  > **Action**: for each named test in the design's Test plan: write it (failing), implement until green, in salience order. Small bounded steps. MAY spawn implementation subagents via the `Agent` tool (`model: "sonnet"`), one per independent unit, each handed the relevant slice of the design + its scope. Edit only the design's Critical file paths + their tests; reuse the named utilities.
  > **Gate**: every Test-plan item has an implemented test, the change is complete, nothing is left unimplemented.

---

**T9 — Verify**

- subject: `Verify — run the design Verification commands and named tests`
  > **Goal**: confirm the change works end-to-end.
  > **Action**: run the design's **Verification** commands + named test runs verbatim. If the change is user-observable, invoke `verify` / `run` (from the T3 scan) to drive the real app.
  > **Bounded retry**: on failure, return to T8 and fix; **max 3 T8↔T9 cycles**. On the 3rd consecutive red, fire the terminal: **`🛑 BLOCKED` draft PR** — push the WIP branch, open a draft PR titled `🛑 BLOCKED: tests failing`, body leads with the failing output, post to chat, halt. Do not loop past 3.
  > **Gate**: all named tests pass and Verification succeeds (else the bounded-blocked terminal fired).

---

**T10 — Self-review**

- subject: `Self-review — scrutinize the diff`
  > **Goal**: automated diff review before commit.
  > **Action**: invoke `brian:scrutinize` via the `Skill` tool on the working-tree diff (safe — chat-only, no terminal prompt, no internal loop). Treat findings as a hostile audit. Disposition each:
  > - Medium-severity → **Fix**, **Rebut** with citable evidence, or **Defer** with a follow-up reference recorded into the design's Assumptions ledger (so it surfaces in the PR).
  > - High-severity → **must Fix or Rebut with citable evidence. A high-severity finding may NOT be deferred** (severity floor). A high-severity finding that can be neither fixed nor citably rebutted → fire the terminal: **`🛑 BLOCKED` draft PR** (title leads with the unresolved finding, do not mark ready-for-review, post to chat, halt).
  > One scrutinize pass — do not re-run it after dispositioning. Apply the fixes and proceed to T11. Severity is judged from each finding's prose.
  > **Gate**: no unaddressed high-severity finding; every medium-severity finding dispositioned and ledger-surfaced (or a blocked terminal fired).

---

**T11 — Commit**

- subject: `Commit the change`
  > **Goal**: commit the autopilot change as one logical commit.
  > **Action**: invoke `brian:commit` via the `Skill` tool to commit the change as one logical commit. Do **not** trigger its interactive split path — autopilot's change is a single logical unit; name the coherent design decision in the message.
  > **Gate**: committed; working tree clean.

---

**T12 — Raise the PR (terminus)**

- subject: `Raise the PR`
  > **Goal**: open the PR — the single human review gate — with a body that leads with the decisions autopilot made unasked.
  > **Action**:
  > 1. **Pre-draft coherence self-check**: re-read the design end-to-end and confirm Context → Assumptions → Recommended approach → Test plan describe ONE final approach. If T6's in-place revision left residue ("originally…/instead…", two names for one artifact, a superseded approach described as if current), collapse to the final state **before** drafting.
  > 2. Push the branch.
  > 3. Draft the PR body in plain language. The body **MUST lead with the Assumptions ledger, sorted by blast radius (high-blast-radius first)**, framed *"Decisions I made without asking — flag any that are wrong,"* then a plain-language change summary, then Verification results, then any deferred medium-severity scrutinize findings.
  > 4. Open the PR via the Bitbucket MCP (`mcp__bitbucket__create_pull_request`; in the interface repo use workspace `drovacorp` / repo `interface` / target `master`) or `gh`, detected from the repo remotes / T3 scan.
  > **Fallback (terminal: chat summary)**: if neither PR tool resolves, push the branch and emit to chat the exact manual PR-creation command / compare-URL plus the drafted body, then halt — do not leave a dangling branch silently.
  > **Gate**: PR open (or the manual-PR fallback fired); body leads with the blast-radius-sorted ledger; the PR URL (or compare-URL) is posted to chat. **Terminus.**
