---
name: scrutinize
description: "Use to review local code changes against Brian's house rules — correctness, reliability, security, tests, architecture, spec, and code-cleanness."
---

# Scrutinize

## What it does
Reviews a local diff by axis (correctness, cleanness, security, tests, architecture, spec) with parallel reviewer subagents instead of one generalist pass, then synthesizes their findings under Brian's house rules into a severity-ordered list in chat. The diff is also snapshotted under a per-repo directory in `/tmp` (outside the repo) for replay.

## Args
- *(no args)* — working-tree mode: stages + unstaged + untracked files.
- `--branch <name>` — diff a branch against its merge-base with `main`/`master`/`origin/HEAD`.
- `--commit <sha>` — review a single commit.
- `--base <ref>` — diff `<ref>..HEAD`.
- `--axes=all` — force every axis (override smart-dispatch).
- `--axes=<csv>` — force a specific axis set (always-on axes still run).
- `--spec <path>` — explicit spec/PRD file for the spec axis to check the diff against.
- `--input <sha-ts>` — replay against a prior cached snapshot (see Output for the path).

## Output
- Diff snapshot: `/tmp/scrutinize/<flattened-repo-path>/<sha>-<UTC-ISO>.diff` — lives outside the repo (no `.gitignore` entry needed); used by `--input <sha-ts>` to replay against the cached diff.

---

`brian:scrutinize` dispatches axis-specialized reviewer subagents in parallel against a local diff, synthesizes findings under Brian's house rules, and prints a severity-ordered findings list to chat. Chat output is the canonical and sole output mode; the diff is snapshotted to disk under a per-repo directory in `/tmp` to support `--input <sha-ts>` replay. The snapshot lives outside the repo root so it never pollutes the working tree or needs a `.gitignore` entry.

The orchestrator owns the I/O contract. Reviewer agents narrate the contract in their Input Contract sections — they do not own the Finding Anchor format, the defect-class wording, or the house rules. The orchestrator Read-injects the shared blocks at invocation time.

---

## Axis Registry (single source of truth)

| axis | `subagent_type` (Agent tool) | agent file | always-on? | trigger (one-line) | default model |
|---|---|---|---|---|---|
| `correctness-reliability` | `brian:review-correctness-reliability` | `review-correctness-reliability.md` | yes | — | sonnet |
| `cleanness` | `brian:review-cleanness` | `review-cleanness.md` | yes (downgradable on tiny diffs) | — | sonnet |
| `security` | `brian:review-security` | `review-security.md` | no | path/code regex OR new-file under security-trigger dir (mandatory) | sonnet |
| `tests` | `brian:review-tests` | `review-tests.md` | no | production-code OR test file in diff | sonnet |
| `architecture` | `brian:architectural-reviewer` | `architectural-reviewer.md` (REUSED) | no | new file / public-export change / module-boundary path | sonnet |
| `spec` | `brian:review-spec` | `review-spec.md` | no | spec source resolvable (Jira key in branch/commit messages, `--spec <path>`, or PRD file under `docs/`\|`specs/`\|`.scratch/`) | sonnet |

Steps C, D, E, F all reference this table. This table is the only place axes are enumerated in this file — everywhere else refers back to it.

**Dispatch invariant**: when emitting an `Agent` tool call for an axis, the `subagent_type` argument comes from the second column above and ONLY from that column (note the `brian:` plugin prefix — the harness registers plugin agents under it) — never substitute `brian:architectural-reviewer` (or any other value) as a default. If the orchestrator finds itself emitting two Agent calls with the same `subagent_type`, that is a bug: re-read this table.

---

## Step A. Parse args

Extract from the user's `/scrutinize` invocation:

- `mode ∈ {working-tree, branch, commit, base}` — driven by which flag is present (default: `working-tree`).
- `axes_override ∈ {all, <comma-list>, default}` — from `--axes=...`.
- `replay_input ∈ {<sha-ts> | none}` — from `--input <sha-ts>`.
- `spec_source ∈ {<path> | none}` — from `--spec <path>` (explicit spec file to check the diff against).

Reject incompatible combinations (e.g. `--branch` and `--commit` together) with a one-line error and exit non-zero.

