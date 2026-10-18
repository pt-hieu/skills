---
name: scrutinize
description: "Use to review local code changes against Brian's house rules — code-cleanness (comments, reuse), security, tests, and the repo's own CODING_STANDARDS.md."
---

# Scrutinize

`brian:scrutinize` reviews a local diff with one reviewer subagent per axis (cleanness, security, tests), each in its own context, then synthesizes their findings into one report whose verdict line says whether every axis covered the whole diff. It needs the Agent tool, so it runs from a main session or from a subagent that has one; a workflow worker has none.

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
| `tests` | `brian:review-tests` | no | any production or test file changed, and on a zero-tests diff a home for tests exists (Step C) |

Every reviewer runs on `sonnet`. Steps C through F refer to this table and enumerate no axes of their own.

---

## Step A. Parse args

Map the invocation onto a mode (`working-tree`, `branch`, `commit`, `base`, or `replay`) and an axis override. Reject incompatible flags, such as `--branch` with `--commit`, with a one-line error.

A caller may pass prose instead of flags ("review f18c77f..HEAD, report only rule-named findings"). Map the range onto a mode and keep the rest of the prose for Step E: a caller's filter decides what it does with the report, and it never reaches a reviewer.

## Step B. Snapshot the diff

Run the bundled script as a single plain command, with the mode and its argument:

```
"${CLAUDE_PLUGIN_ROOT}/skills/scrutinize/scripts/snapshot.sh" <working-tree | branch <name> | commit <sha> | base <ref> | replay <sha-ts>>
```

`${CLAUDE_PLUGIN_ROOT}` is the plugin's install directory. The script writes the snapshot directory under `/tmp`, outside the repo: `full.diff`, one diff per changed file under `files/`, and `index.tsv` with one line per file (status, diff line count, repo path, per-file diff path). It prunes old snapshots, and prints the facts Steps C and F use: the snapshot path, file and line counts, the security trigger, and the zero-tests facts. Exit 3 means the diff is empty: report that there is nothing to review and stop.

The script is the only snapshot path, because a hand-written equivalent drifts from it and loses replay. When the shell refuses or fails to run it, report the refusal and stop.

## Step C. Decide the axes

Produce `dispatched[]` and `skipped[{axis, reason}]`. Every registry axis ends in exactly one of the two.

- **cleanness** always dispatches, unless an explicit `--axes=<csv>` leaves it out.
- **security** dispatches when the script's `security trigger` line names a reason. Record that reason; Step D.3 passes it on.
- **tests** dispatches when any file changed. On a zero-tests diff (the script prints `zero tests: true`), it dispatches only when the script prints `tests home: yes`; on `tests home: no`, record `tests: <the script's reason>; pass --axes=tests to force` in `skipped[]`. A package with no tests and no test script means its owner chose to have none, and a diff review is the wrong place to overturn that choice.
- `--axes=all` dispatches everything, and `--axes=<csv>` dispatches the list plus a mandatory-new-file security trigger.

**Coding standards.** When `$repo_root/CODING_STANDARDS.md` exists, record its absolute path for Step D.3.

**Groups.** Read `index.tsv`. A reviewer reads every line of every file it is given (House Rule 9), so a large diff is split into groups of about 3,000 diff lines each: keep files from one directory together, and give a single file over 3,000 lines a group of its own. Leave out lockfiles, and files the repo itself marks generated or vendored (`.gitattributes`, `CODING_STANDARDS.md`, or a generated-file banner at the top of the file); list them as `excluded` for the header. A diff under 3,000 lines is one group. Every dispatched axis reviews every group.

## Step D. Dispatch

### D.0 The Agent tool

Check that the Agent tool is available, in your tool list or through `ToolSearch` with `select:Agent`. When it is not, stop with this message and nothing else, filled in:

> scrutinize did not run: the Agent tool is not available here, so no reviewer was dispatched. The diff is saved at `<snapshot>`; run `brian:scrutinize --input <sha-ts>` from a session that has the Agent tool. Report this to your caller as a failed review.

No reviewing the diff yourself in its place. One context holding three reviews misses what three separate reviewers catch, and its result would reach the caller as a scrutinize pass.

### D.1 Run the suite

Find the repo's test command from its manifests (a `test` script in `package.json`, `swift test` for `Package.swift`, `go test ./...`, `pytest`, `cargo test`, a `test` target in a `Makefile` or `justfile`). Run it once, with a five-minute timeout, when the reviewed tree is the checked-out one: working-tree mode, `--base`, or a `--branch` or `--commit` that names `HEAD`. Record the outcome as `<command>: passed`, `<command>: N failing` with each failing test's name and file, or `not run: <reason>`. A red test is a fact, and it reaches every reviewer before any of them argues a change is a pure refactor.

### D.2 The reviewer prompt

Each reviewer's prompt is the following blocks, in this order, and nothing else:

```
## Output Contract

Every finding starts with a Finding Anchor on its own line:

  Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>

Name the defect class in plain words — a short phrase for the underlying defect (e.g. "missing validation — external input to a DB query"), not a label from a fixed list. Synthesis merges and renders by `defect_class`, so every anchor carries it.

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
<the D.1 suite outcome, verbatim>
```

