# Contract Audit

This file is the repo's single registry of literal tokens that one agent or skill emits and another parses, with every file that emits or consumes each one. Renaming or deleting any of them is a multi-file change: update every listed file in the same commit, and grep `plugins/brian/agents/*.md` and `plugins/brian/skills/**/*.md` for the literal in case a copy is missing here. A new token gets its row in the commit that introduces it. ("SKILL.md" below means this skill's `SKILL.md`; agent files are under `plugins/brian/agents/`.)

## Shared reviewer contract

The reviewer agents narrate this contract in their Input Contract and Output Format sections, and `autopilot` (design review) and this skill (SKILL.md "Reviewers") each inject their own copy of the Output Contract, so a rename touches every copy.

| Token | Owner file |
|---|---|
| `Output Contract` (block name) | emitted by `plugins/brian/skills/autopilot/SKILL.md` (The design review) and SKILL.md (Reviewers); read by `architectural-reviewer.md`, `root-cause-reviewer.md`, `review-cleanness.md`, `review-security.md`, `review-tests.md` (Input Contract) |
| `Finding Anchor` (`defect_class=…; file=…; line=…; summary=…`) | specified by autopilot (The design review) and SKILL.md (Reviewers); emitted by the same five reviewer agents (Output Format / Output); parsed by SKILL.md (From returns to findings) |
| `defect_class` (free prose: reviewers name the defect class in plain words) | the same files as `Finding Anchor`; SKILL.md renders it on each card, and `root-cause-reviewer.md` keeps it on the anchor so findings on one file with one defect read as one |
| `INSUFFICIENT CONTEXT` | specified by autopilot (The design review, Output Contract); emitted by `architectural-reviewer.md` and `root-cause-reviewer.md` (Insufficient context rule / Constraints, Verification Step) for a dimension they cannot assess |
| `Context`, `Affected Files`, `Project Domain Knowledge` (block names) | emitted by autopilot (The design review); read by `architectural-reviewer.md` and `root-cause-reviewer.md` (Input Contract), which request a missing block before reviewing |
| `Prior intent` (`## Prior intent` block) | emitted by autopilot (The design review); consumed by `root-cause-reviewer.md` §2 PROVENANCE and COVERAGE checks, which skip its own historian when the block states where its intent came from; `code-historian.md` (The synthesis) writes the report that block carries |
| `clean` / `findings` / `incomplete` (`verdict:` header keywords) | emitted by SKILL.md (From returns to findings, The result); consumed by autopilot (Self-review), which branches on them. `incomplete` means some dispatched axis left part of the diff unreviewed, and a consumer treats it as unreviewed code rather than a pass |

## Tokens local to scrutinize

| Token | Owner file |
|---|---|
| `House Rules` (block name; its value is the house-rules file's path) | SKILL.md (Reviewers) + `reviewer-house-rules.md` + `review-cleanness.md`, `review-security.md`, `review-tests.md` (Input Contract) |
| `Repo Root`, `Diff Snapshot`, `Changed Files`, `Axis`, `Failing Tests` (block names) | SKILL.md (Reviewers) + `review-cleanness.md`, `review-security.md`, `review-tests.md` (Input Contract) + `reviewer-house-rules.md` (Rule 9, for `Diff Snapshot` and `Changed Files`) |
| snapshot layout: `full.diff`, `files/<path>.diff`, `index.tsv` columns (status, diff line count, path, per-file diff path), and the script's printed lines (`snapshot:`, `security trigger:`, `zero tests:`, `tests home:`) | `scripts/snapshot.sh` + SKILL.md (The snapshot, Axes and groups, Reviewers) + `reviewer-house-rules.md` (Rule 9) |
| `NO FINDINGS` | SKILL.md (Reviewers, From returns to findings) + `review-cleanness.md`, `review-security.md`, `review-tests.md` (Output) + `reviewer-house-rules.md` (Rule 7) |
| `I did not review this diff` (a reviewer's refusal for a missing block) | `review-cleanness.md`, `review-security.md`, `review-tests.md` (Input Contract, the literal) + SKILL.md (From returns to findings, which reads a refusal for a missing block as coverage `none` without matching the literal) |
| `Zero Tests Flag` (per-axis hint) | SKILL.md (Axes and groups, Reviewers, From returns to findings) + `review-tests.md` |
| `Coding Standards` (per-axis hint) | SKILL.md (Reviewers) + `review-cleanness.md`, `review-tests.md` (Input Contract) |
| `Security Trigger` (per-axis hint) | SKILL.md (Reviewers) + `review-security.md` (Input Contract) |
| tautological / change-detector HIGH floor | SKILL.md (From returns to findings) + `review-tests.md` (Prohibited section) + `reviewer-house-rules.md` (Rules 3, 8, 10) |
| zero-tests HIGH floor | SKILL.md (Axes and groups, From returns to findings) + `scripts/snapshot.sh` (`tests home`) + `review-tests.md` (Zero-tests obligation) + `reviewer-house-rules.md` (Rule 8) |
| comment-hygiene MEDIUM floor | SKILL.md (From returns to findings) + `review-cleanness.md` (§1) + `reviewer-house-rules.md` (Rules 3, 8) |
| coding-standards HIGH floor | SKILL.md (From returns to findings) + `review-cleanness.md` (§7) + `reviewer-house-rules.md` (Rules 3, 8) |
| check-then-act race ownership | `review-security.md` (Methodology, check-then-act races bullet) + `reviewer-house-rules.md` (Rule 8) |
| `axis` (orchestrator-side per-finding metadata, including `suite`) | SKILL.md (From returns to findings) |
| `coverage:` header line and its values `full` / `partial` / `none` | SKILL.md (From returns to findings, The result) + `plugins/brian/skills/autopilot/SKILL.md` (Self-review, which moves each uncovered axis and its files to the top of the register) |

The severity floors and the coverage statement are recognized from reviewer prose rather than a sentinel token, so they have no greppable string to sweep. The files listed for each must instead agree on which axis owns the finding, what wording the reviewer uses to claim the floor or state its coverage, and that House Rule 3's anti-cosmetic gate does not reach the floors. Changing a floor level, moving ownership between axes, or relaxing the anti-cosmetic carve-out is a multi-file edit.

The `defect_class` field is free prose: reviewers name the defect class in plain words, and the orchestrator renders that phrase on the finding's card; findings merge by file and overlapping line span. The `cleanness` axis (via `review-cleanness.md`) covers the comment rule and reuse hunt plus the behavior-preserving quality angles — efficiency, simplification, and local altitude — and reviewers describe each in plain words (e.g. "redundant work" for reuse/efficiency, "simplification gap" for simplification/local altitude).
