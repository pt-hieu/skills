# Template: the agent instruction file

> Applies when the repo has a `CLAUDE.md` or an `AGENTS.md`. The text below says `CLAUDE.md` for either.

`CLAUDE.md` is loaded into every session, so each of its lines costs context on every task, including the tasks it has nothing to do with. It is a phonebook: it says what the repo is in a sentence or two, and it points to the files that hold the detail, each pointer saying what the file holds and when to open it. An agent then loads the detail for the task in front of it and nothing else.

Each line of an existing `CLAUDE.md` is one of these kinds:

- **A pointer** to a file stays, once the path is checked against the tree. A pointer to a path that moved is updated, and one to a path that is gone is removed.
- **An instruction that applies to every task and that no file in the repo states** stays exactly as written, because it is Brian's and every session needs it: what to do before committing, which tool to run in place of another, what to leave alone. The blocks this skill writes are of this kind.
- **A fact the repo already states** is deleted: anything a reader gets from the code, the comments already in it, a manifest, a config, or `ls`. A copy in `CLAUDE.md` goes stale when the code changes, and an agent that trusts the stale copy acts on a repo that is gone. A line that contradicts the code is deleted for the same reason.
- **A fact no file states, about one area or one task,** moves to where an agent working on that area looks. When it is about a path or a task (the command that validates a config, the step a change must not skip, the reason a file is built the way it is), it becomes a line in `CODE_MAP.md`. When it is too long for one map line, it goes in a Markdown file beside the code it describes, and `CODE_MAP.md` gets a line naming that file and the task that opens it.

A fact moves into `CODE_MAP.md` or a Markdown file and never into a code comment, because `CODING_STANDARDS.md` allows no new comments. The comments already in the code stay: this skill edits no source file.

To tell a stated fact from an unstated one, find the file that states it. The file and line go in the report beside the deleted text, so Brian can check that nothing was lost. A fact with no such file is unstated and moves.
