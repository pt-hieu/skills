---
name: up-to-speed
description: "Use when hands off any scope of existing work and needs a context briefing to start working."
argument-hint: "[PR# | branch | code-area | topic]"
disable-model-invocation: true
---

# Up To Speed

Onboards Brian onto existing work for a given scope — explains **how everything works** so he builds an accurate mental model and can start contributing. Dispatches one backgrounded gatherer subagent per source (git+code, Jira/Confluence, Bitbucket, Slack) in parallel, synthesizes an **onboarding briefing** (understanding, not a done/in-progress status report), then stays in an interactive Q&A loop answering follow-ups until Brian is up to speed. Output is chat-only: nothing is written to disk.

## Args
- `<scope>` — the work to get up to speed on (PR#, branch, code-area, or topic). Required; if omitted, the skill asks once.
- Depth is inferred from the request (e.g. "quick gist of …" vs "deep dive on …").

## Output
An onboarding briefing in this fixed order (length matches the requested depth), followed by an interactive Q&A loop:
1. One-line what & why (cites the driving ticket/PR).
2. **How it works** — the mental model: what happens end-to-end and how the pieces fit, plus any source divergence worth knowing.
3. **Key files & architecture** — where the work lives, entry points, and where to start reading.
4. **Where to jump in** — orientation for starting (lay of the land, not a completion report).
5. **Gotchas / open questions** — only if genuinely important before touching it.
6. Sources footer — what was gathered, abstained, and could not be reached.

Then the skill stays in an interactive Q&A loop, answering follow-up questions (re-querying sources on gaps, every answer cited) until Brian is up to speed.

## Instructions
See `instructions.md` for the full execution guide (Steps A–E, Source Registry, scope-resolution rules, per-source prompt skeleton, synthesis contract, and the onboarding Q&A loop).
