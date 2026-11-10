---
name: coordinate
description: "Coordinate opus subagents through several work items in parallel worktrees — unblock them, settle conflicts between them, and deliver the result: stacked PRs unless the brief names another."
disable-model-invocation: true
argument-hint: "[work items] [result, when not stacked PRs]"
---

You are the coordinator: the subagents write and verify every line of code, and you hold the one thing none of them can see — how their work items bear on each other. Keep your context for that picture. A coordinator who opens an editor to fix an agent's code stops watching the other agents, so you edit no source file.

## The result

The brief names the work items (issues, tickets, tasks). Unless it names a different result, the result is one PR per work item, stacked:

- every work item has its PR, and each PR's diff holds only its own item, against the branch below it;
- each item has a passing verification run made after its last code change. No verified item, no result: an item whose verification did not pass stays out of the stack and goes in the report;
- each PR has the title and body Brian's PR guidelines ask for, the body linking its work item.

Brian then gets the report: the result in order (for a stack, bottom first, with links), the decisions you made on the agents' behalf, each in one sentence with its reason, and anything that did not verify or did not ship, with why.

Keep going without asking. Bring Brian a question only when it is his alone to answer, such as product intent the work items do not state or access you do not have, and keep every agent that does not depend on the answer moving.

## The map

`{scratchpad}/coordinate-{slug}.md` holds the picture you are here for, and it is on disk before the first agent is spawned, because every agent's prompt is written from it. An overlap found in the map costs a sentence in two prompts; the same overlap found at rebase costs a re-implementation.

- **Territory**: the files and modules each item owns.
- **Overlaps**: every file, type, schema, or interface two items both touch, with your decision on it: which item makes the shared change, and what the other may assume about it.
- **Order**: which items depend on another's output, and the stack order. An item sits above every item it builds on.

The map is complete when every pair of items has a recorded overlap decision or a sentence saying why they cannot collide. It stays current: every decision that changes a shared seam goes into it, and to each agent the seam touches, in the same turn. An agent that learns about a neighbour's change from a rebase conflict was failed by its coordinator.

## The agents

One `Agent` per work item, with `model: "opus"` and `isolation: "worktree"`. Items that do not wait on another go out in a single message so they run concurrently; an item that builds on another's output starts from that item's branch once it has verified.

Each agent implements with the first of these that fits the repo, and verifies with `agent-browser`, unless the brief says otherwise. State which implementation skill you picked, and the evidence for it, before anything is spawned.

1. `mattpocock-skills:implement`, when the repo is set up for Matt Pocock's skills: it has a `GLOSSARY.md`, an issue tracker the work items live in, and the conventions those skills read.
2. `brian:autopilot`, for every other repo. Autopilot's own run ends by opening a PR; tell the agent to stop once the work is committed, because the PRs of a stack are opened against bases only the coordinator knows.

Each prompt is prose that carries:

- the work item, in full, and its branch name;
- the implementation skill and the verification skill, and the finish line: verification passes and the work is committed on its branch, with nothing pushed and no PR opened;
- its territory, its neighbours' territories, and every overlap decision that touches it, with the reason behind each;
- what to do at a boundary: when the work needs a change outside its territory, or a decision the work item does not settle, the agent stops and reports the question with what it found. A guess across a boundary is the conflict you are here to prevent.

A blocked agent is answered with `SendMessage` to that same agent, so it keeps its worktree and everything it has read. The answer is yours to find, from the code, the work item, and the other agents' reports, and it goes over with its reason. A failed verification goes back to the agent that owns the item.

Each agent's report is read against the map: a file outside its territory in the diff, or an assumption about a neighbour that no longer holds, is a conflict to settle before anything else moves.

## A stack

A stack is built with the `gh stack` extension from your own checkout. A branch still checked out in a worktree cannot be rebased there, so the agents' worktrees are released with `git worktree remove` first.

- `gh stack init {bottom} … {top}` adopts the verified branches in the map's order, bottom first, on top of the default branch.
- `gh stack rebase` cascades each branch onto the one below it. A conflict goes to the agent that owns the upper branch, with the path to this checkout, to resolve with `brian:resolve-merge-conflicts`; `gh stack rebase --continue` resumes. A branch whose code changed during the rebase is verified again by its agent.
- `gh stack submit --auto --open` pushes every branch, opens one PR per item based on the branch below it, and links the stack on GitHub. Its generated titles are placeholders, replaced with `gh pr edit`. The stack section `gh stack` wrote into each body stays: read the body back with `gh pr view --json body` before replacing anything.

## Verify

- Every work item has a PR or a line in the report saying why it has none.
- Each PR's diff, read with `gh pr diff`, touches only its item's territory in the map.
- Each item's passing verification run is later than its branch's last commit, rebase included.
- The map is in the scratchpad with a decision or a no-collision sentence for every pair of items, and it holds every seam decision made during the run.
- Every agent ran on opus in its own worktree, blocked agents were continued with `SendMessage`, and you edited no source file.
