---
name: scrutinize
description: "Use to review local code changes against Brian's house rules — code-cleanness (comments, reuse), security, tests, and the repo's own CODING_STANDARDS.md."
---

# Scrutinize

`brian:scrutinize` reviews a local diff with one reviewer subagent per axis (cleanness, security, tests), each in its own context, then synthesizes their findings into one report whose verdict line says whether every axis covered the whole diff. It dispatches through the Agent tool, which a main session and a regular subagent have and a workflow worker lacks.

The leading word is **coverage**: a review counts for the files its reviewers read, and the report says which those were.

## Args

- *(no args)*: working-tree mode, meaning staged, unstaged, and untracked changes.
- `--branch <name>`: the branch against its merge-base with `main`, `master`, or `origin/HEAD`.
- `--commit <sha>`: one commit.
- `--base <ref>`: `<ref>..HEAD`.
- `--axes=all`: every axis, whatever the triggers say.
- `--axes=<csv>`: the listed axes. The mandatory-new-file security rule still adds security.
- `--input <sha-ts>`: replay a prior snapshot, named by its directory under `/tmp/scrutinize/<flattened-repo-path>/`.

---

## Axis Registry

| axis | `subagent_type` (Agent tool) | always-on? | trigger |
|---|---|---|---|
| `cleanness` | `brian:review-cleanness` | yes | — |
| `security` | `brian:review-security` | no | the snapshot script's `security trigger` line is not `none` |
| `tests` | `brian:review-tests` | no | any production or test file changed, and on a zero-tests diff a home for tests exists ("Axes and groups") |

Every reviewer runs on `sonnet`.

---

## The result

One report, printed last, whose verdict line says whether every axis covered the whole diff. Nothing acts on a reviewer's return before the report is printed: no edit, no fix, no commit, no reply to the caller. A finding exists once it appears under the verdict line, after coverage, floors, and dedupe have run over every return; a fix started on the first return to arrive is a fix to a finding the report might drop or merge.

```
scrutinize | <repo_root> @ <short_sha> (<iso_ts>) | <mode and refs>
verdict:    <clean | findings | incomplete>
dispatched: <axis (trigger)>, ...
coverage:   <axis>: <full | partial | none> (<files read> of <files> files[; <gap in the reviewer's words>]); ...
suite:      <the suite outcome>
skipped:    <axis>: <reason>; ...      (omit when empty)
excluded:   <paths left out of every group>   (omit when empty)
snapshot:   <snapshot directory>
```

Then the findings, HIGH, then MEDIUM, then LOW themes, each card carrying the reviewer's Claim, Evidence, and Fix as written:

```
[<SEVERITY>] <file>:<line>  (<defect_class>; axes: <axes>)
  Claim:    <claim>
  Evidence: <file:line>
            ```<lang>
            <snippet>
            ```
  Fix:      <fix>
  Confidence: <the reviewer's stated confidence, in a few words>
```

The findings come HIGH, then MEDIUM, then LOW themes, each card carrying the reviewer's Claim, Evidence, and Fix as written. Rewording a card changes what the reviewer claimed and what the caller acts on, so a card quotes its reviewer. Your own view of a finding, a caller's filter applied to the list, and any refuted mutation go after the cards, under a line that marks them as yours.

When no finding renders, the line after the header reads `No findings.` on a `clean` verdict, and `No findings in the files reviewed; <axes> did not cover the whole diff.` on an `incomplete` one.

Three cases end the run with one line in place of a report:

- **Incompatible flags**, such as `--branch` with `--commit`: a one-line error.
- **An empty diff** (the snapshot script exits 3): there is nothing to review.
- **No Agent tool**, in your tool list or through `ToolSearch` with `select:Agent`: this message and nothing else, filled in.

  > scrutinize did not run: the Agent tool is not available here, so no reviewer was dispatched. The diff is saved at `<snapshot>`; run `brian:scrutinize --input <sha-ts>` from a session that has the Agent tool. Report this to your caller as a failed review.

  Reviewing the diff yourself is no substitute. One context holding three reviews misses what three separate reviewers catch, and its result would reach the caller as a scrutinize pass.

## The snapshot

Every reviewer reads the same snapshot, written by the bundled script, run as a single plain command with the mode and its argument:

