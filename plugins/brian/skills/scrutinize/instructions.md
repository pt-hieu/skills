# Scrutinize — Execution Guide

`brian:scrutinize` dispatches axis-specialized reviewer subagents in parallel against a local diff, synthesizes findings under Brian's house rules, and renders a self-contained HTML report plus a durable JSON sidecar. The HTML is presentation; the JSON is canon.

The orchestrator owns the I/O contract. Reviewer agents narrate the contract in their Input Contract sections — they do not own the schema, enum, or rules. The orchestrator Read-injects the shared blocks at invocation time.

---

## Axis Registry (single source of truth)

| axis | `subagent_type` (Agent tool) | agent file | always-on? | trigger (one-line) | default model |
|---|---|---|---|---|---|
| `correctness-reliability` | `review-correctness-reliability` | `review-correctness-reliability.md` | yes | — | sonnet |
| `cleanness` | `review-cleanness` | `review-cleanness.md` | yes (downgradable on tiny diffs) | — | sonnet |
| `security` | `review-security` | `review-security.md` | no | path/code regex OR new-file under security-trigger dir (mandatory) | sonnet |
| `tests` | `review-tests` | `review-tests.md` | no | production-code file in diff | sonnet |
| `architecture` | `architectural-reviewer` | `architectural-reviewer.md` (REUSED) | no | new file / public-export change / module-boundary path | sonnet |

Steps C, D, E, F, G all reference this table. Do not re-list axes in prose elsewhere in this file.

**Dispatch invariant**: when emitting an `Agent` tool call for an axis, the `subagent_type` argument comes from the second column above and ONLY from that column — never substitute `architectural-reviewer` (or any other value) as a default. If the orchestrator finds itself emitting two Agent calls with the same `subagent_type`, that is a bug: re-read this table.

---

## Step A. Parse args

Extract from the user's `/scrutinize` invocation:

- `mode ∈ {working-tree, branch, commit, base}` — driven by which flag is present (default: `working-tree`).
- `axes_override ∈ {all, <comma-list>, default}` — from `--axes=...`.
- `replay_input ∈ {<sha-ts> | none}` — from `--input <sha-ts>`.

Reject incompatible combinations (e.g. `--branch` and `--commit` together) with a one-line error and exit non-zero.

---

## Step B. Resolve diff base and gather diff

