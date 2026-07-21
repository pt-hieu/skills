# Contract Audit — run before every spec-stripping change

Fires when you delete, rename, or retire a field of the reviewer Output Contract (Step 2), a Step 3 closing-verdict keyword, or a Step 4 disposition token. Not part of a normal challenge run — this is a maintenance gate for skill authors.

Before deleting or renaming any field listed below, grep both scopes for the literal token:

- `plugins/brian/agents/*.md`
- `plugins/brian/skills/**/*.md`

The reviewer agents narrate the contract in their Input Contract sections, and the `autopilot` and `scrutinize` skills carry their own copies of the Output Contract — so a token rename must touch every copy in the same commit. Use directory-level globs (never hardcode a specific `instructions.md`/`SKILL.md` path — sibling skills are restructured independently). For every hit, plan a same-commit edit that updates the prose, and add the affected file(s) to the commit's diff before pushing.

Currently-live contract tokens (alphabetized):

- `accurate` / `discrepancies` / `unsound` (Step 3 closing-verdict keywords, emitted by `plan-fact-checker` per `plugins/brian/agents/plan-fact-checker.md:53-60`; consumed by challenge/SKILL.md's Step 3 keyword-mapping table, which reads the keyword deterministically rather than inferring a verdict from tone)
- `defect_class` (now a free-prose field — reviewers name the defect class in plain words; there is no fixed vocabulary, no shared SSOT file, and no runtime injection sentinel. The field itself stays on the anchor as the `(file, defect_class)` merge key.)
- `DEFERRED` (Step 4 disposition token, defined in `references/templates.md`'s Round N Changes block; challenge/SKILL.md Step 5 keys off it for the disposition-rule-enforcement check — flags `DEFERRED` without a follow-up reference)
- `ESCALATED-CRUX` (Step 4 disposition token — Step 5's crux branch and `references/crux-round.md` key off it)
- `Finding Anchor`
- `FIXED` (Step 4 disposition token, defined in `references/templates.md`'s Round N Changes block; challenge/SKILL.md Step 5's diminishing-returns check keys off it — a finding marked `FIXED` in a prior round reappearing in a new Synthesis ends the loop)
- `INSUFFICIENT CONTEXT`
- `Output Contract`
- `pass` / `concerns` / `rethink` (Step 3 closing-verdict keywords, emitted by `architectural-reviewer` per `plugins/brian/agents/architectural-reviewer.md:180-185` and reused verbatim by the wildcard-lens prompts in `references/wildcard-lenses.md`; consumed by challenge/SKILL.md's Step 3 keyword-mapping table)
- `Premise Audit` (plan-mode contract section — narrated by all three plugin reviewer agents and the wildcard-lens prompts)
- `Prior Round Findings`
- `REBUTTED-CITE` (Step 4 disposition token, defined in `references/templates.md`'s Round N Changes block)
- `REBUTTED-JUDGMENT` (Step 4 disposition token, defined in `references/templates.md`'s Round N Changes block; challenge/SKILL.md Step 5 keys off it for the disposition-rule-enforcement check — flags `REBUTTED-JUDGMENT` used outside its eligibility filter, or of a high-severity finding without a documented sibling-instance check)
- `Resolved Gaps`
- `Round N Changes`
- `systematic` / `partial` / `patch-only` (Step 3 closing-verdict keywords, emitted by `root-cause-reviewer` per `plugins/brian/agents/root-cause-reviewer.md:297-306`; consumed by challenge/SKILL.md's Step 3 keyword-mapping table)

The crux round carries its own mini-contract in `references/crux-round.md` (no Finding Anchors); it is self-contained and not part of this token list.

When the orchestrator-emit shape evolves (new field added, existing field renamed, token retired), update this list in the same commit. The list is the single source of truth — agents narrate it in their Input Contract sections; this audit step keeps both sides aligned.
