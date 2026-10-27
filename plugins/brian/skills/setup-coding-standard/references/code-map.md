# Template: code map

> Applies to every repo. The map is written from the repo's own tree, and every path it names exists in the repo.

`CODE_MAP.md` shows an agent where to go for a task, so it opens the right file first. Its reader is an agent that has the repo checked out and reads the map before its first search. It holds:

- **Areas.** Each top-level directory, and each subdirectory an agent would visit for a different reason, with a line on what lives there and the task that brings an agent to it. In a monorepo, each package is an area with its own subareas.
- **Entry points.** The files where execution starts or is wired together: the app's main, the route table, CLI commands, workers, and the build, test, and formatter configs.
- **Where to go for a task.** The changes this repo sees most and the files each one touches, for example "add an API route: the handler goes in `src/routes/`, is registered in `src/routes/index.ts`, and is tested in `src/routes/__test__/`".
- **Paths you can predict.** A naming convention that gives a file's path from what the file holds, such as one folder per component or one file per route. When `CODING_STANDARDS.md` states the convention as a rule, the map gives the path pattern and the rule stays in `CODING_STANDARDS.md`.
- **Places to skip.** Generated, vendored, and build-output directories that a search will hit, and directories whose names point to the wrong thing.

Leave out a listing of every file and anything one glob finds; `ls` gives the agent those faster than the map.

**Existing file** — check every path it names against the tree. A path that moved is updated, a path that is gone is removed with its line, and an area, entry point, or task the map lacks is added. Lines about paths that still exist stay as written.

**Agent instruction file** — give `CLAUDE.md` (or `AGENTS.md`) this block, beside the `CODING_STANDARDS.md` pointer:

`CODE_MAP.md` says where things live in this repo; read it before searching for a file. A change that adds, moves, or removes a directory, an entry point, or a path the map names updates the map in the same commit.