---

## Step B. Resolve diff base and gather diff

```
repo_root=$(git rev-parse --show-toplevel)
scrutinize_dir="/tmp/scrutinize/$(printf '%s' "$repo_root" | sed 's#^/##; s#/#_#g')"
mkdir -p "$scrutinize_dir"
```

`scrutinize_dir` is a per-repo subdirectory under `/tmp` (the repo path is flattened into the dir name so distinct repos and worktrees never collide). All snapshot paths below resolve under `$scrutinize_dir`, never inside the repo.

### B.1 Compute diff_text and diff_files

- **working-tree mode**: if `git rev-parse --verify HEAD` succeeds:
  ```
  diff_text = $(git diff HEAD)
  ```
  Else (fresh repo, no commits):
  ```
  diff_text = $(git diff 4b825dc642cb6eb9a060e54bf8d69288fbee4904)   # the empty-tree SHA
  ```
  In both branches, append synthesized fully-added diffs for untracked files:
  ```
  git ls-files --others --exclude-standard
  ```
  For each path, `git diff --no-index /dev/null <path>` to synthesize.

- **branch mode**: resolve `<main-fallback>` by trying `main` → `master` → `origin/HEAD`. If none resolve, exit with a clear error. Then:
  ```
  diff_text = $(git diff $(git merge-base <main-fallback> <name>)..<name>)
  ```

- **commit mode**: `diff_text = $(git show <sha>)`.

- **base mode**: `diff_text = $(git diff <ref>..HEAD)`.

### B.2 Identify changed file paths and statuses

```
diff_files = $(git diff --name-status <base>..<head>)   # status + path; same base+head as B.1
```

For working-tree mode, also include untracked files (status `A`).

### B.3 Snapshot the diff

```
short_sha=$(git rev-parse --short HEAD 2>/dev/null || echo nohead)
iso_ts=$(date -u +%Y%m%dT%H%M%SZ)
snapshot="$scrutinize_dir/${short_sha}-${iso_ts}.diff"
printf '%s' "$diff_text" > "$snapshot"
```

### B.4 / B.5 — Retention prune and replay mode

Retention prune (B.4, run at end of Step F) and replay mode (B.5, taken only when `--input <sha-ts>` is set) are on-demand branches. When `replay_input` is set, or when running the end-of-run prune, read `references/snapshot-replay-retention.md` and follow it.

---

## Step C. Smart-dispatch

Produces the triple `(dispatched_axes[], skipped[{axis, reason}], tier)`.

### C.1 Always-on

`correctness-reliability` and `cleanness` are always dispatched unless overridden by `--axes=<csv>` (in which case the explicit list wins, augmented by anything matching mandatory triggers below).

### C.2 Tiny-diff tier

Compute:
```
total_lines = $(printf '%s\n' "$diff_text" | grep -cE '^[+-][^+-]')
total_files = $(printf '%s\n' "$diff_files" | wc -l)
tiny_diff_flag = (total_lines < 10 AND total_files < 2)
```

If `tiny_diff_flag`:
- Drop `cleanness` from always-on (record reason `tiny diff: <N> lines across <M> files`).
- Set `tier = narrow`.

If not tiny: `tier = full`.

Every axis runs on the Axis Registry's default-model column (`sonnet`); the tier controls axis breadth, not model choice.

### C.3 Security trigger

Dispatch `security` when a changed-file path, an added code line, or a mandatory new-file under a security/module-boundary directory matches the trigger catalog. When evaluating the security trigger, read `references/security-triggers.md` for the full path regex, code-pattern regexes, and the Mandatory-Security rule, and record the trigger reason (path / code-pattern / mandatory-new-file) in `axes_dispatched[]` metadata.

### C.4 Tests trigger

Dispatch `tests` if at least one production-code file **or** at least one test file is in the diff. Test-only diffs dispatch too: a diff that touches nothing but tests is exactly where a tautological or change-detector test enters the codebase with no production change to draw a reviewer's eye. A file is production-code if its path does NOT match any of:
```
^(test|tests|spec|specs|__tests__)/
\.(test|spec)\.(ts|tsx|js|jsx|py|go|rs|java|rb)$
_test\.(go|py)$
_spec\.rb$
```

