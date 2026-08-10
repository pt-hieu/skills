# skills

Brian Pham's personal Claude Code skills, published as a plugin marketplace.

## Install

Add as a marketplace in Claude Code:

```
/plugin marketplace add pt-hieu/skills
/plugin install brian@brian-skills
/plugin install design@brian-skills
```

## How I use these — my workflow

Most of my work happens through Claude Code, where Claude does the typing and I steer. These skills are the rails that keep that loop honest. They're organized around the moments where I most often go off the road.

### 1. Before I let Claude commit to a plan — `challenge`

The most expensive mistake in an LLM session is a *plausible* plan that's wrong. Once it's in context, the model justifies it instead of questioning it. So before I exit plan mode, `challenge` runs a panel of fresh-context subagents against the plan — architecture fit and root cause always; in plan mode also a fact-checker that verifies the plan's claims against the actual repo, plus an optional bespoke critic the orchestrator writes for whichever aspect of this particular plan most deserves depth.

Then it comes to me. Every surviving concern is put as a decision — what the plan proposes, what the tension is, what my options are and which one Claude recommends. I answer each one, Claude applies my directions, and that's the run. Nothing gets fixed, rebutted, or waved through on my behalf: I'd rather spend one turn deciding than read a model negotiating with itself.

Only after I've directed every tension do I approve and let implementation start.

### 2. While Claude is debugging — `diagnose`

When something breaks, Claude defaults to the first plausible cause. `diagnose` is a script it follows instead: frame the problem, deepen past the first hypothesis, identify the defect class, validate with a test, run a devil's-advocate pass. It pairs with `challenge` — `diagnose` builds the hypothesis, `challenge` stress-tests it.

### 3. When Claude is writing prompts or agents — `prompting`

I build a lot of LLM agents. `prompting` is the set of techniques I keep reaching for: conflict detection, confidence calibration, pro/con balance, chain-of-verification, citation, hallucination prevention. Useful when designing agent prompts and structured-output schemas, not only when running them.

### 4. When the work is done — `commit`

Stops Claude from writing the kind of commit message a future `git blame` won't thank me for. Enforces format, blocks batch/summary commits, splits when concerns differ.

### 5. When I'm building UI — `design`

`principles` collects the UI design rules I otherwise re-explain on every project: component patterns, formatting, interaction defaults. Loads automatically when Claude is touching frontend.

## What's inside

Two plugins, each a coherent domain:

### `brian` — engineering workflow rigor

| Skill | Purpose |
| --- | --- |
| `assess-code-review` | Work a Bitbucket PR's open review comments to closure — assess, propose fixes or push-backs, apply and resolve on approval. |
| `autopilot` | Autonomous, no-human-in-the-loop sibling of `kickoff`: takes a requirement to a PR without entering plan mode. |
| `bro` | Restate the last message in plain human language, with no jargon. |
| `challenge` | Audit a plan or implementation with a panel of independent subagents — fixed architecture and root-cause reviewers, plus plan-mode fact-checking, premise falsification, and a target-specific bespoke critic — then surface every tension as a decision for the user, with options and a recommendation. |
| `commit` | Structured commit workflow. |
| `consult-fable` | Spawn a Fable second opinion — one consultant per named decision fork — where legwork could not settle it, or where a wrong branch is a one-way door. |
| `diagnose` | Systematic root-cause debugging methodology. |
| `kickoff` | Turn a new requirement, ticket, or task description into a planned kickoff file. |
| `prompting` | Research-backed prompting techniques for reliable LLM agents. |
| `resolve-merge-conflicts` | Resolve Git merge conflicts. |
| `scrutinize` | Review local code changes against Brian's house rules across correctness, reliability, security, tests, architecture, and cleanness axes. |
| `up-to-speed` | Context briefing that explains how existing work fits together so you can start contributing. |
| `writing-skills` | Principles and vocabulary for writing and editing skills that make an agent's behaviour predictable. |

**Agents** (dispatched by the skills above, not invoked directly):

| Agent | Purpose |
| --- | --- |
| `architectural-reviewer` | Stress-tests a plan or diff for architectural drift, coupling, expandability, and historical coherence. |
| `code-historian` | Gathers historical "why" context from git history and the ticket tracker. |
| `fable-consultant` | Weighs in on one hard decision fork — recommendation, strongest case against it, and the observation that would flip it. Advisory only. |
| `plan-fact-checker` | Verifies a plan's file:line, count, path, and toolchain claims against the actual repo; audits internal numeric consistency. |
| `plan-verifier` | Final gate on a kickoff plan file before exiting plan mode. |
| `review-cleanness` | Local code-shape hygiene and behavior-preserving quality angles. |
| `review-correctness-reliability` | Adversarial reviewer for correctness and reliability defects. |
| `review-security` | Application-security reviewer for a diff. |
| `review-spec` | Checks a diff against what its originating ticket / PRD asked for — missing, extra, or wrongly-implemented requirements. |
| `review-tests` | Test-coverage reviewer for a diff. |
| `root-cause-reviewer` | Validates that a fix addresses the root cause rather than a symptom. |
| `test-designer` | Designs the Test design section of a kickoff plan file. |

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
      assess-code-review/
      autopilot/
      bro/
      challenge/
      commit/
      consult-fable/
      diagnose/
      kickoff/
      prompting/
      resolve-merge-conflicts/
      scrutinize/
      up-to-speed/
      writing-skills/
    agents/
      architectural-reviewer.md
      code-historian.md
      fable-consultant.md
      plan-fact-checker.md
      plan-verifier.md
      review-cleanness.md
      review-correctness-reliability.md
      review-security.md
      review-spec.md
      review-tests.md
      root-cause-reviewer.md
      test-designer.md
  design/
    .claude-plugin/plugin.json
    skills/
      principles/
```

## License

MIT
