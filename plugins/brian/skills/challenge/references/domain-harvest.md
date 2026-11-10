# Domain knowledge — `{knowledge_context}`

`{knowledge_context}` is the project's own knowledge that bears on the affected files, handed to every panel agent so it reviews against documented patterns and not only general principles.

> Scope: this skill intentionally violates the `prompting` skill's
> rule that code computes every number and the LLM only interprets.
> Rationale: the orchestrator is the sole consumer of any quantitative state
> here (no cross-process handoff). Verbal discipline + a human-readable run
> file is sufficient for single-process loops. The prompting rule still
> binds for any agent shipped for external consumers.
>
> The one concrete quantitative artifact this covers is the relevance
> formula below — keep it and this rationale together so a future editor does
> not "fix" the formula blindly.

## What it holds

**Up to five Skill Context Blocks**, the five most relevant skills, most relevant first, at most 200 words each and 1500 words together. When the total runs over, the lowest-ranked whole block is dropped; a block is never truncated.

Candidates are the project's skills, deduped by name in this priority order: `.claude/skills/*/SKILL.md`, `plugins/*/skills/*/SKILL.md` (which catches plugin marketplaces), and `<git-root>/.claude/skills/*/SKILL.md`. User skills under `~/.claude/plugins/marketplaces/*/plugins/*/skills/*/SKILL.md` are candidates too, and compete on the same score. Relevance is:

```
relevance = (path-overlap-with-affected-files * 3)
          + (name-mention-in-context-or-paths * 2)
          + (description-domain-match * 1)
```

Each block has this shape:

```
### Skill: {name}
**Domain**: {what area this covers}
**Patterns to verify**: {documented patterns the diff/plan should follow}
**Constraints/Gotchas**: {rules that could be violated — review criteria}
**Deep-dive paths**: {file paths agents can Read for more context}
```

**One Project Rules Block**, at most 500 words and outside the five-skill limit, drawn from `<git-root>/CLAUDE.md`, `<git-root>/.claude/CLAUDE.md`, `~/.claude/CLAUDE.md`, any `*/CLAUDE.md` whose directory is an ancestor of an affected file (monorepo support), `<git-root>/AGENTS.md`, and `<git-root>/CONTRIBUTING.md`. `README.md` is left out as too noisy.

When there are no blocks at all, `{knowledge_context}` is this sentence: `"No project-specific skills or CLAUDE.md found. Review using general software engineering principles only."`
