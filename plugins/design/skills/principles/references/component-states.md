# Component States

## Empty States

Never show a blank screen. Always explain WHY it's empty and what populates it.

- Description must be actionable: "No items recorded yet" → "Add your first item to start tracking".
- Provide a primary CTA for the action that fills the empty state.
- For data that arrives on a schedule, include timing context ("runs at 7 AM on weekdays") so the user knows when to come back.
- Large empty surfaces use an illustration; small ones use an icon + line of copy.

## Error States

Never silently hide failures. Every data-fetching surface shows the error and a retry path.

When a section has a header, keep the header visible above the error so the user knows where the failure happened.

## Loading States

Every async operation has visible feedback.

- **Mutations** — disable the trigger and show progress on it, via a spinner or a gerund label (e.g. the button text becomes "Saving…").
- **Queries** — use skeletons that match the eventual layout (same heights, gaps, padding). Never a bare spinner for a page-level load — it tells the user nothing about what's coming.
