---
name: kickoff
description: "Use when a new requirement, ticket, or task description is handed off for planning."
---

# Kickoff

`kickoff` takes a fresh requirement to a plan Brian can green-light: a plan file that states the architectural direction, is grounded in the code and its history, has been challenged, and reads whole to an implementer with no memory of this conversation. Every piece of **evidence** the plan rests on is produced, never assumed: a plan that skipped its skill scan, its challenge, or its test design looks the same in chat as one that did not.

## The result

The finished plan sits in plan mode's plan file, and plan mode has been exited so Brian can review it.

Until then the plan lives in the **working plan file**: `kickoff-plan-<short-requirement-slug>.md` in the session scratchpad directory when the system prompt names one, otherwise in `/tmp`, with its absolute path posted to chat when it is created. Planning runs in the session's current permission mode. Plan mode is entered only for the hand-over: `EnterPlanMode`, the working file written verbatim to the path the plan-mode system prompt names, replacing whatever is there, then `ExitPlanMode`. Nothing is authored, summarized, re-ordered, or trimmed in the transfer.

**The plan states architectural direction, not implementation detail.** It answers what shape the change takes and what must be true for it to be right, never how to write the code. Detail gets settled while implementing, so the file holds no code snippets, no function signatures, and no step-by-step edit sequences. High-level is not hand-wavy: the plan is decisive about direction, boundaries, and premises. "Refactor as needed" fails as hard as a pasted diff.

The implementer reads the file in a fresh context, so everything they need is in it. Its sections, in order:

- **Context** — one continuous narrative: the requirement in concrete terms; where it came from (ticket id, user ask, bug report, link or quote); why it is being made; and the code findings that justify the approach, inlined. The quoted ask is the final agreed scope: when Brian's answers corrected the filename, scope, or approach, Context quotes the corrected version and reads as if that scope was always the scope. For a bug it includes the root cause and defect class from `brian:diagnose`; for a feature, the existing patterns, call sites, and constraints.
- **Prior intent** — the historian's recurring themes and implications, with commit-hash and ticket-key anchors and prior decisions quoted verbatim. It carries the historian's own account of which files it inspected and where its "why" came from, so a reader can tell what was and was not looked at.
- **Recommended approach** — the chosen direction: the shape the change takes, the boundaries it crosses and the ones it holds, and why this shape over the alternative that was in play.
- **Critical premises** — the two to four claims the approach's correctness rests on (e.g. "the current config is active", "X wins the CSS cascade", "tool Y supports option Z"), one bullet each as `premise — verified by: <the grep/read/command that confirmed it, or "unverified — checkable by: <how>">`. A declared premise gives Challenge's premise audit a direct target; the failure this prevents is an undeclared premise nobody thought to check.
- **Surface area** — the components and files the change lands in, absolute paths, one line each on the role that component plays in the direction. It names where the change lives, not what edit each file receives.
- **Reused utilities** — existing functions, helpers, or patterns this builds on, each with its path.
- **Skills to use** — every skill the implementer must invoke, one bullet each as `skill-name — when to invoke it and what it contributes`, covering skills used while implementing (`brian:prompting`, `claude-api`, design skills) and at hand-off (`brian:commit`). When the scan found none: `None — skill scan returned no matches`, so the implementer knows the scan ran.
- **Test design** — written by `brian:test-designer`: the behaviors the change must prove, in salience order, so the implementer can drive TDD against them. Behaviors, not test code.
- **Verification** — how to confirm the change works end to end: commands, manual smoke checks, and named test runs. It refers to the behaviors Test design pins and does not redescribe them.
- **Post-implementation protocol** — injected by `brian:plan-verifier`, never hand-written, and always the final section.

## The evidence

