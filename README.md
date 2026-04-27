# skills

Brian Pham's personal Claude Code skills, published as a plugin marketplace.

## Install

Add as a marketplace in Claude Code:

```
/plugin marketplace add pt-hieu/skills
/plugin install brian@brian-skills
```

## Why these skills

Each of these started as a personal rule for working with Claude Code that I kept manually re-typing into prompts. The skills make them sticky.

### `challenge` — defend against tunnel vision

The hardest failure mode of an LLM coding session isn't a wrong answer; it's a *plausible* answer it commits to too early. Once a path is in context, the model is biased toward justifying it. One unnecessary read or misleading file shapes the rest of the session, and the model is unlikely to question whether the path was right to begin with.

`challenge` runs two subagents on a fresh context window, each with a specific methodology, against a plan or diff:

- **Architecture review** — does the change fit the surrounding codebase, or is it a local optimum that fights existing structure?
- **Root-cause review** — is this the real cause, or a patch on a symptom? Asks "why" repeatedly; runs a devil's-advocate pass.

Two green passes is a high bar. The primary agent rarely clears it on the first try, which is the point — it forces the plan to get better before it gets implemented. Recommended use: run `challenge` before exiting plan mode, before merging a non-trivial diff, or any time you suspect the agent has decided too quickly.

### `diagnose` — root-cause methodology, made systematic

A debugging script Claude can follow: problem framing, iterative deepening past the first plausible cause, defect-class identification, root-cause validation tests, devil's-advocate self-challenge. Pairs with `challenge` — `diagnose` builds the hypothesis, `challenge` stress-tests it.

### `commit` — structured commit workflow

Stops Claude from writing the kind of commit message a future blame won't thank you for.

### `prompting` — research-backed prompting techniques for reliable LLM agents

Conflict detection, confidence calibration, pro/con balance, chain-of-verification, data citation, hallucination prevention. Useful when designing agent prompts or structured-output schemas, not just when running them.

## What's inside

Single bundled plugin `brian` containing:

| Skill | Purpose |
| --- | --- |
| `challenge` | Audit a plan or implementation with 2 independent opus subagents. |
| `commit` | Structured commit workflow. |
| `diagnose` | Systematic root-cause debugging methodology. |
| `prompting` | Research-backed prompting techniques for reliable LLM agents. |

## Layout

```
.claude-plugin/
  marketplace.json          # marketplace manifest
plugins/
  brian/
    .claude-plugin/
      plugin.json           # plugin manifest
    skills/
      challenge/
      commit/
      diagnose/
      prompting/
```

## License

MIT
