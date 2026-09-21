# flyingsalmon rules for prototypes

Distilled from flyingsalmon at commit `5b8bce1`: `CLAUDE.md`, `CONTEXT.md`, `docs/adr/`, and the `interface-review` skill. These are the rules that change rarely. The component list is never recorded here; read it from `https://flyingsalmon.superbrian.dev/r/registry.json`. When this file and the published registry disagree, the registry wins, and the commit message says where they disagreed.

## Hard gate

Every piece of UI is a registry component or a composition of registry components and theme tokens. Import each component from its folder root, never from a file inside it. Icons come from `lucide-react`.

## Look

- **Mood** — soft, minimal, playful.
- **Type** — Baloo 2 (`--font-heading`) for headings and display, Onest (`--font-sans`) for body and UI. No other typeface.
- **Color** — an indigo accent over pure neutral grays, all OKLCH, reached only through the functional aliases (`--background`, `--primary`, `--muted`, `--destructive`, `--success`, `--warning`, `--error`, `--border`, and their `-foreground` pairs). No raw hex or `rgb()`, and no alpha on any color; softness comes from a lighter or darker palette step. Element opacity is for disabled states and motion only.
- **Surfaces** — flat. No shadows and no elevation. Surfaces separate by solid borders and background steps, and interaction feedback shows in the border.
- **Radius** — derived from `--radius` through `--radius-sm` … `--radius-4xl`. Never a hardcoded value.
- **Motion** — small, springy, under 200ms; spinner and skeleton are exempt. Durations come from `--motion-fast` and `--motion-base`, springs from the registry's `motion` item. `prefers-reduced-motion` is not handled anywhere in the system and a prototype does not add it.
- **Dark mode** — the `dark` class on `<html>`. Prototypes are reviewed in dark mode.

## Feedback rule

The acting component shows its own busyness: a button morphs through its loading state, a field shows its own error. A result appears where the user's attention already is and stays until seen. Homes for a result, in order:

1. The affected item — it appears, updates, or shows a failed state with retry.
2. The acting surface — the form's result slot, below the actions row, as an alert.
3. A notice — only when the result has no visible home: after navigation, from a closed dialog form, for a confirm-only action.

Anything that auto-dismisses, stacks, has no owner, or has no link back to its subject is banned. That covers every toast and snackbar.

## Choosing between components

- **Dialog or drawer** — a dialog interrupts and sits centred; a drawer accompanies the page still visible beside it (filters for a list, the detail of a selected row). A drawer is never app navigation and never a confirm. While an operation runs inside either, set `pending`; the button inside carries the spinner.
- **Sidebar, breadcrumb, tabs** — sidebar moves between sections at every width; breadcrumb moves up within one hierarchy and has at least two levels; tabs switch between peer panels.
- **Stepper, progress, timeline, pagination** — stepper shows position in a sequence with a known count and never navigates; progress is a fraction of one operation; timeline lays out markers joined by connectors and carries no item states; pagination moves between numbered pages of one list, and a one-page list has none.
- **Empty state, skeleton, alert** — a region that rests with no content shows an empty state with a reason and an action; a region still fetching shows a skeleton matching the eventual layout; a failed action reports through the feedback rule.
- **Toggle-group, checkbox, radio-group** — toggle-group is chips that toggle, where single mode can return to empty and multiple mode is one group with a `max`. A chip that does not toggle is a badge.
- **Text link or button** — a link navigates and a button acts. An action inside a sentence is a button placed inline.
- **Field family** — input, textarea, checkbox, select, radio-group, date-picker, combobox, number-field, and toggle-group own their label and error message. Switch has a label and no error state; a failed toggle is a result the app shows.
- **Carousel** — a free-scrolling, scroll-snapping row where several items can be visible; it is not a slideshow.