Compute `zero_tests_flag = (production_files >= 1 AND test_files == 0)`. Pass into the tests agent's user-turn prompt as `## Zero Tests Flag: true|false`.

### C.5 Architecture trigger

Dispatch `architecture` when a new file, a `{index, main, mod, __init__, lib, app}` basename, a public-export line change, or a module-boundary path is present. When evaluating the architecture trigger, read `references/architecture-triggers.md` for the full new-file / basename / public-export regex / module-boundary-path catalog.

### C.6 Override semantics

- `--axes=all`: dispatch every axis in the registry regardless of triggers. `skipped[]` is empty.
- `--axes=<csv>`: dispatch the listed axes. Always-on axes still run unless `--axes=<csv>` explicitly excludes them (the comma-list is authoritative). Mandatory-Security still forces security on when its rule fires.
- Default (no flag): always-on + triggered axes; everything else is recorded in `skipped[]` with a one-sentence `reason` string explaining the gap ("no production-code files changed; pass `--axes=tests` to force").

The dispatch decision flows through to the chat-print step (Step F), which renders `axes_dispatched`, `axes_skipped`, and `axes_abstained` in the header line.

### C.7 Spec trigger + resolution

The `spec` axis verifies the diff builds what its originating ticket / PRD asked for — every other axis checks quality or house-rules; none checks whether the diff is the *right* change. Resolve the spec source in this priority order and capture `spec_text` and `spec_source_label` (what the text came from). Stop at the first branch that resolves:

1. **`--spec <path>` present** → `Read` it. `spec_source_label = "--spec <path>"`.
2. **Jira key in history** — search the branch name and `git log <base>..<head>` commit messages for the regex `\b[A-Z][A-Z0-9]+-\d+\b` (e.g. `GPT-1234`). On a match, fetch the issue best-effort via the Atlassian MCP (`getJiraIssue`); use the summary + description as `spec_text`, `spec_source_label = "Jira <KEY>"`. If the MCP is unavailable or the fetch fails, degrade to the next branch (do not hard-fail).
3. **PRD/spec file on disk** — a file under `docs/`, `specs/`, or `.scratch/` whose name matches the branch/feature name → `Read` it. `spec_source_label = "<path>"`.
4. **None resolved** → record `skipped[] = {axis: spec, reason: "no spec source resolved; pass --spec <path>"}` and do NOT dispatch the spec axis.

The spec axis is dispatched only when one of branches 1–3 yields `spec_text`. Under `--axes=all` it is still subject to resolution: if no source resolves, it lands in `skipped[]` with the same reason rather than dispatching empty.

---

## Step D. Launch dispatched agents in parallel

### Step D.0 — Pre-launch Read

Before the parallel dispatch, the orchestrator Reads the shared house-rules file. **This Read is critical**; it is the single-source-of-truth substrate that gets injected into every reviewer.

```
house_rules_txt   = Read("${CLAUDE_PLUGIN_ROOT}/skills/scrutinize/references/reviewer-house-rules.md")
```

`${CLAUDE_PLUGIN_ROOT}` is the plugin's install directory (the harness substitutes it); the path must resolve from any repo the skill runs in, so it is always plugin-root-relative, never repo-relative.

The orchestrator NEVER restates the house rules literally — only via this Read-and-inject substitution.

### Step D.1 — Per-axis prompt assembly

For each dispatched axis, build the user-turn prompt as the concatenation, in this order:

```
## Output Contract

Every finding MUST start with a structured Finding Anchor on its own line:

  Finding Anchor: defect_class=<plain-words defect-class phrase>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>

Name the defect class in plain words — a short phrase describing the underlying defect (e.g. "missing validation — external input to a DB query"), not a label from a fixed list. Keep the `defect_class` field on every anchor: synthesis merges and renders by it, so the phrase is critical.

After the Finding Anchor, the body is:

  Claim:    <one-sentence root-cause framing>
  Evidence: <repo-relative file:line>
            ```<lang>
            <quoted snippet from disk, ≤8 lines>
            ```
  Fix:      <concrete suggestion, optional; "—" if none>

State your confidence and its basis in plain words as part of the Claim or a short closing sentence — high when verified against cited code, low when it rests mostly on the diff. Do not append a tag.

If zero findings: emit a single line `NO FINDINGS`.

## House Rules

{{house_rules_txt}}

## Repo Root
{{repo_root}}

## Diff
{{diff_text}}

## Changed Files
{{diff_files}}

## Project Rules
{{project_rules — see below}}

## Axis
{{axis_name}}

<axis-specific hints — see Step D.2>
```

