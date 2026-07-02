# Skills Marketplace

## Versioning (required before committing)

For every touched plugin under `plugins/<name>/`, bump:

1. `plugins/<name>/.claude-plugin/plugin.json` — the plugin's own `version`.
2. `.claude-plugin/marketplace.json` — the matching per-plugin `version` entry.
3. `.claude-plugin/marketplace.json` — the top-level `metadata.version` (whenever any plugin version changes or the marketplace itself changes).

All three bumps go in the same commit as the change.

## Listing sync (required before committing)

For every touched plugin, the top-level `README.md` reference table and the plugin's `plugin.json` / `marketplace.json` descriptions list exactly the skills present under `plugins/<name>/skills/`, and the README names every agent under `plugins/<name>/agents/`. Touching a skill or agent re-syncs all four.
