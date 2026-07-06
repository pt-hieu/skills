# Skills Marketplace

## Authoring stance: no verbatim rigidity

Skills prescribe the *process* (steps, gates), not the judgment — within a step, how to satisfy the gate is the agent's call. Don't have pipelines copy long instruction blocks verbatim into runtime state (task descriptions) or into sibling skills; register short pointers back to the canonical section instead, so each meaning keeps a single source of truth.

## Skill anatomy: phonebook + references

A skill's prose lives in exactly two kinds of file:

1. **`SKILL.md`** — injected whole into context on invocation. It is the skill's **phonebook**: everything the agent needs on every run — steps, gates, rules — written in full, plus one pointer per reference file. A pointer's wording decides whether it ever fires: state the condition for opening it ("on testability FAIL, read `references/…`"), never a bare "see also".
2. **`references/*.md`** — deep dives loaded on demand: rare branches, rationale and trade-off records, long examples, exhaustive catalogs.

Size for the sweet spot — every inline line taxes every invocation, every extra file taxes attention with a hop:

- Inline what every run needs; disclose to `references/` what only some runs reach; delete what no run reads.
- A `SKILL.md` drifting past ~150 lines is a smell, not a cap — audit which sections only some runs need and push those down. Keep it whole when every line genuinely runs every time.
- A reference file too thin to justify its hop (roughly under 20 lines) is fragmentation — inline it back.

Existing `instructions.md` bodies are grandfathered: fold each into its `SKILL.md` the next time that skill is touched.

## Versioning (required before committing)

For every touched plugin under `plugins/<name>/`, bump:

1. `plugins/<name>/.claude-plugin/plugin.json` — the plugin's own `version`.
2. `.claude-plugin/marketplace.json` — the matching per-plugin `version` entry.
3. `.claude-plugin/marketplace.json` — the top-level `metadata.version` (whenever any plugin version changes or the marketplace itself changes).

All three bumps go in the same commit as the change.

## Listing sync (required before committing)

For every touched plugin, the top-level `README.md` reference table and the plugin's `plugin.json` / `marketplace.json` descriptions list exactly the skills present under `plugins/<name>/skills/`, and the README names every agent under `plugins/<name>/agents/`. Touching a skill or agent re-syncs all four.
