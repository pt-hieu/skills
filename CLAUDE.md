# Skills Marketplace

Brian's personal Claude Code skills marketplace: plugins live under `plugins/<name>/`, each registered in `.claude-plugin/marketplace.json`.

## Authoring skills

### Process, not judgment

Skills prescribe the *process* (steps, gates); within a step, how to satisfy the gate is the agent's call. Keep each meaning in a single source of truth: pipelines register short pointers back to the canonical section, and sibling skills point at that section rather than carrying their own copy.

### Anatomy: phonebook + references

A skill's prose lives in exactly two kinds of file:

1. **`SKILL.md`** — injected whole into context on invocation. The skill's **phonebook**: everything the agent needs on every run — steps, gates, rules — written in full, plus one pointer per reference file. A pointer's wording decides whether it ever fires: state the condition for opening it ("on testability FAIL, read `references/…`"), never a bare "see also".
2. **`references/*.md`** — deep dives loaded on demand: rare branches, rationale and trade-off records, long examples, exhaustive catalogs.

Size for the sweet spot — every inline line taxes every invocation, every extra file taxes attention with a hop:

- Inline what every run needs; disclose to `references/` what only some runs reach; delete what no run reads.
- A `SKILL.md` drifting past ~150 lines is a smell, not a cap — push down the sections only some runs need; keep it whole when every line genuinely runs every time.
- A reference file too thin to justify its hop (roughly under 20 lines) is fragmentation — inline it back.

## Before committing

**Version bumps** — for every touched plugin, in the same commit as the change:

1. `plugins/<name>/.claude-plugin/plugin.json` — the plugin's own `version`.
2. `.claude-plugin/marketplace.json` — the matching per-plugin `version` entry.
3. `.claude-plugin/marketplace.json` — the top-level `metadata.version` (whenever any plugin version changes or the marketplace itself changes).

**Listing sync** — for every touched plugin: the top-level `README.md` reference table and the plugin's `plugin.json` / `marketplace.json` descriptions list exactly the skills present under `plugins/<name>/skills/`, and the README names every agent under `plugins/<name>/agents/`. Touching a skill or agent re-syncs all four.
