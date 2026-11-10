---
name: autopilot
description: "Use when Brian hands over a requirement and asks for it to be taken all the way to a PR autonomously — phrased as autopilot, hands-off, unattended, end-to-end, or \"don't ask me anything\". Plans, implements, verifies, self-reviews, commits, and opens the PR as the single human gate, never entering plan mode. When Brian wants to approve a plan first, use kickoff instead."
---

# Autopilot

`autopilot` is the autonomous, no-human-in-the-loop sibling of `brian:kickoff`. It takes a requirement all the way to a PR without entering plan mode, asking a clarifying question, or waiting for approval. The PR is the single human review gate, so every decision a human would have been asked about is made on best judgment and **recorded** where the reviewer reads first.

## The result

Every run ends in exactly one of three terminal states, and none of them prompts.

**A normal PR.**

- The change is on a feature branch, in one logical commit made with `brian:commit`, whose message names the design decision. Autopilot's change is a single logical unit, so the commit is not split.
- The PR body leads with the assumptions register, sorted with high blast radius first and framed "Decisions I made without asking — flag any that are wrong". Then a plain-language summary of the change, the verification results, and any deferred medium-severity review findings.
- The body describes one final approach. A design revised during review leaves residue ("originally… instead…", two names for one artifact, a superseded approach described as current), and none of it reaches the PR.
- The PR is opened with the Bitbucket MCP (`mcp__bitbucket__create_pull_request`; in the interface repo, workspace `drovacorp`, repo `interface`, target `master`) or with `gh`, whichever the repo's remotes call for, and its URL is posted to chat.

**A `🛑 BLOCKED` draft PR**, when the work cannot be made review-ready. The WIP branch is pushed, a draft PR is opened titled `🛑 BLOCKED: <reason>` with a body that leads with the blocker, it is not marked ready for review, and chat gets the link. The cases:

- verification is red for the third time;
- a high-severity self-review finding can be neither fixed nor rebutted with citable evidence;
- `brian:scrutinize` reports that it did not run, so the diff has no review.

**A chat summary and no PR**, when the run cannot safely start or cannot finish the plumbing:

- The working tree is dirty at entry. `git status --porcelain` must be empty before anything else happens, so that pre-existing edits are not swept into the branch, the commit, and the PR. Otherwise the whole run is the line "autopilot needs a clean tree; commit or stash your existing changes first".
- An assumption is both low confidence and high blast radius. The summary names the coin-flip decision.
- No PR tool resolves. The branch is pushed, and chat gets the exact manual PR-creation command or compare URL plus the drafted body, so no branch is left dangling silently.

## What holds throughout

- **No human before the PR.** No pre-implementation question, no `EnterPlanMode` or `ExitPlanMode`, no wait for approval, and no skill or agent that does any of these. `brian:challenge` ends by asking the user for directions, so the design is reviewed by the reviewer agents directly.
- **No edit on the default branch.** On `main`, `master`, or `develop`, `git switch -c <ticket-or-slug>` comes before the first edit; on any other branch the run stays where it is.
- **Every loop is bounded**, so the run always reaches a terminal state: three verification attempts, one design-review round, one `brian:scrutinize` pass.

## What the PR rests on