Each piece below is produced by the agent or skill named, at the model named (the `Agent` tool's `model` parameter). How to brief each one is your call; what each must return is not.

| Evidence | Produced by | Model |
| --- | --- | --- |
| Code findings | up to three `Explore` subagents | `sonnet` |
| Root cause, for a bug | `brian:diagnose`, inline via the `Skill` tool | — |
| Prior intent | `brian:code-historian` | `sonnet` |
| Architectural direction | one `Plan` subagent, high effort | `opus` |
| Challenge | `brian:challenge`, via the `Skill` tool | pins its own reviewers |
| Test design | `brian:test-designer` | `sonnet` |
| Coherence and protocol | `brian:plan-verifier` | `sonnet` |

- **Code findings.** Concrete file paths, reusable utilities, and existing patterns, written down. For a bug, a regression, or "why is X broken", the findings are `brian:diagnose`'s root cause, defect class, and suggested fix shape. Those are findings, not a design: the direction still comes from the `Plan` agent.
- **Prior intent.** The why behind earlier changes to the code about to be modified, so the plan does not repeat a past failure or invert a past decision blindly: a timeline of meaningful commits, linked tickets with verbatim "why" quotes (or an explicit note that there is no tracker or no linked ticket), recurring themes, and implications for this change. The historian works from the topic and a focusing question and detects the ticket tracker itself, so it does not need Explore's paths and can run alongside Explore. The files it inspected must cover the critical paths Explore surfaced; a narrow second pass scoped to the uncovered paths closes a gap.
- **Brian's answers.** Any ambiguity that would change the chosen approach is closed by asking Brian: one to three questions in one plain-text batch, on direction, trade-offs, scope boundaries, and integration choices only. A question the code can answer is answered from the code. Each question and option is in plain English a smart non-engineer could answer from, free of class names and file paths, with the recommended option first and labelled `(Recommended)`. An unambiguous requirement gets no questions and the note "no architecture ambiguity".
- **Skill scan.** One line per skill, `skill-name: relevant? (yes/no — one-sentence reason)`, for every skill in the available-skills list and every project skill under `.claude/skills/` and `<git-root>/plugins/*/skills/`, with each relevant skill invoked before the direction is designed. The list is written down even when nothing applies, because an unwritten scan cannot be told from a skipped one.
- **Architectural direction.** The direction comes from the `Plan` agent, which is given the code findings, the historian's report, the requirement and its constraints, the skill scan, and Brian's answers, and is told the altitude to write at. Its return is written verbatim to the working plan file before any restructuring, and the sections above are built from it without discarding its content. Nothing external can tell the agent's return from your own paraphrase of what it would have said, so ask honestly which one the file holds. A design you wrote yourself because it felt coherent is not this evidence, and neither is `brian:diagnose`'s output.
- **Challenge.** `brian:challenge` is given the absolute path of the working plan file, so its reviewers read the artifact the implementer will. It surfaces every tension to Brian as a decision. Each direction he gives is written into the file, as the revision it called for or as an explicit acceptance of the risk he chose to keep.
- **Test design.** `brian:test-designer` is given the file's path and told plainly how the requirement arrived: as a bug, where it must design a regression test that pins the diagnosed root cause, or as a feature. It inserts `## Test design` between Skills to use and Verification and touches no other section. It runs on the approach as Challenge left it, because a Test design written earlier is orphaned by Challenge's in-place revisions. When it reports a problem, the cause is fixed in the plan and it runs again, until its reply reads as satisfied.
- **Coherence and protocol.** `brian:plan-verifier` is given the file's path. It confirms the plan reads as one narrative from Context to Verification with no residue of a superseded decision, which Challenge's in-place revisions tend to leave, and it injects the protocol block. It reports and does not fix: residue is cut from the file and the verifier runs again. Its confirmation is evidence only for the file as it was when the verifier read it.

**An untestable approach.** When `test-designer` says the approach itself cannot be tested (every test deferred, or no regression test can pin the diagnosed root cause), the direction is wrong. The concern goes back to the `Plan` agent, and the plan file, the challenge, and the test design are produced again for the revised direction. This is the one case where Challenge runs twice.

## When to wait

Brian is asked three times at most: the question round, the tensions Challenge surfaces, and the plan itself once plan mode is exited. Everything between runs without asking. When a piece of evidence cannot be produced, say what blocks it in one line and wait.

This skill is the source of truth for how a requirement becomes a plan; where a `CLAUDE.md` says otherwise, this skill holds until the two are reconciled.

## Verify

The run is long enough to be compacted, so register each check below as a task before any planning work and complete a task only when its evidence exists. A check left pending is then visible instead of forgotten.

- The working plan file exists and its absolute path is in chat.
- Code findings are written down with file paths, or with root cause and defect class for a bug.
- The historian's report is in hand, and the files it inspected cover the critical paths Explore surfaced.
- Brian answered the question round, or "no architecture ambiguity" is recorded.
- The skill scan is written, one line per skill, and every skill marked relevant was invoked.
- The working plan file held the `Plan` agent's verbatim return before it was restructured.
- Re-reading the file end to end: Context names the requirement's source by quote or id at the final agreed scope and inlines at least one code finding; Prior intent has commit-hash or ticket-key anchors; Skills to use lists every skill the scan marked relevant, or states `None`; every critical premise carries `verified by:` or `unverified — checkable by:`; and no section holds a code snippet, a function signature, or a per-file edit list.
- Every tension Challenge surfaced has Brian's direction, and that direction is in the file.
- `test-designer`'s last reply reads as satisfied, and `## Test design` sits between Skills to use and Verification.
- `plan-verifier`'s last reply confirms one coherent narrative and says whether the protocol block was injected fresh, was already present, or had drifted and was corrected. That reply is later than the last edit to the file, and `## Post-implementation protocol` is the file's final section.
- Plan mode's plan file matches the working plan file end to end, and plan mode has been exited.