### Step D.2 — Axis-specific hint blocks (conditional)

After the common blocks above, append per-axis hint blocks. Each is conditional on the dispatched axis:

- **If `axis_name == tests`** — append:
  ```
  ## Zero Tests Flag
  {{zero_tests_flag}}    # literal "true" or "false" from Step C.4
  ```

- **If `axis_name == architecture`** (i.e. dispatching the reused `architectural-reviewer` agent) — also append the legacy-vocabulary block aliases that the reused agent's Input Contract requires:
  ```
  ## Context
  {{diff_text}}

  ## Affected Files
  {{diff_files}}

  ## Project Domain Knowledge
  {{project_rules}}
  ```
  These duplicate the same payload under the block names architectural-reviewer.md expects. Without them the agent refuses per its Input Contract. The duplication is a deliberate adapter — do not delete it.

- **If `axis_name == security`** — append:
  ```
  ## Security Trigger
  {{trigger_reason}}    # one of: "path", "code-pattern", "mandatory-new-file"
  ```

- **If `axis_name == spec`** — append the resolved spec text and its provenance (from Step C.7):
  ```
  ## Spec
  {{spec_text}}

  ## Spec Source
  {{spec_source_label}}    # one of: "--spec <path>", "Jira <KEY>", "<PRD path>"
  ```
  The `review-spec` agent refuses if `## Spec` is missing, so this block is mandatory whenever the spec axis is dispatched.

**Project Rules** is the concatenation (capped at 1500 words; trim lowest-priority whole blocks if over):
- `<repo_root>/CLAUDE.md`
- `<repo_root>/.claude/CLAUDE.md`
- `~/.claude/CLAUDE.md`
- Any `*/CLAUDE.md` ancestor of any `diff_files` path (monorepo support)

If none exist, write the line: `No project rules found; review against general principles only.`

### Step D.3 — Dispatch in parallel

Emit ALL dispatched-axis Agent calls in a **single assistant message** with multiple `Agent` tool-use blocks. Each call:

- `subagent_type`: the **second column of the Axis Registry** for this axis — and only that column. Every dispatched axis MUST use a distinct `subagent_type`; if you are about to emit two Agent calls with the same value, stop and re-read the registry.
- `model`: the Axis Registry's default-model column (`sonnet` for every axis).
- `run_in_background: true`.
- `prompt`: the assembled user-turn from D.1.

After dispatch, wait for harness notifications — do NOT poll. Emit at most one status line during the wait.

---

## Step E. Synthesize

When all dispatched agents have returned:

1. **Parse Finding Anchors** from each agent's return. Discard any text that is not a Finding Anchor + body block. Tag each finding with `axis = <agent_name>` (orchestrator-side metadata; NOT a field in the anchor). **Judge severity from the prose**: read each finding's body and decide whether it reads as high, medium, or low severity from how the reviewer described it and grounded it. **Default to low when the claim isn't grounded in a cited file/line** (so the finding flows through citation-enforcement / severity gate per rules 6+4).

   Three floors override that default. Recognize each from the reviewer's own words rather than a sentinel token — every reviewer that carries a floor is told to claim it in prose. Never demote a floored finding below its level, however terse the prose:

   | Floor | Fires on | Why it cannot be demoted |
   |---|---|---|
   | HIGH | a `review-tests` finding whose prose identifies it as the zero-tests obligation, a tautology, or a change detector | a test that can only pass is not a weak test but a false negative wearing a green check; at LOW, the grouping gate (rule 4) would drop the one finding explaining why the suite is lying |
   | MEDIUM | a `review-cleanness` finding whose defect class names comment hygiene | a house-rule prohibition, not a style preference; the gate would otherwise drop it wherever fewer than three land in one directory |
   | MEDIUM | a `review-spec` finding whose defect class names a missing or partial requirement (a `spec gap` / `spec deviation`) | a single unmet requirement would otherwise be dropped silently by the same gate |

   The floors are the only severity override; dedupe and the rest of the logic below are unchanged. Comment-hygiene findings arrive already grouped one-per-file from `review-cleanness`, so its floor promotes whole files rather than individual lines and cannot flood the report.