No human reviews anything before the code is written, so each piece below exists before the piece that depends on it, produced by the agent or skill named at the model named (the `Agent` tool's `model` parameter).

| Evidence | Produced by | Model |
| --- | --- | --- |
| Code findings | up to three `Explore` subagents | `haiku` |
| Root cause, for a bug | `brian:diagnose`, inline via the `Skill` tool | — |
| Prior intent, when escalated | `brian:code-historian` | `sonnet` |
| Design | one `general-purpose` agent, high effort | `opus` |
| Design review | `brian:architectural-reviewer` and `brian:root-cause-reviewer` | `sonnet` |
| Implementation | you, or one subagent per independent unit | `sonnet` |
| Self-review | `brian:scrutinize`, via the `Skill` tool | its own |

**Code findings and prior intent.** Concrete file paths, reusable utilities, and existing patterns, written down; for a bug, regression, or "why is X broken", the root cause, defect class, and suggested fix shape from `brian:diagnose`. With them, a prior-intent note from `git log` and `git blame` on the touched paths, saying why earlier changes were made. The historian is added when those paths have non-trivial history (about five commits or more, or any merge commit) and an assumption would cite prior intent. The note says which files were inspected and where its account came from (commit refs, ticket links), because the design review reuses it.

**The assumptions register.** Every architecture- or approach-level unknown (direction, trade-offs, scope boundaries, integration choices) is closed by a best-judgment call, one entry each:

```
- Assumption: <plain-English decision>. Rationale: <why, citing code, git, or historian evidence>. Confidence: <high|medium|low>. Blast radius if wrong: <low | high (security / data / irreversible)>. Disconfirming check: <the specific evidence I looked for that would have falsified this call, and what I found>. Alternative if wrong: <what the human should change>.
```

The same agent makes and rates each call, so a high-blast-radius assumption rated high confidence whose disconfirming check is empty or circular is rated `medium` instead, which sorts it higher in the PR where the human's eye lands first. An unambiguous requirement is recorded as `None — requirement was unambiguous`. Later decisions join the register too: out-of-scope review findings, deferred self-review findings, and coverage gaps.

**The skill scan.** One line per skill, `skill-name: relevant? (yes/no — one-sentence reason)`, for every skill in the available-skills list and every project skill under `.claude/skills/` and `<git-root>/plugins/*/skills/`, with each relevant skill invoked before the design. It is written down even when nothing applies, because an unwritten scan cannot be told from a skipped one.

**The design.** It comes from the opus agent, given the findings, the prior-intent note, the register, the requirement and its constraints, and the skill scan, and asked to enumerate every file that changes and to state, per file, how it stays consistent with the others. The cross-file check has to live in the design because nobody reviews it before code. Nothing downstream can tell the agent's return from your own improvisation standing in for it, so ask honestly which one you hold. Its content is kept and organised into:

- **Context** — the requirement in concrete terms, where it came from, why it is being made, and at least one inlined code finding. Where an assumption resolved scope, filename, or approach, Context states the resolved version and reads as if that scope was always the scope. For a bug it includes the root cause and defect class.
- **Assumptions** — the register.
- **Recommended approach** — the chosen path.
- **Critical file paths** — every file that will change, absolute paths.
- **Reused utilities** — existing functions, helpers, or patterns this builds on, each with its path.
- **Skills to use** — one bullet per skill as `skill-name — when to invoke it and what it contributes`, including `brian:commit`, or a plain statement that the scan found none.
- **Test plan** — the named tests, in salience order, each named by the imperative phrase it will be given. For a bug, at least one test whose stated purpose pins the diagnosed root cause and not a nearby symptom.
- **Verification** — commands and named test runs, each test quoted by its identifier in backticks.

**The design review.** Both reviewers are launched in one message, for one round, on the design as a plan, since no diff exists yet. Each prompt needs every section below, or the reviewer stalls asking for the missing one:

- `## Output Contract` — every finding starts with `Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>`. The defect class is named in plain words, each finding states its confidence and basis in prose, and a dimension that cannot be assessed is reported as `INSUFFICIENT CONTEXT — [...]`.
- `## Context` — the design's Recommended approach and Assumptions, inline.
- `## Affected Files` — the design's Critical file paths, repo-relative. The architectural reviewer anchors its historical-coherence check on them.
- `## Prior intent` — the prior-intent note, stating which files were inspected and where its account came from, and covering the Critical file paths. Tell both reviewers that prior intent is supplied inline and they are not to spawn their own historian.
- `## Project Domain Knowledge` — the project-specific rules the skill scan surfaced for the touched area, or a plain statement that none applied. Tell both reviewers that a stated absence is a complete answer.

You own the synthesis. Each high- and medium-severity finding, severity judged from the reviewer's prose, is fixed in the design, rebutted with citable evidence (a file reference, git history, a domain rule), or, when it is out of scope, noted in the register. A rebuttal without citable evidence is a fix.

**The implementation.** Built test-first against the Test plan, in salience order: each named test exists and failed before the code that makes it pass. Edits stay within the design's Critical file paths and their tests, and reuse the named utilities.

**Verification.** The design's Verification commands and named test runs, run verbatim. A user-observable change is also driven in the real app with the `verify` or `run` skill when the scan found one.

**Self-review.** `brian:scrutinize` runs once on the working-tree diff, and its findings are read as a hostile audit, severity taken from each finding's prose:

- A high-severity finding is fixed or rebutted with citable evidence. It is never deferred.
- A medium-severity finding is fixed, rebutted with citable evidence, or deferred with a follow-up reference in the register, so it surfaces in the PR.
- The report's `verdict:` line is read before the findings. On `incomplete`, each axis and the files it did not cover, as the `coverage:` line names them, go at the top of the register, so the PR leads with what no reviewer read.

## Verify

The run is long enough to be compacted, so once the tree is known to be clean, register each check below as a task and complete a task only when its evidence exists. A check left pending is then visible instead of forgotten.

- `git status --porcelain` was empty at entry.
- Findings and the prior-intent note are written down.
- Every approach-level unknown has a register entry with rationale, confidence, blast radius, and disconfirming check, and none is low confidence with high blast radius.
- The skill scan is written, and every skill marked relevant was invoked.
- The design came back from the opus agent and states per-file consistency; its Context names the source and the resolved scope and inlines a finding; its Test plan names the tests, with a root-cause test for a bug.
- One review round ran with both reviewers, neither stalled on a missing section, and every high- and medium-severity finding is fixed, rebutted with a citation, or in the register.
- The first edit was made on a non-default branch.
- Every Test-plan item has an implemented test, and the Verification commands and named tests pass.
- `brian:scrutinize` ran once; no high-severity finding is unaddressed, every medium one is dispositioned, and an `incomplete` verdict's gaps lead the register.
- The working tree is clean after one commit.
- The PR is open and its URL is in chat, its body leads with the register sorted by blast radius, and it describes one approach. Or one of the other two terminal states was reached and chat says which.
