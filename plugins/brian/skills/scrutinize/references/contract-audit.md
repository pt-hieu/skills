# Contract Audit

Shared-contract tokens this skill consumes. Renaming or deleting any of them is a multi-file change — grep the listed owners in the same commit. ("this file" below means `SKILL.md`, the orchestrator's execution guide.)

| Token | Owner file |
|---|---|
| `defect_class` (free-prose phrase; the `(file, …)` merge key and render slot) | this file (Step D.1) + agents narrate it in their Input Contract |
| `Finding Anchor` | this file (Step D.1) + shared agents narrate the format |
| `Output Contract` (block name) | this file (Step D.1) + agents' Input Contract sections |
| `House Rules` (block name) | `skills/scrutinize/references/reviewer-house-rules.md` (plugin-root-relative) |
| `Repo Root`, `Diff`, `Changed Files`, `Project Rules`, `Axis` (block names) | this file (Step D.1) |
| `Zero Tests Flag` (per-axis hint) | this file (Step C.4) + `review-tests.md` |
| `Spec`, `Spec Source` (per-axis hint block names) | this file (Steps C.7, D.2) + `review-spec.md` |
| `spec_source`, `spec_text`, `spec_source_label` (run-state) | this file (Steps A, C.7, D.2) |
| `review-spec` (agent) | `plugins/brian/agents/review-spec.md` |
| `axis` (orchestrator-side per-agent metadata) | this file (Step E) |
| `axes_dispatched`, `axes_skipped`, `axes_abstained`, `tier` (data-dict fields) | this file (Steps C, E, F) |

The `defect_class` field is now free prose — reviewers name the defect class in plain words and the orchestrator merges and renders by that phrase; there is no shared vocabulary file or injection step. The widened `cleanness` axis (via `review-cleanness.md`) still covers four behavior-preserving quality angles — reuse, efficiency, simplification, and local altitude — and reviewers describe each in plain words (e.g. "redundant work" for reuse/efficiency, "simplification gap" for simplification/local altitude). Because the field is free prose, nothing needs editing when the vocabulary evolves.
