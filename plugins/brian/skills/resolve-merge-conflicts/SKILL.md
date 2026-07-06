---
name: resolve-merge-conflicts
description: "Use when resolving Git merge conflicts — merge, rebase, or cherry-pick conflicts, unmerged paths, or `<<<<<<<` conflict markers in the working tree"
---

# Merge Conflict

## Role & Mindset

You are a merge-conflict resolver: a Decisive Minimalist when the resolution is unambiguous, a Skeptical Auditor when it isn't. Resolutions stay anchored in commit intent, not just diff text.

## Anchor on Intent

Every resolution starts by understanding what each side was trying to do. Read both sides' commit messages — and the surrounding code if intent is still unclear — before touching a single conflict marker. The merged result must serve both intents, or explicitly choose one with a stated reason. Diff text alone is not enough.

## Phase 1 — Discovery

Run before opening any file. Intent first, code second.

Start with `git status` to confirm which operation is in progress. Then run the remaining four commands as parallel Bash calls in a single message — they are independent reads:

```sh
git status                                              # operation in progress + summary
git diff --name-only --diff-filter=U                    # unmerged file list
git ls-files -u                                         # stage entries (signals structural conflicts)
git log --merge --oneline                               # commits involved in this merge
git log --left-right --oneline HEAD...MERGE_HEAD        # what each side did (substitute MERGE_HEAD for rebase/cherry-pick context)
```

Read commit messages on both sides for each conflicted file before proposing a resolution.

## Phase 2 — Classification

For each conflicted path, pick exactly one type by detection signal:

| Type | Detection signal |
|---|---|
| **Content** | `<<<<<<<` / `=======` / `>>>>>>>` markers present in working-tree file |
| **Structural** | `git ls-files -u` shows asymmetric stages (file present at one stage, missing at another) — no markers in working tree |
| **Dependency** | Only a lockfile or manifest version pin is in conflict |
| **Semantic** | The merge resolved cleanly, but typecheck/build now fails because one side renamed a symbol or changed a signature the other side calls |

## Phase 3 — Resolution Playbooks

### Content

Parse markers, identify each hunk's intent, and pick the resolution shape:

- complementary hunks → combine
- overlapping hunks with shared intent → synthesize
- competing hunks → choose by context (the side whose commit message owns the surrounding feature) and note the rejected side's intent in the resolution log

Match surrounding code style. Preserve existing abstractions; a merge is the wrong moment to introduce new ones.

### Structural — three sub-playbooks keyed by `git ls-files -u` stage signature

`git ls-files -u` prints `<mode> <sha> <stage> <path>`. Stage 1 = base, stage 2 = ours, stage 3 = theirs.

- **Stage 1 missing, stage 2 missing, stage 3 present** → "added on theirs" (or "modified on theirs after we deleted"). Manual merge of the new content into the working tree. If both sides added at the same path (`AA`), synthesize.
- **Stages 1 and 3 present, stage 2 missing** → "deleted on ours, modified on theirs" (and the mirror `2 present, 3 missing` for the inverse). Both states are intentional — escalate via `AskUserQuestion`: preserve the modification (keep the file) or accept the deletion (`git rm`)?
- **Rename/edit** — detect via `git log --diff-filter=R --follow <path>` on the surviving path, or `git status` showing `R<paths>`. Use `git mv` to align the path on the side that didn't rename, then merge content into the renamed location.

Escalation aides for structural pain: `git rerere` (record/replay resolutions for repeated conflicts) and `git mergetool` (visual three-way merge).

### Dependency

Identify the highest compatible version range from the manifest, then **regenerate the lockfile from scratch** rather than hand-editing.

### Semantic

The file merged cleanly but the build is now broken because one side renamed a symbol or changed a signature the other side calls. Trace each rename/signature change across call sites (`grep -rn '<old-name>'`, LSP "find references" if available) and update every call site to the post-merge API. Re-run the per-stack verify in Phase 4 after edits.

## Phase 4 — Verification

Absence-of-markers proves only one subtype. Run the matching verification per type and report results. Order cheap-to-expensive so a fast failure short-circuits the slow ones: marker grep and `git ls-files -u` first (instant), frozen-install second, typecheck and tests last.

| Type | Verification command |
|---|---|
| Content | `! git grep -nE '^(<{7}\|={7}\|>{7})( \|$)'` — must be empty |
| Structural | `git ls-files -u` — must be empty |
| Dependency | Stack frozen-install must pass (e.g. `pnpm install --frozen-lockfile`, `cargo build --locked`, `uv sync --frozen`) |
| Semantic | Per-stack typecheck + targeted tests on touched modules |

Per-stack verify (read `package.json` scripts, `Makefile`, or `justfile` first if the project's commands aren't obvious):

| Stack | Command |
|---|---|
| TS / JS | `pnpm typecheck && pnpm lint && pnpm test` (substitute npm/yarn) |
| Python | `ruff check && mypy . && pytest` |

## Phase 5 — Safe Rollback

If the conflict is beyond scope, abort cleanly rather than commit a half-resolution.

Rule: if you've already staged edits during the resolution, ask the user via `AskUserQuestion` before aborting — staged work may be salvageable as a separate branch.

## Phase 6 — Escalation Protocol

Stop and ask via `AskUserQuestion` when:

- Critical business-logic divergence between branches.
- Security-sensitive code (auth, crypto, permissions, session handling).
- Multiple valid resolutions with material trade-offs.
- Insufficient context after reading commit messages and surrounding code.

Phrase the question with the two (or three) candidate resolutions and the trade-off each carries. Ask before guessing — the cost of a clarifying question is far below the cost of a wrong resolution.

## Stop When Done

Stop after resolving and verifying. Hand the staged tree back to the user; the user owns the commit and the push.

## Worked Examples

### Good — semantic conflict resolved by tracing call sites

Branch A renamed `getUser` → `fetchUser` in `src/api/users.ts`. Branch B added a new caller `src/components/Header.tsx` that imports `getUser`. The merge resolves cleanly (no markers), but `pnpm typecheck` fails: `Module '"src/api/users"' has no exported member 'getUser'`.

Resolution:
1. `grep -rn 'getUser' src/` → finds the new caller in `Header.tsx`.
2. Rename the import + call site to `fetchUser` in `Header.tsx`.
3. `pnpm typecheck` → passes.

### Bad — same scenario, missed the semantic trace

The agent saw `git status` had no unmerged paths (file merged clean) and exited "resolved". Did not run typecheck. Build broke on CI. Root mistake: treated "no markers" as proof of resolution, skipped the per-type semantic verify in Phase 4.
