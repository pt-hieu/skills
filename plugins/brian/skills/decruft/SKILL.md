---
name: decruft
description: Use when removing outdated instructions from an existing prompt surface.
---

Decruft removes instructions that were written for an older model and now degrade the current one, editing the files in place. It is not a shortening pass: the harm comes from specific dated instructions, not from length, and a surface with none of them is left untouched.

**Cruft** is the leading word. A line is cruft only when it matches a named pattern in [`references/patterns.md`](references/patterns.md) *and* you can state why the target model no longer needs it. A line that fails either test is context, and context is never cruft. Indiscriminate deletion is the one way this skill makes things worse, so the keep list below binds as strongly as the pattern tables.

## Ground rules

- **Edit in place.** Apply every high- and medium-confidence finding directly to the file, without pausing for confirmation. The closing report is the record of what changed.
- **Never commit.** Do not run `git commit`, `git add`, or `git stash`. Leave every edit unstaged in the working tree so the user reviews it with `git diff` on their own schedule.
- **Low confidence is report-only.** Idiom-dating with no documented pattern behind it, and anything outside scope, goes in the final report and is not edited.
- **Rewrite before deleting.** When an instruction has a live purpose, re-express it plainly (a shouted `NEVER delete without checking` becomes `Look before you delete`). Bare deletion is for lines with no live purpose.
- **A removal is complete only when its references go too.** Grep the project for the removed text, symbol, and any retired model ID before finishing: tests asserting the old behaviour, helper functions that only served the old mechanism, docs, READMEs, and rule files. A prompt fixed while its smoke test still asserts the old shape is a broken app.

## Steps

### 1. Fix scope and target model

Resolve both from the request and the repository, never by asking. Scope is whatever the request names (file, directory, list). With no name, scope is the working directory's whole prompt surface as found in step 2.

Target model resolves in this order: the model the request names; else the destination of a migration the repository documents (vendor notes, TODOs); else the newest model the repository's code or docs point at; else the current flagship of the provider the code calls (for Anthropic: Claude Fable 5.1). State both assumptions at the top of the final report so the user can re-run narrower.

Done when: scope and target model are written down and every later judgement is relative to that model.

### 2. Inventory the prompt surface

Find everything that reaches the model as text, not just the file called "prompt": system prompts and the code that assembles them; tool definitions (description and parameter descriptions); skill and rule files; request-building code (model IDs, thinking config, sampling parameters, stop sequences, prefill construction, retry loops, beta headers, `tool_choice`); few-shot blocks and embedded examples wherever they live.

Done when: the inventory is listed and nothing in scope that reaches the model is missing from it.

### 3. Establish provenance

Where git history exists, `git blame` the prompt files. For every emphatic or prohibitive line ask: which failure, on which model, did this prevent, and does that failure still reproduce on the target model? Lines added as mitigations for a retired model are presumptive removals. A line nobody can justify is suspect by default.

Idioms date text without history too: `<scratchpad>` / `<thinking>` tag instructions, "think step by step", assistant-turn prefills, quotes-first extraction scaffolds, ROLE → CONTEXT → RULES → EXAMPLES boilerplate. Idiom-dating alone is low confidence; it becomes medium or high only when paired with a target-model reason or a blame line tying it to a retired model's era.

Done when: every emphatic, prohibitive, or scaffold-shaped line has a provenance note (model, era, or "unknown").

### 4. Classify every line

Ask one question per instruction: could the model already know this?

- **Keep** what only the author knows: audience and product, environment facts, the quality bar, tool contracts and mechanics, genuinely hard judgement calls, and the reasons behind constraints.
- **Candidate** for removal: restatements of trained defaults ("be accurate and helpful"), behaviour the model does unprompted (thoroughness, planning, tool use), workarounds for failures the target model no longer has.

A second cut: is the line a constraint on behaviour (test it for removal) or context the model cannot get elsewhere (usually keep)? This is what stops the pass from becoming a length contest, because a naive shortening deletes exactly the highest-value words.

