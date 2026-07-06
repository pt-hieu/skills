# Domain Knowledge Harvest — Step 1.5 pipeline

Gather project-specific knowledge so agents review against documented patterns, not just general principles. The 5-stage pipeline produces `{knowledge_context}` for Step 2.

> Scope: this skill intentionally violates the `prompting` skill's CRITICAL
> rule "Deterministic split — code computes all numbers; LLM interprets only".
> Rationale: the orchestrator is the sole consumer of any quantitative state
> here (no cross-process handoff). Verbal discipline + a human-readable run
> file is sufficient for single-process loops. The prompting rule still
> binds for any agent shipped for external consumers.
>
> The one concrete quantitative artifact this covers is the Stage 2 relevance
> formula below — keep it and this rationale together so a future editor does
> not "fix" the formula blindly.

## Stage 1 — Collect

Walk all sources, build a candidate list `[{source, path, name, description}]`:

- **Project skills** (deduped by name, in priority order):
  - `.claude/skills/*/SKILL.md`
  - `plugins/*/skills/*/SKILL.md` (catches plugin marketplaces)
  - `<git-root>/.claude/skills/*/SKILL.md`
- **User skills** (only if relevant per Stage 2 score):
  - `~/.claude/plugins/marketplaces/*/plugins/*/skills/*/SKILL.md`
- **Project rules sources** (separate from skill blocks; assembled into a Project Rules Block):
  - `<git-root>/CLAUDE.md`, `<git-root>/.claude/CLAUDE.md`, `~/.claude/CLAUDE.md`
  - Any `*/CLAUDE.md` whose directory is an ancestor of an affected file (monorepo support)
  - `<git-root>/AGENTS.md`, `<git-root>/CONTRIBUTING.md` (skip `README.md` — too noisy by default)

## Stage 2 — Score

For each skill candidate compute:

```
relevance = (path-overlap-with-affected-files * 3)
          + (name-mention-in-context-or-paths * 2)
          + (description-domain-match * 1)
```

## Stage 3 — Rank

Stable sort skill candidates by relevance descending.

## Stage 4 — Trim

Keep the top 5 skill candidates after ranking. Discard the rest.

## Stage 5 — Assemble

Compose each kept skill as a Skill Context Block (max 200 words each):

```
### Skill: {name}
**Domain**: {what area this covers}
**Patterns to verify**: {documented patterns the diff/plan should follow}
**Constraints/Gotchas**: {rules that could be violated — review criteria}
**Deep-dive paths**: {file paths agents can Read for more context}
```

Assemble blocks until the aggregate `{knowledge_context}` reaches 1500 words. On overflow drop the lowest-ranked **whole** block; never truncate mid-block. CLAUDE.md / AGENTS.md / CONTRIBUTING.md content goes into a separate Project Rules Block (not subject to the 5-skill trim, capped at 500 words).

If the pipeline yields zero blocks: `"No project-specific skills or CLAUDE.md found. Review using general software engineering principles only."`
