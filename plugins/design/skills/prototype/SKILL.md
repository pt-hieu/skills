---
name: prototype
description: "Use when prototyping a screen or flow in an app that consumes the flyingsalmon design system"
argument-hint: "<what to prototype>"
---

# Prototype

Builds a **throwaway** clickable flow inside the host app, out of flyingsalmon registry components, on its own worktree branch. Throwaway means the code answers one question and then stays on its branch as a reference: nothing in it is promoted in place, so it carries no tests, no real data source, and no abstractions. What it must carry is the design system — a prototype made of look-alike components answers nothing about the real product.

## The result

The user has a localhost URL where the flow runs end to end by clicking, in every scenario and every variant, with the dev server still running. Behind the URL:

- **A worktree** named `prototype/<name>`, entered with `EnterWorktree`, where `<name>` is a short kebab-case name for the flow. It reuses the host app's dependencies. It starts from the remote default branch unless the `worktree.baseRef` setting says otherwise, so it sees only pushed work. Every file the run writes is inside it.
- **The flow**, embedded in the host application or wherever the arguments say. Every screen is reachable by clicking from the flow's entry, and state is in memory.
- **A commit** on the prototype branch, never pushed. Its message is the record a later reader of the branch starts from, so its body states the question the prototype answers, the scenarios, the variants and the dimension each differs on, the flyingsalmon components added to the host, and the gaps filled with stand-ins.

The hand-over is the URL. With variants, it adds one line per variant on when it is the right choice and what it costs, names any variant cut for looking the same as another, and leaves the pick to the user. Each round of feedback ends in the same state: verified and committed. The dev server and the worktree stay up until the user asks otherwise, and what happens to the prototype afterwards is the user's decision.

## The brief

The prototype answers one question, and three things are agreed with the user before anything is built: the question, the steps of the flow from entry to end, and the scenario list. When the argument already states all three, proceed without waiting.

When the question compares alternatives (side panel or page, grouped by customer or by issue, dense or roomy), the brief adds variants: two or three directions, each named with the dimension it differs on, such as layout, density, hierarchy, container choice, or grouping. flyingsalmon fixes the look, so two directions that differ in color, type, or copy are one direction.

## What it is built from

`references/flyingsalmon.md`, `references/craft.md`, and the `design:principles` skill bind the prototype; read all three before building. On conflict the order is flyingsalmon, then `design:principles`, then `craft.md`. The component list is at `https://flyingsalmon.superbrian.dev/r/registry.json`.

- **Components** come from the registry, added with `shadcn add @flyingsalmon/<component>` without asking. When the flow needs something the registry lacks, or lists with no files, the stand-in is composed from registry components and theme tokens and marked as a stand-in in the code. A stock shadcn component, or a hand-rolled copy of something the registry has, fails the prototype.
- **Scenarios** are named fake-data fixtures: a data state (empty, error) or a starting condition (new user, paid plan). Every prototype has at least populated, empty, loading, and error, plus the ones the flow's question needs. Each scenario is one fixture object, so adding one is a single edit.
- **Fixtures** hold realistic content from the subject's domain: plausible names, amounts, dates, and one long value per list so truncation and wrapping show. `Item 1` and lorem ipsum fail the prototype. When the question is how the layout holds up under real data, the `design:break-ui` skill adds its worst-case fixture as one more scenario.
- **Variants** are one component per direction behind the same flow and fixtures, so any variant runs in any scenario.
- **The switcher** is a floating bottom bar listing the scenarios, plus a variant group when there are variants. It is test-harness chrome that reviewers look past: built from registry components like the rest, kept plain and visibly apart from the flow, and placed at the top edge whenever the flow uses the bottom of the screen (a bottom sheet, a sticky action row). The selection lives in `sessionStorage` and defaults to populated and the first variant, so a full reload keeps the state under review.

## When to stop and ask

- The brief is not agreed and the argument does not settle it.
- A worktree or branch named `prototype/<name>` already exists.
- The host cannot run flyingsalmon. No setup, no prototype: the host needs React 19 and Tailwind CSS v4 in its dependencies, `"registries": { "@flyingsalmon": "https://flyingsalmon.superbrian.dev/r/{name}.json" }` in `components.json`, and the flyingsalmon `theme` item installed in its stylesheet. When any of the three is missing, the run's whole output is a report of each discrepancy.

## Verify

Check in the browser, with the `agent-browser` skill against the host's dev command running in the worktree on a free port. Every failure is fixed before anything reaches the user.

- Every scenario, selected from the switcher, renders its content with no error overlay and no uncaught console error, in every variant.
- The flow clicks through from its entry to its end.
- No two variants look the same.
- Every UI import comes from the host's installed flyingsalmon components, and each stand-in is marked.
- The switcher lists at least populated, empty, loading, and error, plus the variants when the brief has them.
- The working tree is clean, the branch is unpushed, and its last commit's body names the question, scenarios, variants, added components, and gaps.
