# Drawer vs Dialog

## Drawer — Detail Without Losing Context

The drawer is a parallel reading pane, not a navigation event. The parent list stays visible and interactive; clicking a different item swaps drawer content with no close/reopen cycle. Closing preserves scroll position. Mental model: "I'm still on the same page, looking at one thing more closely."

**When to use:** The page has a scannable list of entities and the user needs to drill into one while keeping others visible for comparison. The list is the anchor. The drawer is the lens.

**When NOT to use:**
- Content has no parent list (standalone summaries, page-level banners).
- Items the system told the user to ignore — a drawer gives too much ceremony to low-priority content.
- Detail is so heavy it needs its own page (full reports, multi-section analysis with charts).

**Content budget:** Scannable in one glance on open — no scrolling required. Default shows only the verdict, key signals, and the action. Deeper analysis lives behind a toggle as a Tier 3 expansion. **Rule: if the default drawer content requires scrolling, you've put too much in it.** Compress, tier it, or reconsider the container.

**Sizing:**
- Narrow — simple stat lookups.
- Medium — structured summaries with scores and short prose.
- Wide — metrics tables or side-by-side comparisons.
- **Never wider than 50% of viewport** — the parent list must remain usable.

**Transitions:** Opening compresses main content — never overlays it. Parent list must remain visible. On mobile, use a bottom sheet with a clear "back to list" gesture.

---

## Dialog — Focused Action, Then Return

The dialog is a decision checkpoint. It appears when the user commits to something consequential and demands a response (confirm, cancel, modify), then disappears. Mental model: "I've been pulled aside to make a call, then I'm back."

**When to use:**
- Action is irreversible or consequential.
- Action needs user-supplied input that doesn't belong inline (price, quantity, notes).
- Confirming something the system will do on the user's behalf.

**When NOT to use:**
- Reading or inspecting data — that's a drawer.
- Low-stakes toggles (filters, view options) — those are inline.
- Content that benefits from comparison with the parent page — dialog blocks the page, drawer doesn't.
- User needs to reference the list while filling out the form — use a drawer with a form inside.

**Content budget:** Completable in one action. **Rule: if the dialog requires scrolling, tabs, or multi-step navigation, it's too heavy.** Ideal: context line (what you're acting on) + input fields (what you're deciding) + two buttons (confirm / cancel). Max 3–5 fields. No embedded tables or lists. If the user needs to read extensively before acting → drawer with a CTA. If more than one screen of fields → a dedicated form page.

**Sizing:**
- Small — confirmations with no input.
- Medium — actions with a few fields.
- **Never full-width** — the dimmed background reminds the user this is a temporary interruption.

---

## The Boundary

| Interaction starts with… | Container |
|---|---|
| "Let me look at this" | Drawer |
| "Let me do something" | Dialog |
| "Let me look, then maybe act" | Drawer → CTA → Dialog |

Core loop: **list → drawer (inspect) → dialog (act) → back to list**.

The drawer is for reading. The dialog is for deciding. A drawer keeps you in context while you inspect. A dialog interrupts context because the action deserves full attention.
