---
name: up-to-speed
description: "Context briefing that explains how existing work fits together so you can start contributing."
argument-hint: "[PR# | branch | code-area | topic]"
disable-model-invocation: true
---

# Up To Speed

Onboards Brian onto existing work for a given scope — explains **how everything works** so he builds an accurate mental model and can start contributing. Dispatches one backgrounded gatherer subagent per source (git+code, Jira/Confluence, Bitbucket, Slack) in parallel, synthesizes an **onboarding briefing** (understanding, not a done/in-progress status report), then stays in an interactive Q&A loop answering follow-ups until Brian is up to speed. Output is chat-only: nothing is written to disk.

## Args
- `<scope>` — the work to get up to speed on (PR#, branch, code-area, or topic). Required; if omitted, the skill asks once.
- Depth is inferred from the request (e.g. "quick gist of …" vs "deep dive on …").

## Output
A chat-only onboarding briefing — what & why, How it works, Key files & architecture, Where to jump in, Gotchas / open questions, Sources footer — then an interactive Q&A loop. Step D below is the single source of truth for the render template, section order, and depth-matched length.

---

## Execution guide

The briefing explains *how the work actually works* so Brian builds an accurate mental model and can start contributing. This is onboarding, not status reporting — the goal is understanding (how it fits together, where things live, why it is the way it is), not a done/in-progress/left-to-do report. Chat output is the canonical and sole output mode — **nothing is written to disk**.

The briefing is the *start* of onboarding, not the end: after it renders, the skill stays in an interactive Q&A loop (Step E), answering Brian's follow-up questions — re-querying sources when a question hits a gap — until he signals he's up to speed.

The orchestrator owns scope resolution, the parallel fan-out, the synthesis contract, and the Q&A loop. Gatherer subagents own only their source — they surface cited findings or abstain; they never read another source and never own the briefing shape.

---

## Source Registry (single source of truth for dispatch parameters)

This table is the canonical home for each source's `subagent_type`, `model`, and `tool list` — the steps below read those columns from here and never restate them in prose. Per-source *emphasis* (Step C) and cross-linking (Step D) live in those steps, so adding a source touches a row here plus its emphasis bullet and any cross-link rule.

| source | `subagent_type` (Agent tool) | model | tool list |
|---|---|---|---|
| git+code | `Explore` | `sonnet` | `Bash(git log/show/diff/blame --no-pager)`, `Grep`, `Glob`, `Read` |
| bitbucket | `general-purpose` | `sonnet` | `mcp__bitbucket__{get_pull_request,get_comments,get_diffstat,search_code,list_pull_requests}` |
| jira/confluence | `general-purpose` | `sonnet` | `mcp__claude_ai_Atlassian_Rovo__{getJiraIssue,searchJiraIssuesUsingJql,search,getConfluencePage,searchConfluenceUsingCql}` |
| slack | `general-purpose` | `sonnet` | `mcp__claude_ai_Slack__{slack_search_public_and_private,slack_search_public,slack_read_thread}` |

All four sources are always dispatched; each self-skips when it finds nothing (returning the abstinence sentinel from Step C).

**The `Explore`-vs-`general-purpose` split is critical — do not collapse all four sources to `Explore`.** `Explore`'s MCP reach is not guaranteed, so it is used only for the git+code gatherer (which needs Bash/Grep/Glob/Read, no MCP). The three MCP-backed sources (bitbucket, jira/confluence, slack) use `general-purpose`, which reaches MCP — evidenced by `plugins/brian/agents/code-historian.md` calling Atlassian and Bitbucket MCP tools directly. A future editor who renames `general-purpose` to `Explore` on an MCP source will silently break that source.

**Dispatch invariant**: when emitting an `Agent` call for a source, `subagent_type`, `model`, and the tool list all come from this table — never substitute a different value as a default.

---

## Step A. Parse the request

- `scope_raw` — the text of what to get up to speed on (a PR#, branch, code-area, or topic).
- **Empty `scope_raw`** → ask once in plain text for the scope. Do not guess. Never ask more than once.
- **Depth intent** — infer it from how the user phrases the request, then carry it into the gatherer prompts and the briefing length (see Depth below). Do not require a flag.

### Depth (inferred, one instruction for both modes)

Read the user's wording for how much they want:

- **Quick lean** — phrasing like "quick", "just the gist", "tl;dr", "orient me on". Keep each gatherer tight (lead with the single highest-signal fact, stop early) and render a short briefing — the what/why framer plus a compact How it works, touching Key files & architecture only where it's critical to start.
- **Deep lean** — phrasing like "deep dive", "thorough", "full context", "everything on". Let each gatherer dig further and render the full briefing, including deeper How it works and architecture.
- **Default** — no signal either way → a balanced briefing through Key files & architecture.

In every mode the interactive Q&A loop (Step E) still runs — depth only sets how much the *opening* briefing covers before Brian starts asking.

Depth changes how far each gatherer digs and how long the briefing runs — **never** the cite-or-abstain contract, the source set (all four always dispatch), or the section order. Pass the chosen lean to each gatherer as a one-line instruction in its prompt.

---

## Step B. Resolve scope

Classify `scope_raw` into `scope_type ∈ {pr, branch, code-area, topic}` using these ordered rules (first match wins). A `ticket-anchor` is recognized as a seed, not a scope type of its own.

1. **pr** — `scope_raw` matches `^#?\d+$`, a Bitbucket PR URL, or `(?i)\bPR[ -]?\d+\b`. Resolve the default repo from `git remote get-url origin` when inside a git repo; fall back to `drovacorp/interface` / `master` **only** when no remote resolves. Record the resolved repo in the Sources footer so a wrong guess is visible — a wrong-context briefing reads as authoritative, so it must be falsifiable.
2. **branch** — `git rev-parse --verify <scope_raw>` succeeds, `<scope_raw>` appears in `git branch -a --list '*<scope_raw>*'`, or it is branch-shaped (`feature/`, `bugfix/`, or contains `/`).
3. **ticket-anchor** — `scope_raw` matches `^[A-Z]+-\d+$` AND no branch contains it. Hand the key directly to the jira/confluence and bitbucket gatherers as a seed anchor (a direct `getJiraIssue` fetch is strictly better than keyword search), and resolve the code scope from the ticket's linked branch/PR. This honors "tickets are discovered" — the ticket seeds discovery of the code; it is not the briefing subject itself.
4. **code-area** — `test -e <scope_raw>`, `git ls-files '*<scope_raw>*'`, or `Glob` finds a matching path/module.
5. **topic** — fallback free text; sources search by keyword.

Record `resolved = {scope_type, concrete_target, anchors[]}`. `anchors[]` collects concrete handles — branch name, PR#, paths, merge-base, and ticket keys harvested via `git log --oneline -n 50 | grep -oE '[A-Z]+-[0-9]+'`. Anchors seed the subagents: a ticket key found in a branch name is handed to the jira gatherer, not rediscovered cold.

**Resolution gate:** only when classification is genuinely ambiguous (e.g. `scope_raw` matches both a branch and a folder, or a substring matches multiple branches) ask once in plain text, listing the candidate interpretations. Otherwise proceed silently. Never ask more than once.

---

## Step C. Fan out in parallel

Emit ALL four source `Agent` calls in a **single assistant message** with multiple `Agent` tool-use blocks. Each call uses `subagent_type`, `model`, and tool list from the Source Registry, and `run_in_background: true`.

**Wait discipline (critical — this is the line that makes backgrounding stick).** After dispatch: wait for harness notifications (they arrive on completion, so polling adds nothing) and emit at most one status line during the wait. Every source's data comes exclusively from its dispatched gatherer — the orchestrator holds the same MCP tools, and gathering inline is the lazy path that silently collapses the parallel-isolation guarantee. A source with no dispatched subagent is **skipped, not absorbed**.

### Shared per-source prompt skeleton

Each gatherer prompt is assembled from these blocks:

- **Role** — "You are the {SOURCE} gatherer. Surface from {SOURCE} ONLY the context needed to *start working* on {resolved scope}. You are a precise clerk: extract facts that exist, never infer ones that don't."
- **Scope anchors** — `resolved.concrete_target` + `resolved.anchors[]` relevant to this source.
- **Depth lean** — the one-line depth instruction from Step A (quick / deep / balanced).
- **Tools to use** — the source's tool list from the Source Registry.
- **Cite-or-abstain contract (HARD RULE)**:
  - Every claim carries an inline citation: a commit short-hash, a `PR#<n>`, a `[A-Z]+-\d+` ticket key, a `file:line`, or a Slack permalink URL.
  - A claim you cannot ground in a citation — don't state it.
  - If nothing relevant exists for this source, say so plainly and nothing else — state that you looked and found nothing, naming specifically what you looked for.
  - If a tool call *errors* (auth failure, renamed/unavailable tool, timeout) rather than returning empty, say so plainly instead — name the tool and what failed. Distinguish this clearly from "nothing found": an empty source is a real absence of signal; a failed tool is unknown coverage and must not be laundered into a clean abstention. Say which situation you're in so the orchestrator can tell them apart from your reply.
  - Intra-source disagreement → report both sides with citations; do not pick one silently.
- **Output** — prose, length matched to the depth lean. Lead with the single most start-relevant fact. Order by usefulness, not chronology.

### Per-source emphasis (tool lists live in the Registry)

- **git+code** (`Explore`) — how the work is structured and where it lives: entry points, the main flow, how the pieces fit, where someone new should start reading. Cite `file:line` and commit hashes. Surface ticket keys from commit subjects so synthesis can cross-link.
- **jira/confluence** (`general-purpose`) — the *why*: ticket(s), design docs, acceptance criteria, the latest intent-explaining comment. Fetch a seeded ticket key directly via `getJiraIssue`; otherwise keyword-search.
- **bitbucket** (`general-purpose`) — what the change does and the reasoning behind it: the diff's shape, the review discussion, and whether it's landed or in-flight (so Brian knows what's stable to build on). Use the repo resolved in Step B.
- **slack** (`general-purpose`) — recent team discussion, decisions, blockers, reversals; flag contradictions with PR/ticket state. **Exclude self-DMs** — any result whose conversation is a DM with Brian Pham as the only participant (e.g. channel `D07EGHRBLSJ`); these are Claude draft dumps, not team signal. If a "decision" is sourced ONLY from a self-DM, say plainly that you found nothing usable there rather than citing it — otherwise a real permalink launders a Claude draft past the citation check.

---

## Step D. Synthesize the chat briefing

When all dispatched subagents return (per the Step C wait discipline):

1. Collect each return and tag it by source.
2. **Read each gatherer's reply for meaning and sort it.** A gatherer that says it looked and found nothing relevant goes into `sources_abstained[]`; a gatherer that says a tool call failed goes into `sources_failed[]`. Never invent findings on an abstaining source's behalf, and never fold a failed source into "no signal" — it is incomplete coverage, not a clean empty.
3. **Cross-link discovered ticket keys** (git ↔ jira) without duplicating the same fact under two sources.

**Citation enforcement at the merge boundary (critical — re-assert the contract here, where claims get rewritten).** Before rendering, scan each synthesized bullet for an inline citation token: a commit short-hash, `PR#<n>`, a `[A-Z]+-\d+` ticket key, a `file:line`, or a Slack permalink URL. **A bullet with no token is dropped, not softened.** Compression during synthesis is exactly where a citation falls off while the claim survives, so the check lives at the consumer, not only the producer.

**Conflicts are first-class — for mental-model accuracy, not status-checking.** If two sources disagree (the design doc describes X but the code does Y; Slack says the approach changed but the branch still reflects the old one), surface both sides with citations inside **How it works** so Brian's mental model is correct from day one — never silently pick a side. Frame it as "here's what's actually true and why the sources diverge," not "verify before shipping."

Render to chat — prose, no file — in this fixed order. This is an *explainer*: lead with understanding, cite so Brian can go read the real thing himself.

```
{one-line what & why — what this work is and the problem it solves; cite the driving ticket/PR}

How it works
- The mental model: what happens end-to-end and how the pieces fit together [cite file:line / commit]
- (If sources diverge) What's actually true vs what a stale doc/thread says, and why [cite both sides]

Key files & architecture
- Where it lives + entry points: <paths> [file:line]
- How it's structured + where to start reading: <1–2 sentences> [file:line / commit]

Where to jump in          ← orientation for starting, not a completion report
- What's solid to build on vs where the active edge is [cite]

Gotchas / open questions          ← only if genuinely important before touching it
- <thing to watch> [cite]

—
Sources: gathered {list} (bitbucket repo: {resolved repo}); no signal from {abstained}; could not reach {failed + tool} — coverage incomplete.
```

Length matches the depth lean from Step A: a quick lean trims to the what/why framer + a compact How it works; a deep lean runs the full explainer with deeper architecture; the default runs through Key files & architecture. The Gotchas section appears only when genuinely important; the Sources footer appears regardless. Omit empty Sources clauses.

---

## Step E. Onboarding Q&A (stay in the loop)

The briefing opens onboarding; it does not finish it. After rendering, **explicitly invite Brian's questions and keep answering until he signals he's up to speed** (e.g. "got it", "makes sense", or he simply stops asking). Do not treat the first briefing as the end of the skill.

For each question:

1. **Answer from already-gathered context first** — you still hold every gatherer's return in memory; reuse it before spending tool calls.
2. **If the question hits a gap** (a file not yet read, a thread not yet pulled, a source not dug deep enough), re-dispatch only the relevant gatherer(s) — same Source Registry, same single-message backgrounded fan-out, same wait-don't-poll discipline, same cite-or-abstain contract — to dig deeper, then answer.
3. **Keep the citation discipline on every answer**: ground each claim in a commit / `PR#` / ticket key / `file:line` / Slack permalink, or say plainly you don't have it and offer to dig.
4. **Show, don't just tell** — Brian is building a mental model, so prefer reading and quoting the actual `file:line` / flow over describing it abstractly. Walk through the real code path when a question is about how something works.

Close only when Brian indicates he understands. A good close points at the natural next entry point — e.g. "you're set to start at `<file:line>`; ping me when you want to go deeper on `<area>`."
