---
name: principles
description: Use when building or reviewing any UI — applying layout/hierarchy and visual-consistency rules, choosing between drawer/dialog/inline patterns, or defining component states. When a project ships its own design-system skill (component library, brand rules), that skill wins on conflicts; this one fills the gaps.
---

# UI Design Principles

When a project ships its own design-system skill (component library, brand rules), that skill wins on any conflict; this one fills the gaps.

## The 9 principles

Non-negotiable. Every build and review run tests against all nine; violations are recorded by principle number.

1. **Consistency creates trust** — One visual language everywhere: cards, strips, panels, and dialogs share one skeleton, with constant spacing, padding, and font sizes on a strict 8px grid. Differentiate with subtle signals (color labels, column spans, tints), never different anatomy — structural variation reads as "different data".
2. **Hierarchy is the product** — Give what matters most visual dominance (size, position, color intensity); high-value items get real estate, low-value items compress. The user should know where to look within 2 seconds without reading anything.
3. **Show relationships, not just data** — Cross-link items via shared keys (IDs, dates, categories) so clicking one surfaces the connected items; the value is in the connections, not the parallel lists.
4. **Match interaction model to usage** — Use side panels to preserve context when users scan and click through items; reserve modals for genuine context switches. Fit the mechanic to how people actually work.
5. **Design for scanning** — Every tag, badge, score, and dot does clear, scannable work: scores as bars not bare numbers, types by color/width/position, sentiment by tint/icon. Fewer meaningful signals beat more ambiguous ones; design for peripheral vision first, focused reading second.
6. **Visual weight tracks data state** — Style each value by what the system knows (good/bad, live/stale). When a condition no longer holds, data has aged out, or an item is superseded, dim the entire container as a unit — don't just annotate with a label — so dead items stop competing with live ones for attention.
7. **Escalation proportional to severity** — Change the whole page shape across tiers (info → warning → alarm) — banners, containers, content opacity — not just a status bar. High counts change banner shape (escalation rows, bulk actions, named callouts); 2 alerts must not look like 30.
8. **Group by decision entity** — Group by the thing you act on (entity, customer, issue), not the event that generated the data (run, batch, date). N alerts for M entities = M collapsible rows; collapse repeats and surface what the grouping reveals (repeat count, source diversity, "4× this week") as insight.
9. **Every drill-down needs a CTA** — Every expanded row or section carries at least one primary action (dismiss, act, snooze) scoped to that content, not a generic page-level action. Information without a next step is a dead-end.

## Hard rules

- Differentiate cards via background tint, badge color, or icon color — never a left/top accent stripe (stripes fragment the visual grid).
- Stick to the defined type scale. If the size you want isn't in it, reach for a different element, not a one-off size.
- Keep live text at full-strength palette color; convey softness with a lighter or darker palette color, not transparency. The one sanctioned reduced-opacity use is whole-container dimming of stale/superseded items (principle 6) — dim the container as a unit, never individual text runs, and keep it above readable contrast.

## Conventions

- **Text casing** — Reserve ALL CAPS for short card/section titles; use sentence case for labels and navigation, and Title Case for chips and badges.
- **Dates** — Display as `DD MMM YYYY` (e.g., "02 Feb 2026"), one format across the entire product so users never re-parse.
- **Numbers** — Keep currency, percent, and compact-number formatting consistent everywhere. Render null/missing values as a single placeholder character or an empty state, never as "null", "N/A", or a blank cell.

## Component states

- **Empty** — Every surface shows an explicit empty state that explains WHY it's empty and what fills it. Make the copy actionable ("Add your first item to start tracking") and give it a primary CTA. For scheduled data, include timing context ("runs at 7 AM on weekdays"). Large surfaces use an illustration; small ones an icon + one line of copy.
- **Error** — Every data-fetching surface shows the error and a retry path; keep any section header visible above the error so the user knows where it failed.
- **Loading** — Every async operation has visible feedback. Mutations disable the trigger and show progress on it (spinner or gerund label like "Saving…"). Queries use skeletons that match the eventual layout (same heights, gaps, padding), not a bare page-level spinner.

## References

- When choosing between a side panel/drawer and a modal/dialog — sizing, content budgets, or the inspect-then-act chaining pattern — read [references/drawer-dialog.md](references/drawer-dialog.md).
- When building expand/collapse, progressive disclosure, confirmations for critical operations, or wiring up interactive cues (chevron placement, clickable affordances, metric info icons), read [references/interaction-patterns.md](references/interaction-patterns.md).

## Auditing an existing UI

When reviewing a UI for visual consistency, run each block below as a checklist pass — do not eyeball:

1. **The 9 principles** — test the UI against each; record every violation tagged with its principle number.
2. **Hard rules** — scan for accent stripes, off-scale font sizes, and text-opacity softening; record each occurrence with its location.
3. **Component states** — confirm every async, empty, and error surface has its state handled.
4. **Conventions** — verify text casing, dates, and numbers against the rules above.
5. **Interaction cues and container choices** — confirm cues match [references/interaction-patterns.md](references/interaction-patterns.md) and container choices match [references/drawer-dialog.md](references/drawer-dialog.md).

The audit is done only when all five passes are complete and every violation found is listed with a file/location and the rule it breaks.
