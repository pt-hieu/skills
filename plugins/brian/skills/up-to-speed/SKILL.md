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
A chat-only onboarding briefing — what & why, How it works, Key files & architecture, Where to jump in, Gotchas / open questions, Sources footer — then an interactive Q&A loop. Step D of `instructions.md` is the single source of truth for the render template, section order, and depth-matched length.

## Instructions
See `instructions.md` for the full execution guide (Steps A–E, Source Registry, scope-resolution rules, per-source prompt skeleton, synthesis contract, and the onboarding Q&A loop).
