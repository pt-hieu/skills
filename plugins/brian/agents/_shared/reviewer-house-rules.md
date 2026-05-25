# Reviewer house rules (injected verbatim by the orchestrator as `## House Rules`)

These rules govern every reviewer agent invoked by `brian:scrutinize`. They are the structural noise-suppression and hallucination-filter contract. Treat them as binding — the orchestrator enforces them at synthesis time too, so violations are detected.

## 1. Citation required
Every finding cites `file:line` with a quoted code snippet read from disk (NOT from the diff text). If the snippet does not literally appear at the cited line on disk, the finding is auto-downgraded to `[LOW]` at synthesis. Missing snippet → auto-downgrade to `[LOW]`.

## 2. Severity tags
Append the confidence tag at the end of the finding body, on its own line: `Confidence: [HIGH]` or `[MEDIUM]` or `[LOW]`. The Finding Anchor itself does NOT carry the tag. `[LOW]` findings are dropped at synthesis unless three or more cluster into one `(axis, file_dir)` theme.

## 3. Anti-cosmetic gate
This is the anti-cosmetic gate. Drop these — do not emit findings for any of them:
- Style, formatting, or anything a linter/formatter would enforce.
- Pre-existing acknowledged issues that the current diff does not change.
- Speculation without disk evidence.
- "Could refactor" advisory without a concrete defect.

## 4. Root-cause framing (correctness/reliability/security only)
State the consequence, not the symptom. Good: "under concurrent X, observer Y sees stale Z". Bad: "missing await". The reader must be able to predict the failure mode from the Claim line alone.

## 5. No LLM arithmetic
Counts, ratios, line-spans come from tool output (`grep -c`, `wc -l`, `git diff --stat`), never from the model's head. If a finding requires a count, run the tool and quote the output.

## 6. Conflict detection on same line
If two of your own findings overlap on the same `file:line`, pick one (higher severity wins) or downgrade both to `[LOW]`. Do not emit both.

## 7. Abstinence
If you cannot assess from disk, output a single line: `INSUFFICIENT CONTEXT — <what's missing>` and move on. Do not invent filler. `NO FINDINGS` is clean and welcome — emit it when honest.

## Verification step (run before returning)

Before returning your output:
1. Re-read each finding.
2. For every Claim line, trace it to the quoted snippet under Evidence.
3. Open the cited `file:line` on disk and confirm the snippet literally appears there.
4. Downgrade any finding whose snippet does NOT appear at the cited line to `Confidence: [LOW]`.
5. Re-check Rule 6: collapse any same-line duplicates.

This step is the structural hallucination filter. Skipping it is a contract violation.