Done when: every line in the inventory is classified keep or candidate.

### 5. Scan the pattern groups and edit

Read [`references/patterns.md`](references/patterns.md) and work through its four groups. Run the greppable signals over the inventory rather than eyeballing. For each candidate that matches a documented row with a target-model reason, apply the row's fix now: remove, rewrite (with the replacement), move (to the place named), replace with the API feature, or add (under-described tool contracts get *more* text).

A documented-pattern match is edited even when it seems minor, reads as a soft nudge, or "measurably helps" on the old model. Those are reasons the user may revert a hunk, not reasons to withhold the edit.

Done when: every high- and medium-confidence finding is edited in the file, one finding per logical edit so `git diff` attributes each change to one reason.

### 6. Close out references and verify

- Grep the wider project for the exact removed text and any retired model ID: classifiers, tests, log parsers, and docs sometimes match on prompt strings. Fix or remove each hit.
- For request-construction changes (prefill, stop-sequence scaffolding, forced `tool_choice`, sampling fossils), confirm no code path can still emit the dated shape: every call site, the parser and retry helpers that served it, and the tests that asserted it.
- If the project has an eval suite or tests that exercise the prompt, run them and report the result verbatim. Asking the model whether it needs an instruction is not a measurement.
- If a cut regresses, re-add the instruction in its minimal form. Do not restore the verbose original.

Done when: `git grep` for removed symbols and old model IDs returns nothing unintended, and any available tests have been run with their output recorded.

### 7. Report

Print, in this order:

1. Assumed scope and target model.
2. Counts of edits per pattern group, and the two or three highest-impact changes in prose.
3. One entry per applied edit: `file:line`, the text removed or replaced, the pattern row, why it is obsolete for the target model, confidence (high / medium).
4. Report-only items: low-confidence idiom-dating and out-of-scope observations, each with its reason for not being edited.
5. Reference clean-up done (tests rewritten, helpers deleted, model IDs updated) and the test / eval output if any ran.
6. A reminder that nothing was committed, with `git diff --stat`.

If the surface is clean, say so and change nothing. An empty diff is a valid outcome and beats a manufactured one.

## What not to touch — the keep list

These stay even when a grep matches:

- **Context.** Audience, product, environment facts, quality bar, constraints, and their reasons. Too-short prompts produce generic output because the model fills gaps with safe defaults.
- **Length by itself.** Never justify a deletion by character count.
- **Exact scripts for fragile operations.** Where exactly one sequence is safe (destructive commands, auth flows, compliance steps), low-freedom prescriptive text is correct.
- **Tool contract detail**, which often needs to grow: parameter semantics, limits, failure modes, what the tool does not return. Remove steering and examples from descriptions, not contract.
- **Prohibitions against failures that still reproduce** on the target model in this context. Pattern-matching "prohibition" is not a reason.
- **Trigger and routing text** (a skill's frontmatter description, a trigger block) may carry calibrated urgency because skills under-trigger. Flag shouting in bodies, not in triggers.
- **Format-pinning examples** on genuinely format-sensitive outputs, labelled illustrative.
- **Working redundancy.** The same contract in two files, or content you would merely organise differently, is a refactoring preference, not cruft. Consolidate only when the duplicates disagree.
- **A one-line role statement.** Flag identity text only when it is the sole context the prompt gives.
- **A single end-of-prompt recap** of the key constraints. The anti-pattern is scattered duplication, not deliberate recap.
- **Re-baselining that adds text.** Fitting a prompt to a new model sometimes means adding guidance for that model's failure modes (see the Fable 5.1 notes at the end of the patterns file). The job is fit, in both directions.

## It's working if

- Every edit in `git diff` traces to a named row in the patterns file and a target-model reason in the report.
- The report lists report-only items separately from applied edits, and low-confidence items appear only there.
- `git status` shows modified, unstaged files and no new commit.
- A clean surface produced an empty diff and a report saying so.
