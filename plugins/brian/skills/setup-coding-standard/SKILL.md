---
name: setup-coding-standard
description: "Write or update a repo's CODING_STANDARDS.md from Brian's catalog, and its CODE_MAP.md."
argument-hint: "[repo path]"
disable-model-invocation: true
---

# Setup Coding Standard

Every rule in the `CODING_STANDARDS.md` this skill writes comes from Brian's **catalog** — the section files under `references/` — and a section goes in only when evidence in the repo meets its condition. The catalog is the single home of the wording; the repo's file is a selection from it with the repo's own paths filled in. The skill also writes `CODE_MAP.md`, a guide to where things live in the repo.

The target is the repo at the path given as the argument, or the current working directory.

## The result

- **`CODING_STANDARDS.md`** at the repo root, holding the catalog sections the repo's evidence selects, adapted to the repo.
- **`CODE_MAP.md`** at the repo root, written or updated as `references/code-map.md` describes, naming every top-level directory, package, and entry point.
- **`CLAUDE.md`** (or `AGENTS.md`) pointing at both: the line "Every coding rule is in `CODING_STANDARDS.md`." when neither file points there yet, and the block from `references/code-map.md`. No agent instruction file is created for the pointer alone.
- **The design language**, when the repo has a UI whose look Brian decides: a `DESIGN-LANGUAGE.md` at the repo root, and the block from `references/design-language.md` in `CLAUDE.md` (or `AGENTS.md`).
- **The report** to Brian: which sections went in and the evidence behind each, which were left out and why, what the catalog had no section for, any repo-own section that looks general enough to join the catalog, whether `DESIGN-LANGUAGE.md` was written and its block added, and why, and whether `CODE_MAP.md` is new or updated, with the paths the update fixed.

## Evidence

A section is selected when a named file in the repo proves its condition, and left out otherwise. The facts that decide the selection, each with the file that proves it: languages, UI framework, styling approach, test runner and its DOM environment, formatter, the directory components live in, the entry points, whether a `CODING_STANDARDS.md`, a `DESIGN-LANGUAGE.md`, and a `CODE_MAP.md` exist, and whether the repo has a UI whose look Brian decides. They come from the manifests and configuration (`package.json` and workspace packages, `tsconfig*.json`, the test runner's and formatter's configs, `components.json`, `registry.json`), the directory layout, `docs/` for ADRs, and `CLAUDE.md` / `AGENTS.md`. In a monorepo a section applies when any package meets its condition.

## The catalog

Each catalog section opens with a blockquote stating when it applies and what to adapt.

- `references/any-stack.md` — always. Source text, Grouping, Domain state, Boundaries, and the base Tests section.
- `references/typescript-react.md` — when the repo has TypeScript. Types admit only valid states, and Enums, for any TypeScript repo; Components are folders and the React additions to Tests when it defines React components.
- `references/styling.md` — when the repo defines React components. Tailwind + cva, or CSS Modules + design tokens.

Where the repo's stack reaches past the catalog (another language's idioms, another UI framework, another styling approach), the file carries no section for it: the catalog has no wording to select, and the gap goes in the report.

## The standards file

The sections sit under a `# Coding standards` title in this order: Source text, Grouping, Domain state, Boundaries, Types admit only valid states, Components are folders, Class names live in classnames.ts, Enums, not string unions, Tests.

Each selected section has its adapt notes applied: every placeholder is a real path from the repo, every example names files that exist or that the rule implies, and an ADR is cited only when that ADR exists in the repo. Text with no adapt note reads as the catalog has it.

The file describes the standards as they are. It carries no mention of the catalog, this skill, or an earlier version of itself.

When the repo already has a `CODING_STANDARDS.md`, its sections are of three kinds:

- A section the catalog lacks is the repo's own rule, and stays as it is.
- A selected catalog section the file lacks is added, in catalog order relative to its neighbours, without waiting for Brian.
- A section present in both whose wording differs is Brian's call, because the repo may have diverged on purpose. Show him the two wordings side by side and replace only the ones he approves.

## The design language

Read `references/design-language.md` when the repo has a UI whose look Brian decides. A new `DESIGN-LANGUAGE.md` holds the single line `# Design language`; Brian's rules join it as his feedback arrives. An existing one holds Brian's taste and stays as it is. The block from the reference replaces an existing pointer line to `DESIGN-LANGUAGE.md` in `CLAUDE.md` (or `AGENTS.md`), and goes where the reference says when there is none. The rules live in `CLAUDE.md` because that file is loaded into every session, where they shape what gets written into `DESIGN-LANGUAGE.md`.

## Verify

- Every section in the written file traces to a catalog section, and every selected section to a named file in the repo. Every catalog section opened is accounted for in the report as selected or left out.
- The written file and the design-language block have no `<placeholder>` left, and no path or ADR number that belongs to flyingsalmon.
- An existing file's own sections are byte-identical after the run, an existing `DESIGN-LANGUAGE.md` is untouched, and no differing section was replaced without Brian's approval.
- Every path `CODE_MAP.md` names exists in the repo, every top-level directory, package, and entry point appears in it, and `CLAUDE.md` or `AGENTS.md` points to it.
- Every `DESIGN-LANGUAGE.md` in the repo has the pointer and the rules from `references/design-language.md` in `CLAUDE.md` or `AGENTS.md`.
