# Catalog: styling

Each section opens with a blockquote saying when it applies and what to adapt. Everything after the blockquote is text for `CODING_STANDARDS.md`. A repo matches at most one of the two approaches; a repo that matches neither takes nothing from this file.

## Tailwind + cva

> Applies when the repo depends on `tailwindcss` and `class-variance-authority`. A Tailwind repo without cva takes only the opacity bullet.

This bullet joins the Source text list. Cite the ADR that fixes the palette when the repo has one, as flyingsalmon does with "(ADR 0004)" after "palette":

- No Tailwind opacity modifiers on colors, because they produce colors outside the palette. Opacity applied to a whole element, as for disabled states and motion, is allowed.

This bullet joins the Components are folders file list, after the `.tsx` bullet:

- `classnames.ts` holds every `cva()` call and every reusable `cn()` class string the folder uses.

This section follows Components are folders, at the same heading level as the other sections:

### Class names live in classnames.ts

Every `cva()` call and every `cn()` call that builds a reusable class string is declared in `classnames.ts` and imported by the component file. The component file may merge the consumer's `className` at the render site. It may not declare a class string of its own.

This paragraph takes the place of the second paragraph of Enums, not string unions:

The enum is the source of truth. Do not declare the set as a union type, and do not derive it from cva's `VariantProps`. `classnames.ts` keys its variant maps on the enum members, props default to an enum member, and every consumer, including docs pages and tests, passes the enum member rather than its string value.

## CSS Modules + design tokens

> Applies when components are styled with `*.module.css` files and a component library supplies design tokens.
>
> Adapt: name the repo's library and its token accessor in the second sentence. With no token-supplying library, the bullet is its first sentence only.

This bullet joins the Components are folders file list, after the `.tsx` bullet:

- `styles.module.css` holds the folder's styles. Colors, spacing, and radii come from Ant Design's design tokens, read through `theme.useToken()`.
