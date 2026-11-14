# skills

Brian Pham's personal Claude Code skills.

## Install

Add the marketplace and install both plugins from a Claude Code session:

```
/plugin marketplace add pt-hieu/skills
/plugin install brian@brian-skills
/plugin install design@brian-skills
```

## My workflow

Most of my work happens in Claude Code, where Claude does the typing and I steer. I built these skills for the points in that loop where a session most often goes wrong.

### 1. While Claude is debugging: `diagnose`

When something breaks, Claude reaches for the first plausible cause. `diagnose` makes it prove the root cause with a reproduction that fails because of it, then search for every other instance of the defect class that cause names.

### 2. When Claude is writing prompts, agents, or skills: `prompting`

I build a lot of LLM agents and skills, and all of them run on prose a model reads. `prompting` is how I write that prose: in sentences with reasons, addressed to a reader, with the no-ops cut. It adds what an agent prompt must ask for (missing-data handling, conflicts, the case against, confidence with its basis, citation) and lays a skill out as a result and the checks that verify it, so an agent reaches the same result every run. On an existing prompt surface, it removes instructions written for older models, such as pressure language, thinking and prefill scaffolds, and version workarounds.

### 3. When the work is done: `commit`

`commit` puts each concern in its own commit when staging can separate them, and bundles them into one commit when separating them would mean editing file content. Each message is a gitmoji and a conventional-commit line naming the behavior that changed.

### 4. When I'm building UI: `design`

`principles` collects the UI design rules I'd otherwise re-explain on every project: component patterns, formatting, interaction defaults, motion, and touch. Claude loads it when it touches frontend code.

`prototype` builds a throwaway clickable flow inside an app that consumes my flyingsalmon design system, on its own worktree branch and from registry components. It runs on fake data with a scenario switcher, and adds design variants when the question compares directions.

`break-ui` feeds a component the worst data its real users will produce (unbreakable emails, one-letter names, missing fields, huge counts) behind a toggle, then reports what broke and waits for me to pick the fixes.

## What's inside

### `brian`: engineering workflow

| Skill | Purpose |
| --- | --- |
| `autopilot` | Take a requirement to a PR autonomously, outside plan mode, with the PR as the human review point. |
| `commit` | Commit the working tree in one commit per concern, with gitmoji conventional-commit messages. |
| `diagnose` | Root-cause debugging, proven by a reproduction. |
| `prompting` | Write the prose LLMs read (agent prompts, skills, subagent instructions, and handoffs), and remove instructions written for older models from an existing prompt surface, leaving the edits in the working tree. |
| `scrutinize` | Review local code changes against Brian's house rules for cleanness (comments, reuse), security, tests, and the repo's own `CODING_STANDARDS.md`. |
| `setup-coding-standard` | Write or update a repo's `CODING_STANDARDS.md` from a catalog of standards, picking the sections that fit the stack; write a `CODE_MAP.md` that guides an agent to the right files; and start a `DESIGN-LANGUAGE.md` in a personal project with a UI. |
| `show-me` | Explain the current topic visually as pseudocode, a call tree, a component tree, a file tree, Mermaid, a diff, or a one-off HTML artifact, picking the smallest view that makes the point. |
| `teach` | Build a lesson for a complete newbie: one scrolling desktop HTML page of levels from simple to complex, with storybook-style illustrations and self-playing animations, using up to five opus subagents. |
| `writing` | Write and revise prose a human reads (essays, posts, docs) against rules distilled from the patterns that mark prose as machine-made. |

The skills above dispatch these agents:

| Agent | Purpose |
| --- | --- |
| `architectural-reviewer` | Stress-tests a plan or diff for architectural drift, coupling, expandability, and historical coherence. |
| `code-historian` | Gathers the history behind code from git and the ticket tracker. |
| `review-cleanness` | Flags every comment that explains anything other than why, shim residue, reuse defects, breaks of the repo's `CODING_STANDARDS.md`, and behavior-preserving quality improvements. |
| `review-security` | Reviews a diff for application security. |
| `review-tests` | Reviews a diff's test coverage. |
| `root-cause-reviewer` | Checks that a fix addresses the root cause rather than a symptom. |

### `design`: UI design rules

| Skill | Purpose |
| --- | --- |
| `break-ui` | Worst-case data behind a toggle, a report of every break with its fix, and fixes applied on request. |
| `principles` | UI design principles, component patterns, formatting, interaction, motion, and touch rules. |
| `prototype` | Throwaway clickable flow on fake data with a scenario switcher and optional design variants, built from flyingsalmon registry components on a worktree branch. |

## Layout

```
.claude-plugin/
  marketplace.json
plugins/
  brian/
    .claude-plugin/plugin.json
    skills/
      autopilot/
      commit/
      diagnose/
      prompting/
      scrutinize/
      setup-coding-standard/
      show-me/
      teach/
      writing/
    agents/
      architectural-reviewer.md
      code-historian.md
      review-cleanness.md
      review-security.md
      review-tests.md
      root-cause-reviewer.md
  design/
    .claude-plugin/plugin.json
    skills/
      break-ui/
      principles/
      prototype/
```

## Credits

Several skills and agents distil other people's skills:

- `show-me` is distilled from [humanlayer/skills](https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md)' `show-me`.
- `architectural-reviewer` takes its Module Depth dimension and its Fowler smell baseline from [Matt Pocock's skills](https://github.com/mattpocock/skills), and `review-cleanness` takes the baseline's Duplicated Code smell.
- `break-ui` is distilled from Emil Kowalski's [`break-ui`](https://github.com/emilkowalski/skills/tree/main/skills/break-ui) (MIT License).
- `principles` draws its motion, touch, and interaction rules from Emil Kowalski's [skills](https://github.com/emilkowalski/skills) (MIT License): `emil-design-eng`, `animate`, `review-animations`, `apple-design`, and `mobile-native`.
- `prototype`'s craft guidance is distilled from Anthropic's [`frontend-design`](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/frontend-design) (Apache License 2.0).

## License

MIT
