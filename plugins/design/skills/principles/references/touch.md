# Touch

Distilled from Emil Kowalski's [`mobile-native`](https://github.com/emilkowalski/skills/tree/main/skills/mobile-native) and [`apple-design`](https://github.com/emilkowalski/skills/tree/main/skills/apple-design) skills (MIT License).

These rules apply to a UI that ships to phones. Each one fixes a defect a desktop-built page shows the first time someone uses it with a thumb.

- **Press is its own state.** A tap applies `:hover` and leaves it applied until the next tap elsewhere, so a hover style sticks on touch screens. Give every control press feedback on `:active`, and gate hover-only styles behind `@media (hover: hover) and (pointer: fine)`. Tailwind v4's `hover:` variant applies that gate; hand-written CSS adds it.
- **Inputs render at 16px or larger.** iOS zooms the page when focus lands in a smaller field. Use the type-scale step at or above 16px for inputs, and leave pinch-zoom enabled: `maximum-scale=1` and `user-scalable=no` take zoom away from people who need it.
- **Pinned UI follows the visible viewport.** `100vh` is taller than the visible area while the browser's toolbars show, so full-height layouts use `100dvh`. Anything fixed to the bottom edge (bars, sheets, a prototype's scenario switcher) pads by `env(safe-area-inset-bottom)` and the page sets `viewport-fit=cover`, so the home indicator leaves the controls clear.
- **Inner scroll stays inner.** A drawer, sheet, or scrolling panel sets `overscroll-behavior: contain`, so reaching its end leaves the page behind it in place and pull-to-refresh asleep.
- **Targets fit a finger.** Interactive targets are at least 44px in both directions, with the hit area extended by padding when the visible control is smaller. Two adjacent targets keep a gap between their hit areas.
- **Taps respond on press.** Feedback appears on pointer-down and the action commits on release, so the user sees the interface heard them before their finger lifts. `touch-action: manipulation` on controls removes the double-tap-to-zoom delay.
- **The drawer becomes a bottom sheet.** `drawer-dialog.md` covers when to use one; on a phone it slides up from the bottom edge, dismisses on a downward flick even when the drag is short, and keeps a visible close control for people who never try the gesture.