```
"${CLAUDE_PLUGIN_ROOT}/skills/scrutinize/scripts/snapshot.sh" <working-tree | branch <name> | commit <sha> | base <ref> | replay <sha-ts>>
```

`${CLAUDE_PLUGIN_ROOT}` is the plugin's install directory. The script writes the snapshot directory under `/tmp`, outside the repo: `full.diff`, one diff per changed file under `files/`, and `index.tsv` with one line per file (status, diff line count, repo path, per-file diff path). It prunes old snapshots, and prints the facts the axes and the report header use: the snapshot path, file and line counts, the security trigger, and the zero-tests facts.

A hand-written snapshot drifts from the script's layout and breaks replay, so when the shell refuses or fails to run the script, report the refusal and stop.

A caller may pass prose in place of flags ("review f18c77f..HEAD, report only rule-named findings"). The range maps onto a mode, and the rest of the prose is caller context, which applies to the findings and stays out of reviewer prompts ("Reviewers" says why).

## Axes and groups

Every registry axis is either dispatched or skipped with a reason, and the header names both.

- **cleanness** always dispatches, unless an explicit `--axes=<csv>` leaves it out.
- **security** dispatches when the script's `security trigger` line names a reason, and that reason goes to the reviewer.
- **tests** dispatches when any file changed. On a zero-tests diff (the script prints `zero tests: true`), it dispatches only when the script prints `tests home: yes`; on `tests home: no`, the skip reason is `tests: <the script's reason>; pass --axes=tests to force`. A package with no tests and no test script means its owner chose to have none, and a diff review is the wrong place to overturn that choice.
- `--axes=all` dispatches everything, and `--axes=<csv>` dispatches the list plus a mandatory-new-file security trigger.

A reviewer reads every line of every file it is given (House Rule 9), so a large diff is split into groups of about 3,000 diff lines each, read from `index.tsv`: files from one directory stay together, and a single file over 3,000 lines gets a group of its own. A diff under 3,000 lines is one group. Lockfiles, and files the repo itself marks generated or vendored (`.gitattributes`, `CODING_STANDARDS.md`, or a generated-file banner at the top of the file), are left out of every group and listed as `excluded` in the header. Every dispatched axis reviews every group.

## Reviewers

One Agent call per (axis, group), all sent in a single message: `subagent_type` from the registry, `model: sonnet`, `run_in_background: true`. The report waits for every completion notification.

**The suite outcome.** A red test is a fact, and it reaches every reviewer before any of them argues a change is a pure refactor. The repo's test command comes from its manifests (a `test` script in `package.json`, `swift test` for `Package.swift`, `go test ./...`, `pytest`, `cargo test`, a `test` target in a `Makefile` or `justfile`). It runs once, with a five-minute timeout, when the reviewed tree is the checked-out one: working-tree mode, `--base`, or a `--branch` or `--commit` that names `HEAD`. The outcome is `<command>: passed`, `<command>: N failing` with each failing test's name and file, or `not run: <reason>`.

**The prompt.** Each reviewer's prompt is the following blocks, in this order, and nothing else but its axis hints:

```
## Output Contract

Every finding starts with a Finding Anchor on its own line:

  Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>

Name the defect class in plain words — a short phrase in your own words for the underlying defect (e.g. "missing validation — external input to a DB query"). Synthesis merges and renders by `defect_class`, so every anchor carries it.

After the anchor, the body is:

  Claim:    <one-sentence root-cause framing>
  Evidence: <repo-relative file:line>
            ```<lang>
            <quoted snippet from disk, ≤8 lines>
            ```
  Fix:      <concrete suggestion, or "—">

State your confidence and its basis in plain words in the Claim or a closing sentence: high when verified against cited code, low when it rests mostly on the diff.

If you have no findings, write `NO FINDINGS` on its own line. Either way, end with the coverage statement House Rule 9 describes.

## House Rules
<absolute path of ${CLAUDE_PLUGIN_ROOT}/skills/scrutinize/references/reviewer-house-rules.md>; read it in full before reviewing

## Repo Root
<repo_root>

## Diff Snapshot
<snapshot directory>

## Changed Files
<this group's lines from index.tsv, verbatim>

## Axis
<axis>

## Failing Tests
<the suite outcome, verbatim>
```

