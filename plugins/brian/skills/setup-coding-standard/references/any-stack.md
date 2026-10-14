# Catalog: any stack

Each section opens with a blockquote saying when it applies and what to adapt. Everything after the blockquote is the section text for `CODING_STANDARDS.md`.

## Source text

> Applies to every repo. `styling.md` carries a third bullet for Tailwind repos.

- No code comments. Names and structure carry the meaning.
- Identifiers are spelled out in full. No abbreviations, no single-letter parameters.

## Grouping

> Applies to every repo. Keep the last sentence only when the repo runs a formatter that collapses blank lines (Prettier, oxfmt, gofmt, Black); otherwise end the section at "its own group."

Statements inside a function are grouped by goal: the lines that together achieve one thing sit next to each other, and a blank line separates one group from the next. Each branch of a conditional is its own group. The formatter keeps a single blank line and collapses runs of them, so the spacing is the author's responsibility and is reviewed like any other part of the code.

## Domain state

> Applies to every repo.
>
> Adapt: when the repo already encodes a piece of domain knowledge in one structure (a state machine, a lookup table keyed on an enum, a discriminated union), name it with its path as the example at the end of the first paragraph; otherwise end the paragraph at "branching on the same condition in several places."

A piece of domain knowledge lives in one structure that encodes it: a state machine for a lifecycle, a lookup table keyed on the variant for per-variant values, a discriminated union for variants that hold different data. Code reads the structure instead of branching on the same condition in several places. In this repo, `<structure>` in `<path>` is one.

- A new variant is a new entry in the structure. A change that adds one more branch to an if/else chain that already exists is the sign the structure is missing.
- State that two booleans would have to keep in sync is one value: `status: Status.Loading` rather than `isLoading` beside `isLoaded`.
- A module is organized around the domain knowledge it owns. A pipeline split into steps (load, validate, transform, save) repeats the same domain rules in each step.
- Logic that lives in one place and has two or three cases stays a plain conditional. A structure earns its place by deleting branches, duplicated rules, or invalid states.

## Boundaries

> Applies to every repo.
>
> Adapt: replace `<boundaries>` with the places data enters this repo (route handlers, `process.env` reads, config files, CLI arguments, IPC messages, `fetch` responses, database rows). When the repo has a parse library (zod, valibot, pydantic), name it in the first bullet: "A parse function, written with zod, turns …".

Data from outside the program, from <boundaries>, is parsed into the repo's own types where it enters. Code past that point trusts those types and checks nothing again.

- A parse function turns raw input into a typed value or an error, and business logic receives the typed value.
- Business logic is pure functions with no framework imports. The framework layer parses input, calls them, and writes the output.
- The public surface of a module exposes the repo's domain types. Transport, storage, and wire types stay inside the module that talks to them.

## Tests

> Applies to every repo that has, or will have, a test runner. This is the base section; `typescript-react.md` carries the text a React repo adds to it.
>
> Adapt: the placement paragraph holds where the toolchain leaves placement open (JavaScript, TypeScript, Python). Where the toolchain dictates it (Go's `_test.go`, Rust's inline test modules), state the toolchain's convention in its place. Replace `<source file>` and `<test file>` with a real pair from the repo; in a repo with no tests yet, use a real source file and the test path it implies. Extend the "Every utility function" bullet with the repo's shared-module directories when it has them (flyingsalmon: "whether it lives in a folder's `utils.ts`, in a file of its own, or in a shared module under `src/lib/`"). When an ADR in the repo depends on the no-tautology rule, cite it at the end of the second paragraph.

A test file sits in a `__test__` folder beside the file it tests and is named after it: `<source file>` is tested by `<test file>`.

A test verifies the behavior of its target, never how the target achieves it. A test that restates the implementation is tautological: it can only pass. A test that fails on a behavior-preserving refactor is a change detector. Both are worse than no test.

- Assert on what a caller can observe: the value returned for the inputs a caller passes, or the state change the caller relies on. Asserting that an internal function was called pins the implementation.
- Do not pin values no caller can observe, such as the shape of internal state or the format of an internal lookup key. Assert the property the caller relies on instead.
- Every utility function with behavior of its own is tested.
- Do not test a declarative artifact against itself. A reader sees exactly what it accepts, so a test that restates its clauses documents nothing a reader lacks and catches no defect, because there is no logic to get wrong. Test the code that consumes it, where the behavior is emergent.
- Write the expected value out by hand. An expectation computed with the code under test copies its bug and still passes.
- Run the real collaborators. Mock only what cannot run for real: network, clock, randomness.
- When output is unstable, such as generated ids or timestamps, assert the property that must hold rather than the exact string.
- If a behavior-preserving refactor forces a test edit, rewrite that test against the behavior or delete it. Do not patch the expectation.