followed by the axis hints in D.3.

Caller context stays out of these prompts: accepted risks, out-of-scope notes, focus lists, the implementer's account of the change, and a caller's filter. A reviewer told what not to report stops looking there, and that is how a committed passphrase and an unauthenticated write API passed review. Step E is where caller context applies.

### D.3 Axis hints

- **cleanness**, when `CODING_STANDARDS.md` exists: `## Coding Standards` with its absolute path.
- **tests**: `## Zero Tests Flag` with `true` or `false` from the script, and `## Coding Standards` with its path when the file exists, so the fixes it proposes follow the repo's test rules.
- **security**: `## Security Trigger` with the Step C reason.

The reviewers are not Explore-type, so the harness already gives them the CLAUDE.md files the orchestrator sees, and a project-rules block would duplicate them.

### D.4 Dispatch in parallel

Send one Agent call per (axis, group) in a single message: `subagent_type` from the registry, `model: sonnet`, `run_in_background: true`, and the D.2 prompt. Then wait for every completion notification.

A reviewer's return is input to Step E. Nothing acts on it: no edit, no fix, no commit, no reply to the caller, until the Step F report is printed. A finding exists once it appears under the verdict line, after dedupe, floors, and coverage have run over every return; a fix started on the first return to arrive is a fix to a finding the report might drop or merge.

## Step E. Synthesize

When every reviewer has returned:

1. **Coverage first.** Read each return's coverage statement and judge each axis `full`, `partial`, or `none`. `full` means its reviewers read every file in their groups, or left a file out because it holds no code for the axis (a lockfile, an image). `partial` means any other gap: a file skipped for size or time, a diff read in part, a reviewer that says it sampled. `none` means the reviewers abstained, refused for a missing block, or never returned. Keep each gap in the reviewer's own words; it goes in the header.
2. **Parse Finding Anchors.** Tag each finding with its axis. Judge severity from the prose, defaulting to low when the claim does not cite a file and line. Then apply the floors, which no prose can lower:

   | Floor | Fires on |
   |---|---|
   | HIGH | a `review-cleanness` finding whose defect class names a coding-standard violation, because the repo's owner wrote the rule down as binding |
   | HIGH | a `review-tests` finding whose prose identifies a tautology or a change detector, because a test that can only pass hides the regression it claims to catch |
   | HIGH | a `review-tests` zero-tests finding, on a run whose Zero Tests Flag was `true`; on a `false` flag it is a coverage gap judged on its prose |
   | MEDIUM | a `review-cleanness` finding whose defect class names comment hygiene, because it is a house-rule prohibition |
   | HIGH | each failing test from the D.1 suite run, rendered as a finding of axis `suite` at the test file, line `cross` |

3. **Check the mutation behind a tautology floor.** When a tautology or change-detector finding names a mutation the test survives, the suite command exists, and the reviewed tree is checked out, run that mutation yourself, one finding at a time: copy the file to a backup, apply the mutation, run the one test, and restore the file from the backup, never with `git checkout` or `git stash`, which would destroy uncommitted work. A test that goes red under the named mutation refutes the finding; drop it and say so below the report.
4. **Normalize and dedupe.** A bare line `N` becomes `N-N`. Findings on the same file with overlapping ranges merge, keeping the higher severity; at equal severity, keep both axes.
5. **Severity gate.** HIGH and MEDIUM pass through. LOW findings group by (axis, directory): three or more render as one LOW theme, and smaller groups are dropped and counted. A finding with no Evidence snippet is LOW.
6. **Caller context.** When the caller marked a risk as accepted or out of scope, the finding stays in the report with the caller's note beside it; the caller decides what to do with it after reading.
7. **Verdict.** `incomplete` when any dispatched axis is `partial` or `none`, whatever the finding count; otherwise `findings` when any finding renders; otherwise `clean`. `incomplete` is never a pass: it means part of the diff went unreviewed on some axis, and the header says which part.

## Step F. Report

The report is the last thing the skill prints, and the run is done when it is printed with its verdict line. Fixing findings, committing, and answering the caller come after it.

```
scrutinize | <repo_root> @ <short_sha> (<iso_ts>) | <mode and refs>
verdict:    <clean | findings | incomplete>
dispatched: <axis (trigger)>, ...
coverage:   <axis>: <full | partial | none> (<files read> of <files> files[; <gap in the reviewer's words>]); ...
suite:      <the D.1 suite outcome>
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

Rewording a card changes what the reviewer claimed and what the caller acts on, so a card quotes its reviewer. Your own view of a finding, a caller's filter applied to the list, and any refuted mutation go after the cards, under a line that marks them as yours.

When no finding renders, the line after the header reads `No findings.` on a `clean` verdict, and `No findings in the files reviewed; <axes> did not cover the whole diff.` on an `incomplete` one.

## Contract Audit

When renaming or deleting a token this skill shares with its reviewers or callers (a prompt block name, `Finding Anchor`, `defect_class`, `NO FINDINGS`, a severity floor, the snapshot layout, or a verdict keyword), read `references/contract-audit.md` for every file that emits or consumes it, and change them in the same commit.
