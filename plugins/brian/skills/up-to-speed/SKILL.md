---
name: up-to-speed
description: "Context briefing that explains how existing work fits together so you can start contributing."
argument-hint: "[PR# | branch | code-area | topic]"
disable-model-invocation: true
---

# Up To Speed

Brings Brian up to speed on existing work: a PR, a branch, a code area, a ticket, or a topic. The goal is understanding, not status. The skill is done when Brian can explain the flow end to end, knows which file to open first, and says he is set. The briefing starts that. A Q&A loop finishes it.

The bar every sentence meets: it carries a citation Brian can open (a commit short-hash, `PR#<n>`, a ticket key, a `file:line`, or a Slack permalink). An uncited claim is dropped, not softened. A briefing that reads as authoritative but is wrong costs more than one that says "I don't know". The output is chat only, and nothing is written to disk.

## Scope

Work out what the argument names. When it names nothing, or it could be two things (a branch and a folder with the same name), ask once in plain text and list the readings. Otherwise proceed. A ticket key seeds discovery: fetch it, then follow its linked branch or PR to the code. Collect the concrete handles you find, such as the branch, PR number, paths, and ticket keys in recent commit subjects, so each gatherer starts from them rather than searching cold.

For a PR, use the repo from `git remote get-url origin`. Only when no remote resolves, assume `drovacorp/interface` on `master`, and name the repo you used in the Sources footer so a wrong guess is visible.

Read the depth Brian wants from his wording. "Quick", "gist", and "tl;dr" mean a short briefing: the what/why line plus a compact How it works. "Deep dive" and "everything" mean the full briefing. With no signal, go as far as Key files & architecture. Depth sets how far gatherers dig and how long the briefing runs. It never changes the citation bar or the source set.

## Gather

Send one background gatherer per source, all four in a single message:

| source | `subagent_type` | model | reaches |
|---|---|---|---|
| git+code | `Explore` | `sonnet` | `git log/show/diff/blame`, Grep, Glob, Read |
| bitbucket | `general-purpose` | `sonnet` | `mcp__bitbucket__*`: PR, comments, diffstat, code search |
| jira/confluence | `general-purpose` | `sonnet` | `mcp__claude_ai_Atlassian_Rovo__*`: issues, JQL, pages, CQL |
| slack | `general-purpose` | `sonnet` | `mcp__claude_ai_Slack__*`: search, read thread |

The three MCP sources use `general-purpose` because MCP reach from `Explore` is not guaranteed. A gatherer that cannot reach its tools reports a failure that looks like silence. Leave every source to its gatherer and do not gather inline, so each source's findings stay separately cited.

Brief each gatherer in prose: the scope and its handles, the depth, what its source should contribute, and the citation bar. Ask it to lead with the most start-relevant fact. Ask it to say plainly whether it found nothing (it looked, and here is what it looked for) or whether a tool failed (which tool, and how). An empty source is a real absence of signal. A failed one is unknown coverage. When the source disagrees with itself, it reports both sides.

What each source contributes:

- **git+code**: how the work is structured, meaning the entry points, the main flow, and where to start reading. Ticket keys from commit subjects so they can be cross-linked.
- **jira/confluence**: the why, meaning tickets, design docs, acceptance criteria, and the latest comment that explains intent.
- **bitbucket**: what the change does, the reasoning in review, and whether it has landed or is in flight, which tells Brian what is stable to build on.
- **slack**: decisions, blockers, and reversals, plus contradictions with PR or ticket state. Exclude DMs where Brian is the only participant (e.g. channel `D07EGHRBLSJ`). Those are Claude draft dumps, and a real permalink would launder them past the citation check.

## Brief

Before rendering, check every bullet for its citation, because compression during synthesis is where a citation falls off while the claim survives. When sources disagree, for example a design doc says X while the code does Y, show both sides with citations inside How it works and say which one is true now.

Render in this order, leaving out sections the depth does not reach:

1. One line on what the work is and the problem it solves, citing the driving ticket or PR.
2. **How it works**: the end-to-end mental model, and how the pieces fit.
3. **Key files & architecture**: where the work lives, its entry points, and where to start reading.
4. **Where to jump in**: what is solid to build on and where the active edge is.
5. **Gotchas / open questions**: only what matters before touching the code.
6. A **Sources** footer: which sources gave signal, the Bitbucket repo used, which found nothing, and which could not be reached ("coverage incomplete"). The footer always appears. Leave out empty clauses.

## Q&A

Invite questions, and keep answering until Brian signals he is set. Answer from what the gatherers already returned. When a question hits a gap, send only the relevant gatherer again, under the same rules. Quote the real code path rather than describing it. The citation bar holds for every answer. When you lack the source for something, say so and offer to dig. Close by pointing at the `file:line` where he would start.
