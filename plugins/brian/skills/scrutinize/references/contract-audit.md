# Contract Audit

Shared-contract tokens this skill consumes. Renaming or deleting any of them is a multi-file change — grep the listed owners in the same commit. ("this file" below means `SKILL.md`, the orchestrator's execution guide.)

`defect_class`, `Finding Anchor`, and `Output Contract` describe the shared reviewer contract this skill's Output Contract section (SKILL.md Step D.2) narrates a copy of. Their canonical registry is `plugins/brian/skills/challenge/references/contract-audit.md`, which also holds the verdict keywords `clean` / `findings` / `incomplete`, because autopilot reads them. A rename of any shared-contract token there must sweep this file's SKILL.md Step D.2 narration in the same commit.

| Token | Owner file |
|---|---|
| `House Rules` (block name; its value is the house-rules file's path) | this file (Step D.2) + `reviewer-house-rules.md` + `review-cleanness.md`, `review-security.md`, `review-tests.md` (Input Contract) |
| `Repo Root`, `Diff Snapshot`, `Changed Files`, `Axis`, `Failing Tests` (block names) | this file (Steps D.1, D.2) + `review-cleanness.md`, `review-security.md`, `review-tests.md` (Input Contract) + `reviewer-house-rules.md` (Rule 9, for `Diff Snapshot` and `Changed Files`) |
| snapshot layout: `full.diff`, `files/<path>.diff`, `index.tsv` columns (status, diff line count, path, per-file diff path), and the script's printed lines (`snapshot:`, `security trigger:`, `zero tests:`, `tests home:`) | `scripts/snapshot.sh` + this file (Steps B, C, D.2) + `reviewer-house-rules.md` (Rule 9) |
| `NO FINDINGS` | this file (Step D.2 Output Contract, Step E) + `review-cleanness.md`, `review-security.md`, `review-tests.md` (Output) + `reviewer-house-rules.md` (Rule 7) |
| `I did not review this diff` (a reviewer's refusal for a missing block) | `review-cleanness.md`, `review-security.md`, `review-tests.md` (Input Contract) + this file (Step E.1, which reads it as coverage `none`) |
| `Zero Tests Flag` (per-axis hint) | this file (Steps C, D.3, E.2) + `review-tests.md` |
| `Coding Standards` (per-axis hint) | this file (Steps C, D.3) + `review-cleanness.md`, `review-tests.md` (Input Contract) |
| `Security Trigger` (per-axis hint) | this file (Step D.3) + `review-security.md` (Input Contract) |
| tautological / change-detector HIGH floor | this file (Step E.2, E.3) + `review-tests.md` (Prohibited section) + `reviewer-house-rules.md` (Rules 3, 8, 10) |
| zero-tests HIGH floor | this file (Steps C, E.2) + `scripts/snapshot.sh` (`tests home`) + `review-tests.md` (Zero-tests obligation) + `reviewer-house-rules.md` (Rule 8) |
| comment-hygiene MEDIUM floor | this file (Step E.2) + `review-cleanness.md` (§1) + `reviewer-house-rules.md` (Rules 3, 8) |
| coding-standards HIGH floor | this file (Step E.2) + `review-cleanness.md` (§7) + `reviewer-house-rules.md` (Rules 3, 8) |
| check-then-act race ownership | `review-security.md` (Methodology 9) + `reviewer-house-rules.md` (Rule 8) |
| `axis` (orchestrator-side per-finding metadata, including `suite`) | this file (Step E) |
| coverage values `full` / `partial` / `none` | this file (Steps E.1, E.7, F) |

The severity floors and the coverage statement are recognized from reviewer prose rather than a sentinel token, so they have no greppable string to sweep. The files listed for each must instead agree on which axis owns the finding, what wording the reviewer uses to claim the floor or state its coverage, and that House Rule 3's anti-cosmetic gate does not reach the floors. Changing a floor level, moving ownership between axes, or relaxing the anti-cosmetic carve-out is a multi-file edit.

The `defect_class` field is free prose: reviewers name the defect class in plain words, and the orchestrator merges and renders by that phrase. The `cleanness` axis (via `review-cleanness.md`) covers the comment rule and reuse hunt plus the behavior-preserving quality angles — efficiency, simplification, and local altitude — and reviewers describe each in plain words (e.g. "redundant work" for reuse/efficiency, "simplification gap" for simplification/local altitude).