**Axis hints**, appended after the blocks:

- **cleanness**, when `$repo_root/CODING_STANDARDS.md` exists: `## Coding Standards` with its absolute path.
- **tests**: `## Zero Tests Flag` with `true` or `false` from the script, and `## Coding Standards` with its path when the file exists, so the fixes it proposes follow the repo's test rules.
- **security**: `## Security Trigger` with the reason its axis dispatched on.

The harness gives the reviewers the same CLAUDE.md files you see, so the prompt leaves project rules out.

Caller context stays out of these prompts: accepted risks, out-of-scope notes, focus lists, the implementer's account of the change, and a caller's filter. A reviewer told what not to report stops looking there, and that is how a committed passphrase and an unauthenticated write API passed review.

## From returns to findings

These rules turn the reviewers' returns into the report. They hold for every run, because a caller compares one report with the next.

- **Coverage.** Each axis is `full`, `partial`, or `none`, judged from its reviewers' coverage statements. `full` means its reviewers read every file in their groups, or left a file out because it holds no code for the axis (a lockfile, an image). `partial` means any other gap: a file skipped for size or time, a diff read in part, a reviewer that says it sampled. `none` means the reviewers abstained, refused for a missing block, or never returned. Each gap goes in the header in the reviewer's own words.
- **Severity.** Each Finding Anchor is parsed and tagged with its axis. Severity is judged from the prose, and is low when the claim does not cite a file and line or carries no Evidence snippet. These floors apply on top, and no prose can lower them:

  | Floor | Fires on |
  |---|---|
  | HIGH | a `review-cleanness` finding whose defect class names a coding-standard violation, because the repo's owner wrote the rule down as binding |
  | HIGH | a `review-tests` finding whose prose identifies a tautology or a change detector, because a test that can only pass hides the regression it claims to catch |
  | HIGH | a `review-tests` zero-tests finding, on a run whose Zero Tests Flag was `true`; on a `false` flag it is a coverage gap judged on its prose |
  | MEDIUM | a `review-cleanness` finding whose defect class names comment hygiene, because it is a house-rule prohibition |
  | HIGH | each failing test from the suite run, rendered as a finding of axis `suite` at the test file, line `cross` |

- **Refuted mutations.** A tautology or change-detector finding that names a mutation the test survives is checked by running that mutation, when the suite command exists and the reviewed tree is checked out. One finding at a time: copy the file to a backup, apply the mutation, run the one test, and restore the file from the backup, never with `git checkout` or `git stash`, which would destroy uncommitted work. A test that goes red under the named mutation refutes the finding; it is dropped, and the drop is stated below the report.
- **Duplicates.** A bare line `N` is the span `N-N`. Findings on the same file with overlapping spans merge, keeping the higher severity; at equal severity, both axes are kept.
- **LOW findings.** HIGH and MEDIUM render as cards. LOW findings group by (axis, directory): three or more render as one LOW theme, and smaller groups are dropped and counted.
- **Caller context.** When the caller marked a risk as accepted or out of scope, the finding stays in the report with the caller's note beside it; the caller decides what to do with it after reading.
- **Verdict.** `incomplete` when any dispatched axis is `partial` or `none`, whatever the finding count; otherwise `findings` when any finding renders; otherwise `clean`. `incomplete` is never a pass: it means part of the diff went unreviewed on some axis, and the header says which part.

## Verify

- The report is the last thing printed, and its verdict line is one of the three keywords.
- Every registry axis appears under `dispatched` or `skipped`, and every dispatched axis has a `coverage` entry naming files read of files given.
- Every file in `index.tsv` is in a group or under `excluded`.
- Every (axis, group) reviewer returned before the report was written, and every card quotes its reviewer.
- The working tree matches what it was before the run: every mutation check restored its file, and no finding was acted on.

## Contract Audit

When renaming or deleting a token this skill shares with its reviewers or callers (a prompt block name, `Finding Anchor`, `defect_class`, `NO FINDINGS`, a severity floor, the snapshot layout, or a verdict keyword), read `references/contract-audit.md` for every file that emits or consumes it, and change them in the same commit.
