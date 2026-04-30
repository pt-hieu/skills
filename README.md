# skills

Brian Pham's personal Claude Code skills, published as a plugin marketplace.

## Install

Add as a marketplace in Claude Code:

```
/plugin marketplace add pt-hieu/skills
/plugin install brian@brian-skills
/plugin install voice@brian-skills
/plugin install design@brian-skills
```

## How I use these — my workflow

Most of my work happens through Claude Code, where Claude does the typing and I steer. These skills are the rails that keep that loop honest. They're organized around the moments where I most often go off the road.

### 1. Before I let Claude commit to a plan — `challenge` + `recap`

The most expensive mistake in an LLM session is a *plausible* plan that's wrong. Once it's in context, the model justifies it instead of questioning it. So before I exit plan mode, two things happen:

- **`challenge`** runs two fresh-context subagents — one for architecture fit, one for root cause — against the plan. Two green passes is a high bar; the first plan rarely clears it, which is the point.
- **`recap`** then summarizes the surviving plan back to me in everyday language: problem, fix, new behavior, no jargon. That's where I catch direction-level mistakes that a technical plan would have hidden behind file names.

Only after both do I approve and let implementation start.

### 2. While Claude is debugging — `diagnose`

When something breaks, Claude defaults to the first plausible cause. `diagnose` is a script it follows instead: frame the problem, deepen past the first hypothesis, identify the defect class, validate with a test, run a devil's-advocate pass. It pairs with `challenge` — `diagnose` builds the hypothesis, `challenge` stress-tests it.

### 3. When Claude is writing prompts or agents — `prompting`

I build a lot of LLM agents. `prompting` is the set of techniques I keep reaching for: conflict detection, confidence calibration, pro/con balance, chain-of-verification, citation, hallucination prevention. Useful when designing agent prompts and structured-output schemas, not only when running them.

### 4. When the work is done — `commit`

Stops Claude from writing the kind of commit message a future `git blame` won't thank me for. Enforces format, blocks batch/summary commits, splits when concerns differ.

### 5. When I'm posting outward — `voice`

Slack messages, PR descriptions, Bitbucket and Jira comments. `voice` writes them in my warm, hedged, emoji-aware engineering register instead of the flat tone an LLM defaults to. Strictly outbound — not for code, plans, or chat replies.

### 6. When I'm building UI — `design`

`principles` collects the UI design rules I otherwise re-explain on every project: component patterns, formatting, interaction defaults. Loads automatically when Claude is touching frontend.

## What's inside

Three plugins, each a coherent domain:

### `brian` — engineering workflow rigor

| Skill | Purpose |
| --- | --- |
| `challenge` | Audit a plan or implementation with two independent opus subagents. |
| `commit` | Structured commit workflow. |
| `diagnose` | Systematic root-cause debugging methodology. |
| `prompting` | Research-backed prompting techniques for reliable LLM agents. |

### `voice` — outbound communication

| Skill | Purpose |
| --- | --- |
| `voice` | Team-facing writing voice for Slack, PRs, Bitbucket, Jira. |
| `recap` | Plain-language plan recap before exiting plan mode. |

### `design` — UI design rules

| Skill | Purpose |
| --- | --- |
| `principles` | UI design principles, component patterns, formatting, interaction rules. |

## Layout

```
.claude-plugin/
  marketplace.json
plugins/
  brian/
    .claude-plugin/plugin.json
    skills/
      challenge/
      commit/
      diagnose/
      prompting/
  voice/
    .claude-plugin/plugin.json
    skills/
      voice/
      recap/
  design/
    .claude-plugin/plugin.json
    skills/
      principles/
```

## License

MIT
