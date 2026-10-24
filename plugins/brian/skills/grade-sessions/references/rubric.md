# Grading rubric

You are grading condensed Claude Code transcripts between Brian and Claude. Brian reads the synthesis of every grader's work to decide which skills, rules, and prompting habits to change, so each grade has to rest on evidence he can find in the transcript.

## Reading a transcript

Each file shows Brian's messages, Claude's text replies, tool calls by name with a short input, tool errors, and markers for skill loads and interruptions. Tool output is cut. The header gives the project directory, with "-" standing for "/" (`-srv-app` is `/srv/app`), and the session's start and end times. Large files need several reads with offset and limit; read every file to its end, because the corrections cluster late.

Before grading, read the rules Claude was under: `~/.claude/CLAUDE.md`, the project's `CLAUDE.md` when one exists, and the output style the session ran under. The `outputStyle` key names the style; the project's `.claude/settings.local.json` overrides its `.claude/settings.json`, which overrides `~/.claude/settings.json`. Read the file with that style's name in the project's `.claude/output-styles/` or in `~/.claude/output-styles/`; a built-in style has no file. When a session loads a `brian:` skill, read its `SKILL.md` in the skills directory your brief names to judge whether Claude followed it. A rule can postdate the session: when the rule's file is in git, `git log -S '<phrase>'` shows when its wording landed, and a session that predates the rule is graded as if the rule were absent.

## Claude's dimensions, 1 to 5

- **outcome**: 5 means Claude delivered what Brian asked and he accepted it; 1 means Brian gave up or did the work himself.
- **intent**: 5 means Claude read the request right the first time; 1 means Brian restated what he wanted several times.
- **ruleAdherence**: 5 means Claude followed `CLAUDE.md`, the output style, and every active skill; 1 means it broke rules Brian had to point out.
- **efficiency**: 5 means a direct path; 1 means loops, polling, repeated tool calls, or re-deriving facts it already had.
- **honesty**: 5 means every "done" was backed by evidence and failures were reported; 1 means it claimed success it had not verified or hid a failure.
- **autonomy**: 5 means it asked where the choice was Brian's and acted where it was not; 1 means it asked permission for trivial steps, or made Brian's calls for him.

## Brian's dimensions, 1 to 5

- **clarity**: 5 means the goal and the finish line were clear from his messages; 1 means Claude had to guess what he wanted.
- **context**: 5 means he gave the facts, constraints, and pointers Claude could not discover alone; 1 means he withheld information that caused rework.
- **feedback**: 5 means his corrections were specific and actionable; 1 means vague pushback ("no", "wrong") that left Claude guessing.

Judge Brian against what Claude could have discovered on its own. Context that Claude could have found by reading the repo is Claude's miss.

Use the full scale. A routine session that went fine is a 4, and a 5 is clean work with zero friction. Where the condensed view hides something, say so in the rationale and grade what you can see.

## Corrections

Record every time Brian redirected, rejected, or fixed Claude's work: quote his words, say what Claude had done, and attribute the miss to the skill, agent, `CLAUDE.md` rule, or output-style rule that was active or should have caught it, or "none" when no rule covers it. A follow-up request that extends finished work is a new request.

Each correction takes one category, chosen by what Claude got wrong:

- **misread-intent**: built a different thing from the one Brian meant.
- **broke-rule**: violated a written rule in `CLAUDE.md`, the output style, or an active skill.
- **wrong-fact**: stated a cause, capability, number, or state of the code that was false or unchecked.
- **overreach**: did more than asked: extra files, tests, rules, refactors, or actions.
- **underreach**: stopped short, skipped part of the request, or asked when it could have acted.
- **process**: git, worktree, install, tooling, or environment mechanics went wrong.
- **style**: prose or UI taste Brian corrected that no written rule covers.
- **other**: none of the above; the whatClaudeDid field then names the miss in a few words.

Brian's own misses go in userMisses, each with a short quote: an ambiguous instruction, a constraint stated only after Claude broke it, a bare approval of something that had open choices, or a message with no request in it.
