---
name: break-ui
description: Use when stress-testing a component or screen with worst-case data, or hunting the edge cases that break its layout before it ships.
argument-hint: "<component or screen>"
---

# Break UI

Puts a piece of UI in front of the worst case its real users will produce, and reports what breaks. Demo data gets picked, usually without anyone noticing, to make a design look good: names that fit on one line, counts under a thousand, every optional field filled in. This skill swaps that data for the worst case, one field at a time, and leaves the component's code alone until the user picks the fixes.

Distilled from Emil Kowalski's [`break-ui`](https://github.com/emilkowalski/skills/tree/main/skills/break-ui) skill (MIT License).

## The result

The run ends on a report, and the user can flip a toggle to see every break it names. The component's own code is unchanged.

- **The report** is written for the person who decides which fixes land, worst break first. A break that hides content, pushes an action out of reach, or shows wrong data outranks one that looks wrong, which outranks a value one realistic step from breaking (no limit, no fallback). Each break names the value that caused it, what the user sees, its cause in the code, and a fix with its `file:line`. Breaks with more than one right answer, such as whether a name wraps or truncates, or whether a missing role leaves a gap, are listed as decisions for the user with your recommendation. It closes with the worst cases the component already handles, and where the toggle lives.
- **The worst-case fixture** sits next to the existing demo data, in the same shape, so it enters through the same boundary the demo data does. Editing markup or CSS to provoke a break tests the edit and leaves the component untested. Fixtures for the states one dataset cannot hold sit beside it: empty, a single item, and the largest list the product allows.
- **The toggle** switches fixtures while the component is on screen, swapping them where the data enters. Inside a `design:prototype` flow, the worst case is a scenario in its switcher. Elsewhere it is a dev-only switch read from a `?data=` URL parameter, so a reload keeps the state, and it stays out of production builds.

Then the run stops and waits: the user flips the toggle, looks, and names the fixes. The named fixes are applied with the project's conventions and tokens, and the worst-case fixture stays for the next person who changes the component.

## The worst case

Every value in the fixture is one a real user could produce, or the longest the backend accepts. A 300-character run of `a` gets dismissed as "that never happens", and the review stops there. So each rendered value has a known source and limit: the limit in the validation schema, database column, API type, or input's `maxLength`, or "unbounded" when none exists. That includes the values that are easy to miss: counts in headers, relative times, badge and status text, button labels fed by data, avatar images, and the length of each list.

Long names are the break everyone expects; the ones that ship are these:

- unbreakable strings: emails, URLs, file names, IDs
- one- and two-character names, and names with diacritics or non-Latin script
- every optional field missing, avatar images included
- counts of 0, 1, and the realistic maximum
- every value of an enum on screen at once
- labels in the longest language the product ships

The failures are spread across the first rows on screen, the long email in one row and the one-letter name in the next, the way real data mixes them.

## Verify

- Every value the component renders has a source and a limit or "unbounded", and the fixture covers each kind of worst case above that applies to it.
- Every fixture is reachable from the toggle with the component in view.
- Every fixture was looked at with the `agent-browser` skill, in screenshots at the component's real container width, at the narrowest width the product supports, and at 200% browser zoom, plus RTL and dark mode when the product supports them. Long text is judged against the long-text convention in `design:principles`, and the rest against what a user needs: to read the value, recognise the item, and reach every action.
- The report leads with a break that hides content or blocks an action, when one exists.
- Before the user's pick, the diff holds fixtures and the toggle and nothing else.
- After the fixes, every fixture renders correctly, demo data included, since a fix for the worst case can break the layout it was designed for.
