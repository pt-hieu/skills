---
name: resolve-merge-conflicts
description: "Use when resolving Git merge conflicts — merge, rebase, or cherry-pick conflicts, unmerged paths, or `<<<<<<<` conflict markers in the working tree"
---

# Resolve merge conflicts

The run is done when the operation in progress (merge, rebase, or cherry-pick) has no unmerged paths, the result serves what both sides were trying to do, and the project's own checks pass on it. Clearing the markers is only part of the result. A conflict-free merge can still break the build when one side renamed or re-signed something the other side calls.

## Resolve from intent

Before you edit a file, read what each side meant: the commits on both sides (`git log --merge`, or the left-right log against `MERGE_HEAD`, `REBASE_HEAD`, or `CHERRY_PICK_HEAD`) and the code around the conflict. The diff text alone does not say which side owns a line. Each resolution serves both intents, or picks one for a reason you can state. When hunks compete, the side whose commits own the surrounding feature wins, and the rejected intent goes in the report. Match the surrounding style and keep the existing abstractions, because a merge is the wrong place to introduce new ones.

For a lockfile, settle the manifest and then regenerate the lockfile with the package manager. A hand-edited lockfile is one no install ever produced.

## When to ask

Resolve everything you can first. Then ask the user about the rest in one message, giving two or three candidate resolutions and the cost of each. Ask when:

- one side deleted a file the other side modified;
- the branches diverge on business logic;
- the code is security-sensitive (auth, crypto, permissions, sessions);
- several valid resolutions have real trade-offs;
- intent is still unclear after reading the commits and the code.

A question costs one turn. A wrong resolution in any of these cases ships silently. Ask before `--abort` as well when you have staged resolution work, since that work may be worth keeping on a branch.

## Verify

- `git ls-files -u` prints nothing, and no conflict markers remain in the files that were conflicted.
- When a lockfile changed, a frozen install passes (`pnpm install --frozen-lockfile`, `cargo build --locked`, `uv sync --frozen`, or the stack's equivalent).
- The project's typecheck, lint, and the tests covering touched modules pass. Find the commands in `package.json` scripts, the `Makefile`, the `justfile`, or the CI config. When a failure traces to a symbol one side renamed or a signature it changed, update every call site to the post-merge API and run the checks again.
- When a check fails, run it on each parent before the merge. A failure both parents already had is not one the merge introduced, so report it and leave it alone.

## Hand back

Stage the resolution and report each file: how you resolved it, any intent you rejected and why, and the checks you ran with their results. Leave the commit, `rebase --continue`, and the push to the caller.
