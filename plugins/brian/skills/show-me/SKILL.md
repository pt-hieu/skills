---
name: show-me
description: "Use when Brian asks to see the current topic rather than read about it"
argument-hint: "[what to show]"
---

Explain the current topic visually. Skip the preamble, keep prose brief, and pick the smallest view that makes the key point clear. Place each visual next to the short sentence it supports, and include only the calls, files, props, states, and boundaries the current question needs.

## Pick the view

| The point is… | Show it as… |
| --- | --- |
| Logic or an algorithm | Pseudocode in a `text` block |
| Runtime control flow | An indented call tree |
| UI structure, with the state hooks and module boundaries that matter | A component tree, file paths in parentheses |
| File responsibility or a broad refactor | A shallow file tree with one comment per directory |
| Interaction, control flow, or data flow between parts | Mermaid (`sequenceDiagram`, `flowchart`, `stateDiagram`) |
| What changes, when the surrounding shape already exists | A `diff` block, shaped like the topic (tree, call tree, pseudocode) |
| Mostly new code, or a copyable target shape | The whole block, not a diff |
| A visual layout, a state comparison, or a concept too dense for Mermaid | One focused HTML file |

Use one view, or a few. Using all of them means the point was not chosen.

## Examples

Call tree:

```text
submitForm
  createSession
    persistPrompt
    launchAgent
  navigateToSession
```

Component tree:

```tsx
<SessionPage> (apps/example/src/routes/session.tsx)
  useSessionEvents()
  <SessionToolbar>
    <RunSkillButton> (packages/ui)
```

Diff shaped like the topic — here a call tree, so the reader sees where the new step lands and what moved under it:

```diff
 submitForm
   createSession
     persistPrompt
+    expandSkillMention
     launchAgent
-  navigateToSession
+  navigateToSession
+    subscribeToEvents
```

The same diff shape works for a file tree, a component tree, or pseudocode. Show the whole block instead when most of it is new or when the omitted context would hide ownership or order.

## HTML artifacts

Write one file — a diagram, an infographic, or a short slide deck, whichever fits the point. Match the product's colors, type, spacing, and components. Use real labels and real data. Support desktop and mobile. Then open it:

```
Bash(open path/to/show-me-{description}.html)
```

---

Distilled from [humanlayer/skills · show-me](https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md).
