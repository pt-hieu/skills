# skills

Brian Pham's personal Claude Code skills, published as a plugin marketplace.

## Install

Add as a marketplace in Claude Code:

```
/plugin marketplace add pt-hieu/skills
/plugin install skills@brian-skills
```

## What's inside

Single bundled plugin `skills` containing:

| Skill | Purpose |
| --- | --- |
| `challenge` | Audit a plan or implementation with 2 independent opus subagents. |
| `commit` | Structured commit workflow. |
| `diagnose` | Systematic root-cause debugging methodology. |
| `prompting` | Research-backed prompting techniques for reliable LLM agents. |

## Layout

```
.claude-plugin/
  marketplace.json   # marketplace manifest
  plugin.json        # plugin manifest
skills/
  challenge/
  commit/
  diagnose/
  prompting/
```

## License

MIT
