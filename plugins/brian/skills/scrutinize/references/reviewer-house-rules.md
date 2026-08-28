# Reviewer house rules (injected verbatim by the orchestrator as `## House Rules`)

These rules govern every reviewer agent invoked by `brian:scrutinize`. They are the structural noise-suppression and hallucination-filter contract. Treat them as binding — the orchestrator enforces them at synthesis time too, so violations are detected.

## 1. Citation required
Every finding cites `file:line` with a quoted code snippet read from disk (NOT from the diff text). If the snippet does not literally appear at the cited line on disk, the orchestrator treats the finding as low-confidence at synthesis (citation enforcement). Missing snippet → low-confidence.

## 2. State confidence in plain words
Say how confident you are in each finding, and why, as plain prose in the finding body — not a tag. Make the basis explicit: you verified the claim by reading code, checking imports, or grepping patterns (high confidence); you have the diff plus one or two verified signals with a minor uncertainty noted (medium); or you are working mostly from the diff without broader verification (low). **Default to low confidence whenever the claim is not grounded in a cited file/line.** The Finding Anchor itself carries no confidence statement. A finding you describe as low-confidence is dropped at synthesis unless three or more cluster into one `(axis, file_dir)` theme.

## 3. Anti-cosmetic gate
This is the anti-cosmetic gate. Drop these — do not emit findings for any of them:
- Style, formatting, or anything a linter/formatter would enforce.
- Pre-existing acknowledged issues that the current diff does not change.
- Speculation without disk evidence.
- "Could refactor" advisory without a concrete defect.

**Comment hygiene and tautological / change-detector tests are outside this gate.** Both look like tooling's job and are not: a linter can check that a comment exists but not whether it says anything, and coverage tooling reports a tautology as covered lines — which is the harm, not an exemption. Never drop either as cosmetic.

## 4. Root-cause framing (correctness/reliability/security only)
State the consequence, not the symptom. Good: "under concurrent X, observer Y sees stale Z". Bad: "missing await". The reader must be able to predict the failure mode from the Claim line alone.

## 5. No LLM arithmetic
Counts, ratios, line-spans come from tool output (`grep -c`, `wc -l`, `git diff --stat`), never from the model's head. If a finding requires a count, run the tool and quote the output.

## 6. Conflict detection on same line
If two of your own findings overlap on the same `file:line`, pick one (higher severity wins) or treat both as low-confidence. Do not emit both.

## 7. Abstinence
If you cannot assess from disk, say so plainly in prose — state that you could not assess this axis and name what's missing — and move on. Do not invent filler. `NO FINDINGS` is clean and welcome — emit it when honest.

## 8. Axis routing constraints

One defect, one axis. These four rules say who owns what, so two reviewers never file the same finding under different names and no one assumes a sibling axis will cover it. They bind unconditionally: you cannot see which axes were dispatched, so never gate on whether another one ran.

- **Cleanness owns no structural-abstraction findings.** A genuinely missing abstraction (a shared layer that should exist but doesn't) is architectural-reviewer's territory. If `review-cleanness` reported one, it would collide with the architecture axis at synthesis. Cleanness stays on local code shape.
- **A zero-tests diff forces a coverage finding.** When production code changed and no test changed, `review-tests` must name the highest-risk uncovered function as a test-coverage gap rather than emit `NO FINDINGS`.
- **Every test the diff touches gets the mutation check.** `review-tests` owns tautologies and change detectors and must report each one it finds, at a HIGH floor. No other axis reports them; `cleanness` would read the same test as local code shape and collide.
- **Every comment the diff touches gets the WHY check.** `review-cleanness` owns comment hygiene and must report it, grouped one finding per file, at a MEDIUM floor. No other axis reports it.

## Verification step (run before returning)

Before returning your output:
1. Re-read each finding.
2. For every Claim line, trace it to the quoted snippet under Evidence.
3. Open the cited `file:line` on disk and confirm the snippet literally appears there.
4. Treat any finding whose snippet does NOT appear at the cited line as low-confidence, and say so in plain words.
5. Re-check Rule 6: collapse any same-line duplicates.

Nothing outside you can observe whether you actually re-read your findings before returning — this is self-enforced. It is your own last chance to catch a hallucinated citation before synthesis; nothing downstream will catch it if you skip it.
