# Contract Audit — run before every spec-stripping change

Fires only when you delete, rename, or retire a field of the reviewer Output Contract (Step 2). Not part of a normal challenge run — this is a maintenance gate for skill authors.

Before deleting or renaming any field listed below, grep both scopes for the literal token:

- `plugins/brian/agents/*.md`
- `plugins/brian/skills/**/*.md`

The reviewer agents narrate the contract in their Input Contract sections, and the `autopilot` and `scrutinize` skills carry their own copies of the Output Contract — so a token rename must touch every copy in the same commit. Use directory-level globs (never hardcode a specific `instructions.md`/`SKILL.md` path — sibling skills are restructured independently). For every hit, plan a same-commit edit that updates the prose, and add the affected file(s) to the commit's diff before pushing.

Currently-live contract tokens (alphabetized):

- `defect_class` (now a free-prose field — reviewers name the defect class in plain words; there is no fixed vocabulary, no shared SSOT file, and no runtime injection sentinel. The field itself stays on the anchor as the `(file, defect_class)` merge key.)
- `Finding Anchor`
- `INSUFFICIENT CONTEXT`
- `Output Contract`
- `Prior Round Findings`
- `Resolved Gaps`
- `Round N Changes`

When the orchestrator-emit shape evolves (new field added, existing field renamed, token retired), update this list in the same commit. The list is the single source of truth — agents narrate it in their Input Contract sections; this audit step keeps both sides aligned.