```
repo_root=$(git rev-parse --show-toplevel)
mkdir -p "$repo_root/.scrutinize"
```

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
snapshot="$repo_root/.scrutinize/${short_sha}-${iso_ts}.diff"
printf '%s' "$diff_text" > "$snapshot"
```

### B.4 Retention prune

After the run completes (end of Step H), prune `<repo>/.scrutinize/` to keep the 30 most recent of each artifact class by mtime:

```
ls -t "$repo_root/.scrutinize/"*.diff 2>/dev/null | tail -n +31 | xargs -r rm --
```

### B.5 Replay mode (`--input <sha-ts>`)

If `replay_input` is set, skip B.1–B.3 and instead:

```
snapshot="$repo_root/.scrutinize/${replay_input}.diff"
test -s "$snapshot" || { echo "scrutinize: snapshot not found: $snapshot" >&2; exit 5; }
diff_text=$(cat "$snapshot")
```

Replay uses the cached snapshot verbatim; the diff is canonical because the snapshot file is what the prior run reviewed.

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
- Downgrade any non-trigger-matched axis to `sonnet`. Triggered axes stay on `opus`.
- Set `tier = sonnet-narrow` if every dispatched axis was downgraded; else `opus-narrow`.

If not tiny: `tier = opus-full`.

### C.3 Security trigger

Dispatch `security` if ANY of:

1. Any changed-file path matches the path regex:
   ```
   auth|session|login|signup|password|token|credential|secret|key|jwt|oauth|saml|csrf|cors|middleware|guard|policy|permission|rbac|acl|identity|account|user|iam|principal|\.env|config/secrets|credentials\.
   ```
2. Any added line (`^+` in diff_text, excluding `+++` headers) matches a code-pattern regex:
   ```
   (SELECT|INSERT|UPDATE|DELETE).*\$\{|`.*\$\{.*`.*(query|exec)
   exec\(|eval\(|spawn\(|system\(|shell|popen\(
   req\.(body|query|params)|request\.(form|args|json)
   process\.env|os\.environ|getenv
   (api[_-]?key|secret|password|token|jwt|bearer)\s*[:=]\s*["']
   crypto|jwt|bcrypt|argon2|scrypt|md5|sha1
   ```
3. **Mandatory-Security rule**: any file with `git diff --name-status` status `A` (added) AND (the file is under one of the security-trigger directory tokens above OR the file is under a module-boundary directory `api|routes|controllers|services|middleware`).

When dispatched, record which trigger fired (path / code-pattern / mandatory-new-file) in the HTML header.

### C.4 Tests trigger

Dispatch `tests` if at least one production-code file is in the diff. A file is production-code if its path does NOT match any of:
```
^(test|tests|spec|specs|__tests__)/
\.(test|spec)\.(ts|tsx|js|jsx|py|go|rs|java|rb)$
_test\.(go|py)$
_spec\.rb$
```

Compute `zero_tests_flag = (production_files >= 1 AND test_files == 0)`. Pass into the tests agent's user-turn prompt as `## Zero Tests Flag: true|false`.

### C.5 Architecture trigger

Dispatch `architecture` if ANY of:

1. Any file in `diff_files` has status `A` (new file).
2. Any file's basename (without extension) is in `{index, main, mod, __init__, lib, app}`.
3. Any added or removed line matches the public-export regex:
   ```
   ^[+-]\s*(export\s+(default|const|function|class|type|interface|enum)|module\.exports\s*=|public\s+(class|interface|enum|fun)|pub\s+(fn|struct|enum|trait|mod))\b
   ```
4. Any changed-file path is under a module-boundary directory: `api|routes|controllers|services|domain|core|interfaces|ports|adapters`.

### C.6 Override semantics

- `--axes=all`: dispatch every axis in the registry regardless of triggers. `skipped[]` is empty.
- `--axes=<csv>`: dispatch the listed axes. Always-on axes still run unless `--axes=<csv>` explicitly excludes them (the comma-list is authoritative). Mandatory-Security still forces security on when its rule fires.
- Default (no flag): always-on + triggered axes; everything else is recorded in `skipped[]` with a one-sentence `reason` string explaining the gap ("no production-code files changed; pass `--axes=tests` to force").

The dispatch decision flows through Step F (JSON `axes_dispatched` and `axes_skipped`) and Step G (HTML header line).

---

## Step D. Launch dispatched agents in parallel

### Step D.0 — Pre-launch Reads

Before the parallel dispatch, the orchestrator Reads three files. **These Reads are load-bearing**; they are the single-source-of-truth substrate that gets injected into every reviewer.

```
enum_text         = Read("plugins/brian/agents/_shared/defect-class-enum.md")
house_rules_txt   = Read("plugins/brian/agents/_shared/reviewer-house-rules.md")
html_template     = Read("plugins/brian/skills/scrutinize/references/html-template.html")
render_script_text = Read("plugins/brian/skills/scrutinize/references/html-render.py")
```

The orchestrator NEVER restates the enum or house rules literally — only via these Read-and-inject substitutions.

### Step D.1 — Per-axis prompt assembly

For each dispatched axis, build the user-turn prompt as the concatenation, in this order:

```
## Output Contract

Every finding MUST start with a structured Finding Anchor on its own line:

  Finding Anchor: defect_class=<CATEGORY>; file=<repo-relative-path>; line=<N | N-M | "cross">; summary=<one-sentence canonical issue>

defect_class enum (closed list):
  {{enum_text}}

After the Finding Anchor, the body is:

  Claim:    <one-sentence root-cause framing>
  Evidence: <repo-relative file:line>
            ```<lang>
            <quoted snippet from disk, ≤8 lines>
            ```
  Fix:      <concrete suggestion, optional; "—" if none>
  Confidence: [HIGH | MEDIUM | LOW]

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

<axis-specific hints — see Step D.3>
```

### Step D.3 — Axis-specific hint blocks (conditional)

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

**Project Rules** is the concatenation (capped at 1500 words; trim lowest-priority whole blocks if over):
- `<repo_root>/CLAUDE.md`
- `<repo_root>/.claude/CLAUDE.md`
- `~/.claude/CLAUDE.md`
- Any `*/CLAUDE.md` ancestor of any `diff_files` path (monorepo support)

If none exist, write the line: `No project rules found; review against general principles only.`

### Step D.2 — Dispatch in parallel

Emit ALL dispatched-axis Agent calls in a **single assistant message** with multiple `Agent` tool-use blocks. Each call:

- `subagent_type`: the **second column of the Axis Registry** for this axis. Concretely:
  - `correctness-reliability` axis → `subagent_type: "review-correctness-reliability"`
  - `cleanness` axis → `subagent_type: "review-cleanness"`
  - `security` axis → `subagent_type: "review-security"`
  - `tests` axis → `subagent_type: "review-tests"`
  - `architecture` axis → `subagent_type: "architectural-reviewer"`
  Every dispatched axis MUST use a distinct `subagent_type`. If you are about to emit two Agent calls with the same value, stop and re-read the registry.
- `model`: per the tier decision in Step C.2 (default `sonnet`; tier downgrade pins `sonnet`).
- `run_in_background: true`.
- `prompt`: the assembled user-turn from D.1.

After dispatch, wait for harness notifications — do NOT poll. Emit at most one status line during the wait.

---

## Step E. Synthesize

When all dispatched agents have returned:

1. **Parse Finding Anchors** from each agent's return. Discard any text that is not a Finding Anchor + body block. Tag each finding with `axis = <agent_name>` (orchestrator-side metadata; NOT a field in the anchor). **Confidence extraction accepts both forms**: (a) the new shared house-rules form — a trailing `Confidence: [HIGH|MEDIUM|LOW]` line; (b) the legacy form used by `architectural-reviewer` and `root-cause-reviewer` — an inline `[HIGH|MEDIUM|LOW]` tag at the end of the Issue/Claim sentence. Search both; the legacy form wins only when no trailing `Confidence:` line is present. If neither is found, default to `LOW` (so the finding flows through citation-enforcement / severity gate per rules 5+3).
2. **Normalize line spans before dedupe.** Normalize each Finding Anchor's `line` field: a bare `N` becomes the range `N-N`; a `N-M` stays as-is; `cross` stays as-is. Two findings overlap if their normalized ranges intersect on the same `file`. This collapses single-line vs range anchors emitted by different agents over the same span.
3. **Dedupe by `(file, line)`** axis-agnostically using the normalized overlap rule. Overlapping findings: keep the higher-severity one; same-severity → merge the two, preserve both axes in the `axes[]` array of the merged finding.
4. **Severity gate**:
   - `HIGH` and `MEDIUM` findings pass through verbatim.
   - `LOW` findings are grouped by `(axis, file_dir)`. If a group has ≥3, render as one collapsed "LOW theme" card. Else drop. Track `counts.low_dropped`.
5. **Anti-summary-collapse**: if an agent's tool-trace shows ≥3 distinct file Reads but emits exactly 1 Finding Anchor, prepend a META finding to the list with `axis=meta`, `severity=MEDIUM`, `defect_class=Implicit Assumption`, summary `"<agent> may have under-reported: scanned N files, emitted 1 finding. Re-read manually."`.
6. **Citation enforcement**: any finding without an Evidence snippet → auto-downgrade to `LOW` (which then flows back through rule 4).
7. **Abstinence tracking**: if an agent returned `INSUFFICIENT CONTEXT — ...`, record `{axis: <axis>, reason: <what was missing>}` in the in-memory `axes_abstained[]` list (handed to Step F as part of the data dict). Do not invent findings on the abstaining axis's behalf.

The synthesized `findings[]` list, plus run metadata (repo_root, refs, short_sha, iso_ts, axes_dispatched, axes_skipped, axes_abstained, tier, counts), is held in orchestrator memory as a single `data` dict and handed directly to Step F. Step E never builds HTML strings; Step F never persists this dict to disk.

---

## Step F. Render HTML

The orchestrator builds an in-memory `data` dict from Step E's outputs and pipes it (plus the template Read in Step D.0) into `python3` over stdin. No JSON sidecar is persisted — the HTML is the only durable artifact (the `.diff` snapshot is separately persisted in Step B for replay).

The `data` dict shape (constructed in memory; serialized only for the python stdin payload):

```jsonc
{
  "repo_root": "<absolute path>",
  "base_ref": "<ref or 'working-tree'>",
  "head_ref": "<ref>",
  "short_sha": "<sha>",
  "iso_timestamp": "<UTC ISO>",
  "axes_dispatched": ["correctness-reliability", "cleanness", "security"],
  "axes_skipped": [{"axis": "tests", "reason": "no production-code files changed"}],
  "axes_abstained": [{"axis": "security", "reason": "auth middleware not in diff snapshot"}],
  "tier": "opus-full",
  "diff_snapshot_path": "<repo>/.scrutinize/<sha>-<ts>.diff",
  "counts": {"high": 0, "medium": 0, "low_collapsed_themes": 0, "low_dropped": 0},
  "findings": [
    {
      "axes": ["correctness-reliability"],
      "defect_class": "Concurrency Hazard",
      "file": "src/foo.ts",
      "line": "42-48",
      "summary": "...",
      "claim": "...",
      "evidence": {"file_line": "src/foo.ts:42", "lang": "ts", "snippet": "..."},
      "fix": "...",
      "confidence": "HIGH"
    }
  ]
}
```

The orchestrator NEVER builds HTML strings. The rendering is a deterministic shell-out to the checked-in script `plugins/brian/skills/scrutinize/references/html-render.py` — see that file for the full renderer. The orchestrator does not embed the script body anywhere; it Reads it once (Step D.0) and stages it.

### F.1 — Stage the script and payload

The Bash tool runs in the user's working directory, which is usually NOT the skills marketplace, so the checked-in script path is not directly callable. Stage both the script and the JSON payload to absolute `/tmp/` paths.

```
out_path="/tmp/scrutinize-$(basename "$repo_root")-${short_sha}-${iso_ts}.html"
script_path="/tmp/scrutinize-render-${short_sha}-${iso_ts}.py"
payload_path="/tmp/scrutinize-payload-${short_sha}-${iso_ts}.json"

command -v python3 >/dev/null 2>&1 || { echo "scrutinize: python3 required" >&2; exit 2; }
```

The orchestrator uses the Write tool to put `render_script_text` (from the Step D.0 Read of `references/html-render.py`) into `$script_path`, and to put the JSON payload `{"template": template_text, "data": <data dict>}` into `$payload_path`. Both writes complete before F.2.

### F.2 — Invoke

```
python3 "$script_path" "$out_path" < "$payload_path"
rc=$?
rm -f "$script_path" "$payload_path"
test $rc -eq 0 || { echo "scrutinize: render exited $rc" >&2; exit $rc; }
```

Non-zero exit from the script propagates with its stderr (sentinel coverage, malformed payload, missing key). The script's exit codes are documented in its module docstring.

---

## Step G. Verify and print

```
test -s "$out_path" || { echo "scrutinize: HTML render produced empty file" >&2; exit 4; }
```

Then print to chat:
```
HTML report:  <out_path>
Diff snapshot: <repo>/.scrutinize/<sha>-<ts>.diff
```

Run Step B.4 retention prune. Done.

---

## Contract Audit

Shared-contract tokens this skill consumes. Renaming or deleting any of them is a multi-file change — grep the listed owners in the same commit.

| Token | Owner file |
|---|---|
| `defect_class` (and its 12-member closed enum) | `plugins/brian/agents/_shared/defect-class-enum.md` |
| `Finding Anchor` | this file (Step D.1) + shared agents narrate the format |
| `Output Contract` (block name) | this file (Step D.1) + agents' Input Contract sections |
| `House Rules` (block name) | `plugins/brian/agents/_shared/reviewer-house-rules.md` |
| `Repo Root`, `Diff`, `Changed Files`, `Project Rules`, `Axis` (block names) | this file (Step D.1) |
| `Zero Tests Flag` (per-axis hint) | this file (Step C.4) + `review-tests.md` |
| `axis` (orchestrator-side per-agent metadata) | this file (Step E) |
| `axes_dispatched`, `axes_skipped`, `axes_abstained`, `tier` (data-dict fields) | this file (Steps C, E, F) |

The two enum members `Comment Hygiene Drift` and `Test Coverage Gap` are new in this skill (extended in `_shared/defect-class-enum.md`). Adding a member is a one-file edit; every Read-and-inject consumer (`scrutinize`, `challenge`) picks it up automatically.