2. **Normalize line spans before dedupe.** Normalize each Finding Anchor's `line` field: a bare `N` becomes the range `N-N`; a `N-M` stays as-is; `cross` stays as-is. Two findings overlap if their normalized ranges intersect on the same `file`. This collapses single-line vs range anchors emitted by different agents over the same span.
3. **Dedupe by `(file, line)`** axis-agnostically using the normalized overlap rule. Overlapping findings: keep the higher-severity one; same-severity → merge the two, preserve both axes in the `axes[]` array of the merged finding.
4. **Severity gate**:
   - `HIGH` and `MEDIUM` findings pass through verbatim.
   - `LOW` findings are grouped by `(axis, file_dir)`. If a group has ≥3, render as one collapsed "LOW theme" card. Else drop. Track `counts.low_dropped`.
5. **Anti-summary-collapse**: if an agent's tool-trace shows ≥3 distinct file Reads but emits exactly 1 Finding Anchor, prepend a META finding to the list with `axis=meta`, `severity=MEDIUM`, `defect_class=implicit assumption (under-reporting)`, summary `"<agent> may have under-reported: scanned N files, emitted 1 finding. Re-read manually."`.
6. **Citation enforcement**: any finding without an Evidence snippet → auto-downgrade to `LOW` (which then flows back through rule 4).
7. **Abstinence tracking**: read each agent's return for meaning — if it states it could not assess the axis from the available context, record `{axis: <axis>, reason: <what was missing, in the agent's own words>}` in the in-memory `axes_abstained[]` list (handed to Step F as part of the data dict). Do not invent findings on the abstaining axis's behalf.

The synthesized `findings[]` list, plus run metadata (repo_root, refs, short_sha, iso_ts, axes_dispatched, axes_skipped, axes_abstained, tier, counts), is held in orchestrator memory as a single `data` dict and handed directly to the chat-print step (Step F).

---

## Step F. Chat print

Print the findings directly to chat using the in-memory `data` dict from Step E. This is the canonical and sole output mode.

### F.1 — Header line

Print one header block summarizing the run:

```
scrutinize | tier: <tier> | <repo_root> @ <short_sha> (<iso_ts>)
dispatched: <axes_dispatched joined by ", ">
skipped:    <axis>: <reason>; ...   (omit line if empty)
abstained:  <axis>: <reason>; ...   (omit line if empty)
diff snapshot: <scrutinize_dir>/<sha>-<ts>.diff
```

### F.2 — Findings

Print findings grouped by severity, in this order: HIGH → MEDIUM → LOW themes (the collapsed groups produced in Step E.4). For each finding, format:

```
[<SEVERITY>] <file>:<line>  (<defect_class>; axes: <axes joined>)
  Claim:    <claim>
  Evidence: <evidence.file_line>
            ```<evidence.lang>
            <evidence.snippet>
            ```
  Fix:      <fix or "—">
  Confidence: <HIGH|MEDIUM|LOW>
```

If `findings[]` is empty, still print the header (so the run is legible) followed by a one-line acknowledgement:

```
No findings. (axes ran clean.)
```

### F.3 — Retention prune

Run the Step B.4 retention prune on `$scrutinize_dir` to keep the 30 most recent `.diff` snapshots (see `references/snapshot-replay-retention.md`). Done.

---

## Contract Audit

This skill consumes shared-contract tokens whose renaming or deletion is a multi-file change. When renaming or deleting a shared contract token (`defect_class`, `Finding Anchor`, an `Output Contract` / `House Rules` / prompt block name, a per-axis hint block, a run-state variable, or a data-dict field), read `references/contract-audit.md` for the token→owner-file table and grep every listed owner in the same commit.
