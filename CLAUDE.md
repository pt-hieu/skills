# Skills Marketplace

## Versioning (required before committing)

For every touched plugin under `plugins/<name>/`, bump:

1. `plugins/<name>/.claude-plugin/plugin.json` — the plugin's own `version`.
2. `.claude-plugin/marketplace.json` — the matching per-plugin `version` entry.
3. `.claude-plugin/marketplace.json` — the top-level `metadata.version` (whenever any plugin version changes or the marketplace itself changes).

All three bumps go in the same commit as the change.
