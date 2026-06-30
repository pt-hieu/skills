---
name: principles
description: Use when building or reviewing any UI — applying layout/hierarchy and visual-consistency rules, choosing between drawer/dialog/inline patterns, or defining component states.
---

# UI Design Principles

## Reference index

All rules live in the reference files below. Read the ones relevant to your task.

| File | Contents |
|------|----------|
| [design-principles.md](references/design-principles.md) | 9 non-negotiable principles: hierarchy, scanning, escalation, dedup, stale data, drill-down CTAs |
| [component-states.md](references/component-states.md) | Empty, error, loading states (skeletons vs spinners) |
| [interaction-patterns.md](references/interaction-patterns.md) | Icons, clickable cues, critical-op confirmations, progressive disclosure, chevron placement, metric info |
| [banned-patterns.md](references/banned-patterns.md) | Accent bars, arbitrary font sizes, text opacity modifiers |
| [formatting.md](references/formatting.md) | Date format, text casing, enum display, formatter conventions |
| [drawer-dialog.md](references/drawer-dialog.md) | Drawer vs dialog: when to use each, sizing, content budgets, chaining pattern |

## Auditing an existing UI

When reviewing a UI for visual consistency, run each reference file as a checklist pass — do not eyeball:

1. **design-principles.md** — test the UI against each of the 9 principles; record every violation tagged with its principle number.
2. **banned-patterns.md** — scan for each banned pattern; record each occurrence with its location.
3. **component-states.md** — confirm every async, empty, and error surface has its state handled.
4. **formatting.md** — verify dates, casing, and enum display against the conventions.
5. **interaction-patterns.md** and **drawer-dialog.md** — confirm interaction cues and container choices match the rules.

The audit is done only when all five passes are complete and every violation found is listed with a file/location and the rule it breaks.
