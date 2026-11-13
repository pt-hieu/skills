---
name: grade-sessions
description: "Grades past Claude Code sessions on Claude's work and Brian's prompting, and ranks the recurring patterns with the edits that would fix them."
argument-hint: "[--since YYYY-MM-DD] [--project SUBSTRING] [--batches N]"
disable-model-invocation: true
---

# Grade sessions

`grade-sessions` grades Brian's Claude Code history with a fleet of sonnet graders and has one opus agent rank what keeps going wrong, so that Brian changes skills and habits on evidence from his own sessions. The leading word is **evidence**: every grade rests on a quote from a transcript, and every proposed edit quotes the text it changes.

Each session gets 1 to 5 on six dimensions for Claude and three for Brian; [`references/rubric.md`](references/rubric.md) defines them and the correction categories, and it is the graders' brief. The run is one Workflow over 30 batches by default, about 3.4M subagent tokens and ten minutes for 190 sessions (measured 2026-10).

## The result

Brian has the grades in chat and the files behind them on disk, and no file outside the run directory changed.

- **In chat**: the score table for each side (the scale tops out at 5), the top Claude patterns and the top Brian patterns with one quote each, and the caveats: ungraded sessions, rules that postdate the sessions they were graded against, and proposed edits dropped as wrong. It points to the two files.
- **On disk**: `report.md` and `sessions.json` in the run directory `/tmp/grade-sessions/<YYYY-MM-DD-HHMM>/`.

The report proposes edits to skills and applies none of them, because Brian chooses which ones to make.

## The scripts

The grades come from the three scripts under `<skill dir>/scripts/`. A run that grades by hand is not comparable with the last one, so when a script fails, report the failure in place of a result.

- `python3 -I <skill dir>/scripts/condense.py <run dir>`, with the arguments Brian passed, keeps the sessions with at least three of Brian's messages, cuts tool output, and writes `<run dir>/batches.json`, one balanced batch per grader. It prints a summary line. When it reports zero sessions, the whole result is one line telling Brian which filter emptied the set.
- `Workflow({scriptPath: "<skill dir>/scripts/grade.js", args: {batches, rubricPath, skillsDir}})` grades every batch, regrades any session a grader dropped, and synthesizes. `batches` is the array in `batches.json`, `rubricPath` is the absolute path to `references/rubric.md`, and `skillsDir` is the absolute path to `${CLAUDE_PLUGIN_ROOT}/skills`. Its completion notification names its output file.
- `python3 -I <skill dir>/scripts/collect.py <workflow output file> <run dir>` writes `report.md` and `sessions.json` and prints the coverage line.

## Verify

- `collect.py` printed its coverage line, and both files exist in the run directory.
- Every edit `report.md` proposes was checked against the file it names as that file is today: the text it says it changes is there, and the rule it says is missing is missing. The synthesizer's summary can misquote, so an edit that fails the check is corrected or dropped in `report.md` and counted in the caveats.
- Every pattern in the chat report carries a quote that appears in `report.md`.
