# Catalog: TypeScript and React

Each section opens with a blockquote saying when it applies and what to adapt. Everything after the blockquote is the section text for `CODING_STANDARDS.md`.

## Enums, not string unions

> Applies to every TypeScript repo, with or without a UI.
>
> Adapt: in a repo with no UI, the second sentence of the first paragraph ends at "declared in the `types.ts` of the module that owns the set", the values are the strings the wire format or storage already uses, and "props default to an enum member" and "docs pages" drop out. In a Tailwind + cva repo, `styling.md` carries a replacement for the second paragraph.

A closed set of string values is a TypeScript enum with string values, declared in `types.ts`. Members are PascalCase. Values are the kebab-case strings the DOM and the class names use.

The enum is the source of truth. Do not declare the set as a union type. Lookup tables and class name maps key on the enum members, props default to an enum member, and every consumer, including docs pages and tests, passes the enum member rather than its string value.

Boolean variants are not string sets and stay booleans. A type alias that only re-exports a third-party type is not a string set and stays an alias in `types.ts`.

## Components are folders

> Applies to every repo that defines React components in TypeScript.
>
> Adapt: the styling bullet in the file list comes from the matching section of `styling.md`; a repo whose styling approach the catalog lacks gets no styling bullet. When components live under one directory, name it in the first sentence ("Every component is a folder under `src/components/`, …"). When the repo ships a shadcn registry (`registry.json` at the root), the first paragraph continues: "The folder is the unit `registry.json` ships, so every file in it, except those under `__test__/`, is listed in the item's `files`."

Every component is a folder, named after the component in kebab-case. A folder holds these files:

- `index.ts` re-exports the folder's public surface and defines nothing.
- One `.tsx` file per component, named after the component in kebab-case, defining that component and its props interface.
- `types.ts` holds every type the folder exports, except component props.
- `utils.ts` holds the folder's utility functions with low cognitive complexity, including every value a component derives from props or state beyond a single expression.
- Any other runtime value the folder needs, such as a React context, a hook, a lookup table, or a utility function too involved for `utils.ts`, gets its own file named after what it holds.

Consumers import from the folder, never from a file inside it.

A `.tsx` file defines exactly one component, named after the file in PascalCase. A folder that ships several components has one file per component beside the main one.

Utility functions do not each need a file. The ones with low cognitive complexity, short and with no nested logic, share the folder's `utils.ts`. A utility function whose branching or nesting takes effort to follow gets its own file, named after the function.

Every exported type the folder defines goes in `types.ts`: variant enums, context value shapes, aliases over third-party types, prop-derived helpers. The one exception is the component's own props interface, which stays in the component file directly above the component so the contract and the implementation read together.

## Tests, in a React repo

> Applies when the repo tests React components. This is not a section of its own: its text goes into the Tests section from `any-stack.md`.
>
> Adapt: replace `<component test file>` with a real or implied path from the repo, such as `src/registry/ui/avatar/__test__/avatar.test.tsx`. Name the DOM environment the test runner is configured with (jsdom, happy-dom) in the mock bullet.

This sentence ends the placement paragraph:

A component folder's behavior tests go in one file named after the folder, such as `<component test file>`.

These bullets take the place of their any-stack counterparts (the first, the second, "Every utility function", and "Run the real collaborators"), and the class names bullet is new, placed second:

- Assert on what a consumer can observe. For a component, that is the rendered content, accessible names and states, focus, or a prop callback firing. For a utility function, it is the value returned for the inputs a caller passes. Asserting that an internal function was called pins the implementation.
- Do not test the class names or styles a target renders. A class name, an inline style, a CSS value, a motion or design constant, or a value that only feeds one of them restates the design. A restyle breaks such a test without breaking anything a consumer relies on.
- Do not pin values no consumer can observe, such as React keys, the shape of internal state, or the format of an internal lookup key. Assert the property the caller relies on instead.
- Every utility function with behavior of its own is tested. A utility function whose output only feeds class names or styles has no behavior of its own.
- Render the real collaborators. Mock only what cannot run in jsdom: network, clock, randomness.
