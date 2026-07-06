---
name: scrutinize
description: "Use to review local code changes against Brian's house rules — correctness, reliability, security, tests, architecture, and code-cleanness."
---

# Scrutinize

## What it does
Reviews a local diff by axis (correctness, cleanness, security, tests, architecture, spec) with parallel reviewer subagents instead of one generalist pass, then synthesizes their findings under Brian's house rules into a severity-ordered list in chat. The diff is also snapshotted under a per-repo directory in `/tmp` (outside the repo) for replay.

## Args
- *(no args)* — working-tree mode: stages + unstaged + untracked files.
- `--branch <name>` — diff a branch against its merge-base with `main`/`master`/`origin/HEAD`.
- `--commit <sha>` — review a single commit.
- `--base <ref>` — diff `<ref>..HEAD`.
- `--axes=all` — force every axis (override smart-dispatch).
- `--axes=<csv>` — force a specific axis set (always-on axes still run).
- `--spec <path>` — explicit spec/PRD file for the spec axis to check the diff against.
- `--input <sha-ts>` — replay against a prior cached snapshot (see Output for the path).

## Output
- Diff snapshot: `/tmp/scrutinize/<flattened-repo-path>/<sha>-<UTC-ISO>.diff` — lives outside the repo (no `.gitignore` entry needed); used by `--input <sha-ts>` to replay against the cached diff.

## Instructions
See `instructions.md` for the full execution guide (Steps A–F, axis registry, smart-dispatch regexes).
