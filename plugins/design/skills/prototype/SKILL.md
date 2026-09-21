---
name: prototype
description: "Use when prototyping a screen or flow in an app that consumes the flyingsalmon design system"
argument-hint: "<what to prototype>"
---

# Prototype

Builds a **throwaway** clickable flow inside the host app, out of flyingsalmon registry components, on its own worktree branch. Throwaway means the code answers one question and then stays on its branch as a reference: nothing in it is promoted in place, so it carries no tests, no real data source, and no abstractions. What it must carry is the design system — a prototype made of look-alike components answers nothing about the real product.

## Steps

### 1. Brief

State three things and wait for the go-ahead: the question the prototype answers, the steps of the flow from entry to end, and the scenario list (step 5 sets the floor). Pick `<name>`, a short kebab-case name for the flow. When the argument already states all three, proceed without waiting.

Done when the question, the flow steps, and the scenarios are agreed.

### 2. Worktree

Create the worktree with `EnterWorktree`, named `prototype/<name>`. When a worktree or branch of that name already exists, stop and ask. Reuse dependencies of the host app.

The worktree starts from the remote default branch unless the `worktree.baseRef` setting says otherwise, so everything after this step sees only pushed work.

### 3. Preflight

Inside the worktree, confirm the host can run flyingsalmon:

- React 19 and Tailwind CSS v4 in the host's dependencies.
- `components.json` carries `"registries": { "@flyingsalmon": "https://flyingsalmon.superbrian.dev/r/{name}.json" }`.
- The flyingsalmon `theme` item is installed in the host's stylesheet.

No setup, no prototype: when any check fails, stop and report each discrepancy.

Done when all three checks pass, or the discrepancy report is delivered and the run has stopped.

### 4. Read the rules

Read `references/flyingsalmon.md` and `references/craft.md`, and load the `design:principles` skill; its nine principles and component states bind the prototype. On conflict the order is flyingsalmon, then `design:principles`, then `craft.md`.

Fetch `https://flyingsalmon.superbrian.dev/r/registry.json` for the component list.

Done when the component list is in hand and each step of the flow is mapped to the registry components that will render it.

### 5. Build

Build the flow embedded into the current host application or whatever matches the arguments.

- **Components** — add what the host lacks with `shadcn add @flyingsalmon/<component>`, without asking. When the flow needs something the registry lacks, or lists with no files, compose a stand-in from registry components and theme tokens and mark it as a stand-in in the code. A stock shadcn component or a hand-rolled copy of something the registry has fails this step.
- **Scenarios** — a scenario is one named fake-data fixture: a data state (empty, error) or a starting condition (new user, paid plan). Every prototype has at least populated, empty, loading, and error; add the ones the flow's question needs. Each scenario is one fixture object, so adding one is a single edit.
- **Fixtures** — realistic content from the subject's domain: plausible names, amounts, dates, and one long value per list so truncation and wrapping show. `Item 1` and lorem ipsum fail this step.
- **Switcher** — a floating bottom bar listing the scenarios. The selected scenario lives in `sessionStorage` and defaults to populated, so a full reload keeps the scenario under review.

Every screen is reachable by clicking through the flow from its entry; state is in memory.

Done when the flow runs end to end by clicking, in every scenario.

### 6. Verify

Start the host's dev command in the worktree as a background process on a free port. With the `agent-browser` skill, open the prototype in dark mode and select each scenario from the switcher. A scenario passes when the page renders its content with no error overlay and no uncaught console error. Fix every failure before anything reaches the user.

Done when every scenario passes in dark mode.

### 7. Commit

Commit on the prototype branch and never push. The commit message is the record a later reader of the branch starts from, so its body states: the question the prototype answers, the scenarios, the flyingsalmon components added to the host, and the gaps filled with stand-ins.

Done when the working tree is clean.

### 8. Hand over

Reply with the localhost URL. Each round of feedback is a change followed by steps 6 and 7 again. Leave the dev server and the worktree running; leave the worktree only when the user asks. What happens to the prototype afterwards is the user's decision.

## It's working if

- The session moved into a `prototype/<name>` worktree before any file was written.
- A host that failed preflight got a discrepancy report and the run stopped.
- Every import of UI comes from the host's installed flyingsalmon components, and each stand-in is marked.
- The floating bar lists at least populated, empty, loading, and error.
- The branch ends in a commit whose body names the question, scenarios, added components, and gaps.
