---
name: break-ui
description: Use when stress-testing a component or screen with worst-case data, or hunting the edge cases that break its layout before it ships.
argument-hint: "<component or screen>"
---

# Break UI

Puts a piece of UI in front of the worst case its real users will produce, and reports what breaks. Demo data gets picked, usually without anyone noticing, to make a design look good: names that fit on one line, counts under a thousand, every optional field filled in. This skill swaps that data for the worst case, one field at a time, and leaves the component's code alone until the user picks the fixes.

Distilled from Emil Kowalski's [`break-ui`](https://github.com/emilkowalski/skills/tree/main/skills/break-ui) skill (MIT License).

## Steps

### 1. Map the surface

List every value the component renders, with where it comes from and how long it can get: the limit in the validation schema, database column, API type, or input's `maxLength`, or "unbounded" when none exists. Include the values that are easy to miss: counts in headers, relative times, badge and status text, button labels fed by data, avatar images, and the length of each list.

Done when every rendered value has a source and a limit or "unbounded".

### 2. Build the worst case

Write one worst-case fixture next to the existing demo data, in the same shape, so it enters through the same boundary the demo data does. Editing markup or CSS to provoke a break tests the edit and leaves the component untested.

Every value is one a real user could produce, or the longest the backend accepts. A 300-character run of `a` gets dismissed as "that never happens", and the review stops there. Long names are the break everyone expects; the ones that ship are these:

- unbreakable strings: emails, URLs, file names, IDs
- one- and two-character names, and names with diacritics or non-Latin script
- every optional field missing, avatar images included
- counts of 0, 1, and the realistic maximum
- every value of an enum on screen at once
- labels in the longest language the product ships

Spread the failures across the first rows on screen, the long email in one row and the one-letter name in the next, the way real data mixes them. Add fixtures for the states one dataset cannot hold: empty, a single item, and the largest list the product allows.

Done when the fixture covers each kind above that applies to the component, and every value is plausible or schema-backed.

### 3. Wire the toggle

Make the fixtures switchable while the component is on screen, swapping them where the data enters. Inside a `design:prototype` flow, the worst case is a scenario in its switcher. Elsewhere, add a dev-only switch read from a `?data=` URL parameter, so a reload keeps the state, and keep it out of production builds.

Done when every fixture is reachable from the toggle with the component in view.

### 4. Break it

Look at every fixture with the `agent-browser` skill, taking screenshots at the component's real container width, at the narrowest width the product supports, and at 200% browser zoom. Add RTL and dark mode when the product supports them. Judge long text against the long-text convention in `design:principles`, and the rest against what a user needs: to read the value, recognise the item, and reach every action.

Done when every fixture has been seen in every one of those conditions, and each break has the value that caused it, what the user sees, its cause in the code, and a fix with its `file:line`.

### 5. Report and stop

Write the report for the person who decides which fixes land, worst break first. A break that hides content, pushes an action out of reach, or shows wrong data outranks one that looks wrong, which outranks a value one realistic step from breaking (no limit, no fallback). Some breaks have more than one right answer, such as whether a name wraps or truncates, or whether a missing role leaves a gap; list those as decisions for the user with your recommendation. Close with the worst cases the component already handles, and where the toggle lives.

Then stop. The user flips the toggle, looks, and names the fixes.

### 6. Fix on request

Apply the fixes the user named, using the project's conventions and tokens. Flip through every fixture again, demo data included, since a fix for the worst case can break the layout it was designed for. Keep the worst-case fixture for the next person who changes the component.

Done when every named fix is applied and every fixture renders correctly.

## It's working if

- The fixture is a data file next to the demo data, and the component's code is untouched before step 6.
- The report leads with a break that hides content or blocks an action, when one exists.
- The run stops after the report and waits for the user's pick.
