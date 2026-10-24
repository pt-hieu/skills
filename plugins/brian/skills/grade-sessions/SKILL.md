---
name: grade-sessions
description: "Grades past Claude Code sessions on Claude's work and Brian's prompting, and ranks the recurring patterns with the edits that would fix them."
argument-hint: "[--since YYYY-MM-DD] [--project SUBSTRING] [--batches N]"
disable-model-invocation: true
---

# Grade sessions

`grade-sessions` grades Brian's Claude Code history with a fleet of sonnet graders and has one opus agent rank what keeps going wrong, so that Brian changes skills and habits on evidence from his own sessions. The leading word is **evidence**: every grade rests on a quote from a transcript, and every proposed edit quotes the text it changes.

Each session gets 1 to 5 on six dimensions for Claude and three for Brian; [`references/rubric.md`](references/rubric.md) defines them and the correction categories, and it is the graders' brief. The run is one Workflow over 30 batches by default, about 3.4M subagent tokens and ten minutes for 190 sessions.

## Steps

1. **Condense.** Make the run directory `/tmp/grade-sessions/<YYYY-MM-DD-HHMM>/` and run `python3 -I <skill dir>/scripts/condense.py <run dir>` with the arguments Brian passed. It keeps sessions with at least three of Brian's messages, cuts tool output, and balances the sessions into one batch per grader. Done when it prints its summary line; when it reports zero sessions, tell Brian which filter emptied the set and stop.

2. **Grade.** Run `Workflow({scriptPath: "<skill dir>/scripts/grade.js", args: {batches, rubricPath, skillsDir}})`, where `batches` is the array read from `<run dir>/batches.json`, `rubricPath` is the absolute path to `references/rubric.md`, and `skillsDir` is the absolute path to `${CLAUDE_PLUGIN_ROOT}/skills`. The workflow grades every batch, regrades any session a grader dropped, and synthesizes. Done when its completion notification arrives.

3. **Collect.** Run `python3 -I <skill dir>/scripts/collect.py <workflow output file> <run dir>`, using the output file path from the notification. Done when it writes `report.md` and `sessions.json` and prints the coverage line.

4. **Check the edits.** The synthesizer proposes edits to named files, and its summary can misquote them. For every proposed edit, confirm that the text it says it changes is in the named file today, and that the rule it says is missing is missing. Done when every edit is marked confirmed or wrong; correct or drop the wrong ones in `report.md`.

5. **Report.** Give Brian the score table for each side (the scale tops out at 5), the top Claude patterns and top Brian patterns with one quote each, and the caveats: ungraded sessions, rules that postdate sessions, and edits dropped in step 4. Point to `report.md` and `sessions.json`. Apply none of the edits; Brian chooses which ones to make.
