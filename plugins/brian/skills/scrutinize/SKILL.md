---
name: scrutinize
description: "Use to review local code changes against Brian's house rules — correctness, reliability, security, tests, architecture, and code-cleanness (including reuse, simplification, efficiency, and altitude quality cleanups).
---

# Scrutinize

## What it does
Dispatches axis-specialized opus reviewer subagents in parallel against the local diff, synthesizes findings against Brian's house rules (citation-or-drop, severity gate, anti-cosmetic gate, root-cause framing), and prints a severity-ordered findings list to chat. The diff is also snapshotted under a per-repo directory in `/tmp` (outside the repo) for replay.

## Args
- *(no args)* — working-tree mode: stages + unstaged + untracked files.
- `--branch <name>` — diff a branch against its merge-base with `main`/`master`/`origin/HEAD`.
- `--commit <sha>` — review a single commit.
- `--base <ref>` — diff `<ref>..HEAD`.
- `--axes=all` — force every axis (override smart-dispatch).
- `--axes=<csv>` — force a specific axis set (always-on axes still run).
- `--input <sha-ts>` — replay against a prior cached `.scrutinize/<sha-ts>.diff` snapshot.

## Output
- Diff snapshot: `/tmp/scrutinize/<flattened-repo-path>/<sha>-<UTC-ISO>.diff` — lives outside the repo (no `.gitignore` entry needed); used by `--input <sha-ts>` to replay against the cached diff.

## Instructions
See `instructions.md` for the full execution guide (Steps A–G, axis registry, smart-dispatch regexes).
