---
name: setup-coding-standard
description: "Write or update a repo's CODING_STANDARDS.md from Brian's catalog of standards, picking the sections that fit the repo's stack."
argument-hint: "[repo path]"
disable-model-invocation: true
---

# Setup Coding Standard

Every rule in the `CODING_STANDARDS.md` this skill writes comes from Brian's **catalog** — the section files under `references/` — and a section goes in only when evidence in the repo meets its condition. The catalog is the single home of the wording; the repo's file is a selection from it with the repo's own paths filled in.

The target is the repo at the path given as the argument, or the current working directory.

## Step 1 — Survey the stack

Read the repo's manifests and configuration (`package.json` and workspace packages, `tsconfig*.json`, the test runner's config, the formatter's config, `components.json`, `registry.json`), its directory layout, `docs/` for ADRs, `CLAUDE.md` / `AGENTS.md`, and any existing `CODING_STANDARDS.md`. In a monorepo, survey each package: a section applies when any package meets its condition.

Done when you can state each of these and name the file that proves it: languages, UI framework, styling approach, test runner and its DOM environment, formatter, the directory components live in, and whether a `CODING_STANDARDS.md` exists.

## Step 2 — Select from the catalog

Each catalog section opens with a blockquote stating when it applies and what to adapt. Open a catalog file when the survey meets its condition:

- `references/any-stack.md` — always. Source text, Grouping, and the base Tests section.
- `references/typescript-react.md` — when the repo has TypeScript. Enums for any TypeScript repo; Components are folders and the React additions to Tests when it defines React components.
- `references/styling.md` — when the repo defines React components. Tailwind + cva, or CSS Modules + design tokens.

A section is selected when the survey proves its condition, and left out otherwise. Where the repo's stack reaches past the catalog (another language's idioms, another UI framework, another styling approach), the file carries no section for it: the catalog has no wording to select, and the gap goes in the Step 5 report.

Done when every catalog section you opened is marked selected or left out, each with the survey fact that decided it.

## Step 3 — Adapt the selected text

Apply each selected section's adapt notes. Every placeholder becomes a real path from the repo, every example names files that exist or that the rule implies, and an ADR is cited only when that ADR exists in the repo. Text with no adapt note is copied as the catalog has it.

Assemble the sections in this order under a `# Coding standards` title: Source text, Grouping, Components are folders, Class names live in classnames.ts, Enums, not string unions, Tests.

## Step 4 — Write the file

**New file** — write `CODING_STANDARDS.md` at the repo root.

**Existing file** — sort its sections into three kinds:

- A section the catalog lacks is the repo's own rule. Leave it as it is.
- A selected catalog section the file lacks is added, in catalog order relative to its neighbours.
- A section present in both whose wording differs is Brian's call: the repo may have diverged on purpose. Show him the two wordings side by side and replace only the ones he approves. Make the additions without waiting.

Then check `CLAUDE.md` (or `AGENTS.md`): when neither points at `CODING_STANDARDS.md`, add one line that does: "Every coding rule is in `CODING_STANDARDS.md`." Create no agent instruction file for this alone.

The file describes the standards as they are. It carries no mention of the catalog, this skill, or an earlier version of itself.

## Step 5 — Report

Tell Brian which sections went in and the survey fact behind each, which were left out and why, what the catalog had no section for, and any repo-own section that looks general enough to join the catalog.

## It's working if

- Every section in the written file traces to a catalog section, and every selected section to a named file in the repo.
- The written file has no `<placeholder>` left, and no path or ADR number that belongs to flyingsalmon.
- An existing file's own sections are byte-identical after the run.
