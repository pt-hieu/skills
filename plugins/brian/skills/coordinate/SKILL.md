---
name: coordinate
description: "Coordinate opus subagents through several work items in parallel worktrees — unblock them, settle conflicts between them, and deliver the result: stacked PRs unless the brief names another."
disable-model-invocation: true
argument-hint: "[work items] [result, when not stacked PRs]"
---

You are the coordinator: the subagents write and verify every line of code, and you hold the one thing none of them can see — how their work items bear on each other. Keep your context for that picture. A coordinator who opens an editor to fix an agent's code stops watching the other agents.

## Step 1: Read the brief

The brief names the work items (issues, tickets, tasks). The rest is fixed unless the brief says otherwise:

- **Result** — one PR per work item, stacked. A brief that names a different result replaces this.
- **Verification skill** — `agent-browser`.
- **Implementation skill** — the first of these that fits the repo:
  1. `mattpocock-skills:implement`, when the repo is set up for Matt Pocock's skills: it has a `CONTEXT.md`, an issue tracker the work items live in, and the conventions those skills read.
  2. `brian:autopilot`, for every other repo. Autopilot's own run ends by opening a PR; tell the agent to stop once the work is committed, because the PRs of a stack are opened in Step 5 against bases only the coordinator knows.

State which implementation skill you picked and the evidence for it before anything is spawned.

## Step 2: Map the work

Read every work item in full, then read enough of the code to say, per item, which files and modules it will touch. From that, write the map to `{scratchpad}/coordinate-{slug}.md`:

- **Territory** — the files and modules each item owns.
- **Overlaps** — every file, type, schema, or interface two items both touch, with your decision on it: which item makes the shared change, and what the other item may assume about it.
- **Order** — which items depend on another's output, and, when the result is a stack, the stack order. An item sits above every item it builds on.

The map is done when every pair of items has either a recorded overlap decision or a sentence saying why they cannot collide. The map is where conflicts are cheapest to resolve: an overlap found here costs a sentence in two prompts, and the same overlap found at rebase costs a re-implementation.

## Step 3: Dispatch

Launch one `Agent` per work item with `model: "opus"` and `isolation: "worktree"`. Send every item that does not wait on another in a single message so they run concurrently; an item that builds on another's output starts from that item's branch once it has verified.

Write each prompt as prose covering:

- The work item, in full, and its branch name.
- The implementation skill to invoke, and the verification skill to invoke when the implementation is done. The agent is finished when verification passes and the work is committed on its branch — it does not push or open a PR.
- Its territory, its neighbours' territories, and every overlap decision that touches it, with the reason behind each.
- What to do at a boundary: when the work needs a change outside its territory, or a decision the work item does not settle, the agent stops and reports the question back with what it found. A guess across a boundary is the conflict you are here to prevent.

## Step 4: Unblock and reconcile

When an agent reports back blocked, answer it with `SendMessage` to that same agent, so it keeps its worktree and everything it has read. Find the answer yourself — read the code, the work item, the other agents' reports — and hand it over with the reason.

Every answer that changes a shared seam goes to each agent the seam touches, in the same turn, and into the map. An agent that learns about a neighbour's change from a rebase conflict was failed by its coordinator.

Each time an agent reports, check its report against the map before moving on: a file outside its territory in the diff, or an assumption about a neighbour that is no longer true, is a conflict to settle now.

Bring Brian a question only when it is his alone to answer — product intent the work items do not state, access you do not have. Ask it, and keep every agent that does not depend on the answer moving.

When verification fails, the fix goes back to the agent that owns the item. No verified item, no result: an item whose verification did not pass is not assembled in Step 5.

## Step 5: Assemble the result

Build the result from Step 1. A stack is built with the `gh stack` extension, from your own checkout: first release the agents' worktrees with `git worktree remove`, because a branch still checked out in a worktree cannot be rebased here.

- `gh stack init {bottom} … {top}` adopts the verified branches in the map's order, bottom first, on top of the default branch.
- `gh stack rebase` cascades each branch onto the one below it. A conflict goes to the agent that owns the upper branch, with the path to this checkout, to resolve with `brian:resolve-merge-conflicts`; you then run `gh stack rebase --continue`. A branch whose code changed during the rebase is verified again by its agent.
- `gh stack submit --auto --open` pushes every branch, opens one PR per item based on the branch below it, and links the stack on GitHub. Its generated titles are placeholders: give each PR the title and body Brian's PR guidelines ask for with `gh pr edit`, each body linking its work item, and keep the stack section `gh stack` wrote into the body — read it back with `gh pr view --json body` before you replace anything.

The result is done when every work item has its PR, each PR's diff contains only its own item, and each item has a passing verification run made after its last code change.

## Step 6: Report

Give Brian the result in order — for a stack, bottom first, with links — then the decisions you made on the agents' behalf, each in one sentence with its reason, and anything that did not verify or did not ship, with why.

## It's working if

- The map exists in the scratchpad before the first agent is spawned, and it grew as decisions were made.
- Independent agents went out in one message, each on opus in its own worktree.
- Blocked agents were continued with `SendMessage`, never respawned.
- You edited no source file.
- A stack was assembled with `gh stack`, and every PR in it shows one item's diff against the branch below it.
