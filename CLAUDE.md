# Skills marketplace

Brian's personal Claude Code skills marketplace. Each plugin lives under `plugins/<name>/` and is registered in `.claude-plugin/marketplace.json`.

## Authoring skills

Before writing or editing a skill, an agent, or a reference file, read `plugins/brian/skills/prompting/SKILL.md` and its `references/skills.md`. They hold this repo's authoring rules: prose over contracts, a checkable finish line, one source of truth, and what goes in `SKILL.md` versus `references/`.

This repo adds two rules of its own:

- A skill states the result and how to verify it, and leaves the steps to the agent, because a frontier model plans its own route. Besides the result and its verification, a skill holds only what the agent cannot infer: constraints that hold throughout the run, the agents, models, and scripts to use, when to stop and ask, and any format that something parses. Leave out numbered procedures, personas, and catalogs of techniques the model would pick anyway.
- `plugins/brian/skills/challenge/references/contract-audit.md` is the registry of literal tokens that one agent emits and another parses, with every file that emits or consumes each one. A new token gets its row in the same commit that introduces it, and a rename or deletion updates every listed file in that commit. `scrutinize` keeps the tokens local to it in `scrutinize/references/contract-audit.md`. Its "From returns to findings" section is the reference example of a parsing consumer: it parses Finding Anchors, normalizes line spans, and dedupes on `(file, line)`, and judges severity from the reviewer's prose.

## Before committing

For every plugin the commit touches, in the same commit:

- **Versions.** Bump `version` in `plugins/<name>/.claude-plugin/plugin.json` and the matching plugin entry in `.claude-plugin/marketplace.json`. Bump the top-level `metadata.version` in `marketplace.json` whenever a plugin version or the marketplace itself changes.
- **Listings.** The top-level `README.md` table and the descriptions in `plugin.json` and `marketplace.json` list the skills under `plugins/<name>/skills/`, and the README names every agent under `plugins/<name>/agents/`.
