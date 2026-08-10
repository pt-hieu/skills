# Contract Audit — run before every spec-stripping change

Fires when you delete, rename, or retire a field of the reviewer Output Contract (Step 2) or a Step 3 closing-verdict keyword. Not part of a normal challenge run — this is a maintenance gate for skill authors.

Before deleting or renaming any field listed below, grep both scopes for the literal token:

- `plugins/brian/agents/*.md`
- `plugins/brian/skills/**/*.md`

The reviewer agents narrate the contract in their Input Contract sections, and the `autopilot` and `scrutinize` skills carry their own copies of the Output Contract — so a token rename must touch every copy in the same commit. Use directory-level globs (never hardcode a specific `instructions.md`/`SKILL.md` path — sibling skills are restructured independently). For every hit, plan a same-commit edit that updates the prose, and add the affected file(s) to the commit's diff before pushing.

Currently-live contract tokens (alphabetized):

- `accurate` / `discrepancies` / `unsound` (Step 3 closing-verdict keywords, emitted by `plan-fact-checker` per `plugins/brian/agents/plan-fact-checker.md:53-60`; consumed by challenge/SKILL.md's Step 3 keyword-mapping table, which reads the keyword deterministically rather than inferring a verdict from tone)
- `defect_class` (now a free-prose field — reviewers name the defect class in plain words; there is no fixed vocabulary, no shared SSOT file, and no runtime injection sentinel. The field itself stays on the anchor as the `(file, defect_class)` merge key.)
- `Finding Anchor`
- `INSUFFICIENT CONTEXT`
- `Output Contract`
- `pass` / `concerns` / `rethink` (Step 3 closing-verdict keywords, emitted by `architectural-reviewer` per `plugins/brian/agents/architectural-reviewer.md:180-185` and required of the runtime-authored bespoke critic per `references/bespoke-critic.md`'s authoring rules; consumed by challenge/SKILL.md's Step 3 keyword-mapping table)
- `Premise Audit` (plan-mode contract section — narrated by all three plugin reviewer agents, and injected verbatim into the bespoke critic's prompt)
- `Resolved Gaps` (Step 3.1 retry section — injected by the orchestrator into the re-launched agent's prompt)

Retired — do not reintroduce without a consumer: `DEFERRED`, `ESCALATED-CRUX`, `FIXED`, `REBUTTED-CITE`, `REBUTTED-JUDGMENT`, `Prior Round Findings`, `Round N Changes`. Nothing branches on these any more: Step 4 hands each finding to the user as a decision, and the user's direction is recorded in prose.

The Step 4 tension markers `➡️` / `🛑` / `？` are render shape, not contract tokens: no code or consumer parses them, and the user reads the block for meaning. They belong to `references/templates.md` and are not audited here.

When the orchestrator-emit shape evolves (new field added, existing field renamed, token retired), update this list in the same commit. The list is the single source of truth — agents narrate it in their Input Contract sections; this audit step keeps both sides aligned.
