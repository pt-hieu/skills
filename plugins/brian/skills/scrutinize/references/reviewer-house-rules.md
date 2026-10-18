# Reviewer house rules (the file `## House Rules` points to)

These rules govern every reviewer agent invoked by `brian:scrutinize`. They keep noise and ungrounded claims out of the report; the orchestrator applies the same rules at synthesis, so a finding that breaks one is downgraded or dropped there instead of reaching the user.

## 1. Citation required
Every finding cites `file:line` with a quoted code snippet read from disk (NOT from the diff text). If the snippet does not literally appear at the cited line on disk, the orchestrator treats the finding as low-confidence at synthesis (citation enforcement). Missing snippet → low-confidence.

## 2. State confidence in plain words
Say how confident you are in each finding, and why, as plain prose in the finding body — not a tag. Make the basis explicit: you verified the claim by reading code, checking imports, or grepping patterns (high confidence); you have the diff plus one or two verified signals with a minor uncertainty noted (medium); or you are working mostly from the diff without broader verification (low). **Default to low confidence whenever the claim is not grounded in a cited file/line.** The Finding Anchor itself carries no confidence statement. A finding you describe as low-confidence is dropped at synthesis unless three or more cluster into one `(axis, file_dir)` theme.

## 3. Anti-cosmetic gate
This is the anti-cosmetic gate. Drop these — do not emit findings for any of them:
- Style, formatting, or anything a linter/formatter would enforce.
- Pre-existing acknowledged issues that the current diff does not change. Code this diff adds or changes is never pre-existing, even when it moves an older behavior.
- Speculation without disk evidence.
- "Could refactor" advisory without a concrete defect.

**Comment hygiene, tautological / change-detector tests, and rules written in the repo's `CODING_STANDARDS.md` are outside this gate.** A standard such as statement grouping reads as formatting, and the repo's owner wrote it down as binding. Both look like tooling's job and are not: a linter can check that a comment exists but not whether it says anything, and coverage tooling reports a tautology as covered lines — which is the harm, not an exemption. Never drop either as cosmetic.

## 4. Root-cause framing (security only)
State the consequence, not the symptom. Good: "under concurrent X, observer Y sees stale Z". Bad: "missing await". The reader must be able to predict the failure mode from the Claim line alone.

## 5. No LLM arithmetic
Counts, ratios, line-spans come from tool output (`grep -c`, `wc -l`, `git diff --stat`), never from the model's head. If a finding requires a count, run the tool and quote the output.

## 6. Conflict detection on same line
If two of your own findings overlap on the same `file:line`, pick one (higher severity wins) or treat both as low-confidence. Do not emit both.

## 7. Abstinence
If you cannot assess from disk, say so plainly in prose — state that you could not assess this axis and name what's missing — and move on. Do not invent filler. `NO FINDINGS` is clean and welcome — emit it when honest, and only for the files your coverage statement (Rule 9) says you read.

## 8. Axis routing constraints

One defect, one axis. These six rules say who owns what, so two reviewers never file the same finding under different names and no one assumes a sibling axis will cover it. They bind unconditionally: you cannot see which axes were dispatched, so never gate on whether another one ran.

- **Cleanness owns no structural-abstraction findings beyond the repo's written standards.** A genuinely missing abstraction (a shared layer that should exist but doesn't) is module-level structure, outside scrutinize's scope unless a rule in `CODING_STANDARDS.md` names it. Cleanness stays on the local shape of the changed lines; its reuse hunt may grep the whole repo to cite an existing helper or a duplicate, but the finding stays "use/deduplicate what exists", never "design a new abstraction".
- **A zero-tests diff forces a coverage finding.** When production code changed and no test changed, `review-tests` must name the highest-risk uncovered function as a test-coverage gap rather than emit `NO FINDINGS`.
- **Every test the diff touches gets the mutation check.** `review-tests` owns tautologies and change detectors and must report each one it finds, at a HIGH floor. No other axis reports them; `cleanness` would read the same test as local code shape and collide.
- **Every comment the diff touches gets the WHY check.** `review-cleanness` owns comment hygiene and must report it, grouped one finding per file, at a MEDIUM floor. No other axis reports it.
- **A check-then-act race across a persistence boundary belongs to `review-security`.** A read that decides whether a later, separate write is allowed (find the open tab, then insert into it) lets a concurrent caller slip a write past the check. `review-security` reports it with the attacker capability it gives; no other axis reports it.
- **The repo's `CODING_STANDARDS.md` belongs to `review-cleanness`.** It reports every rule in the file the diff breaks, grouped one finding per file and section, at a HIGH floor, apart from tautological or change-detector tests, which stay with `review-tests`. No other axis reports a finding whose only basis is that file.

## 9. Coverage

`## Diff Snapshot` names the snapshot directory, and `## Changed Files` lists the files assigned to you, one line each: status, the line count of the file's diff, its repo path, and the path of its own diff file. Read the per-file diff of every listed file before reviewing it. Read returns a large file in slices and says nothing about the rest, so compare the last line number a Read returned with the listed count, and read on with `offset` until you reach it. `full.diff` in the snapshot directory holds the whole diff, other reviewers' files included, for when you need a neighbor's change for context.

End your report with a coverage statement: either that you read every listed file's diff in full, or which files you did not read in full and why. A file that holds no code for your axis, such as a lockfile or an image, may be left out with that reason. The orchestrator turns this statement into the report's coverage line, and an axis with any other gap is reported as incomplete, so name every file you left out: a gap you leave unnamed reaches the caller as a clean review.

## 10. Leave the files as you found them

Edit, mutate, stash, and check out nothing in the repo, including to try a mutation. Other reviewers read the same files while you work, and in working-tree mode the diff is the user's uncommitted work, which `git checkout` and `git stash` destroy. When a finding rests on a mutation, name it exactly (the file, the line, and the change); the orchestrator runs it after every reviewer has returned.

## Verification step (run before returning)

Before returning your output:
1. Re-read each finding.
2. For every Claim line, trace it to the quoted snippet under Evidence.
3. Open the cited `file:line` on disk and confirm the snippet literally appears there.
4. Treat any finding whose snippet does NOT appear at the cited line as low-confidence, and say so in plain words.
5. Re-check Rule 6: collapse any same-line duplicates.

Nothing outside you can observe whether you actually re-read your findings before returning — this is self-enforced. It is your own last chance to catch a hallucinated citation before synthesis; nothing downstream will catch it if you skip it.
