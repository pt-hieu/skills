---
name: scrutinize
description: "Use to review local code changes against Brian's house rules — correctness, reliability, security, tests, architecture, and code-cleanness.
---

# Scrutinize

## What it does
Dispatches axis-specialized opus reviewer subagents in parallel against the local diff, synthesizes findings against Brian's house rules (citation-or-drop, severity gate, anti-cosmetic gate, root-cause framing), and renders a single self-contained HTML report plus a JSON sidecar.

## Args
- *(no args)* — working-tree mode: stages + unstaged + untracked files.
- `--branch <name>` — diff a branch against its merge-base with `main`/`master`/`origin/HEAD`.
- `--commit <sha>` — review a single commit.
- `--base <ref>` — diff `<ref>..HEAD`.
- `--axes=all` — force every axis (override smart-dispatch).
- `--axes=<csv>` — force a specific axis set (always-on axes still run).
- `--input <sha-ts>` — replay against a prior cached `.scrutinize/<sha-ts>.diff` snapshot.
- `--no-html` — chat-only mode; suppresses the HTML report. Use sparingly — the HTML is the canonical artifact and is mandatory unless this flag is set.

## Output
- HTML report: `/tmp/scrutinize-<repo>-<sha>-<UTC-ISO>.html` — self-contained; open in browser.
- Diff snapshot: `<repo>/.scrutinize/<sha>-<UTC-ISO>.diff` — used by `--input <sha-ts>` to replay against the cached diff.

## Recommended .gitignore snippet
Add to the target repo's `.gitignore`:

```
.scrutinize/
```

## Instructions
See `instructions.md` for the full execution guide (Steps A–H, axis registry, smart-dispatch regexes, JSON schema, HTML render).
