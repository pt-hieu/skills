---
name: assess-code-review
description: "Use when working a Bitbucket PR's open review comments to closure — assess each unresolved comment, propose fixes for the ones you agree with and concise push-backs for the ones you don't, then apply and resolve on approval."
argument-hint: "[PR-ID]"
---

# Assess Code Review

## When to Use
- Brian has a Bitbucket PR with reviewer comments and wants them triaged and actioned.
- Invoked as `/assess-code-review [PR-ID]`, or hands off "deal with the review comments on my PR".

## When NOT to Use
- Authoring or describing a PR (that is not this skill).
- Committing or pushing — run `brian:commit` separately afterward.

## Overview

`brian:assess-code-review` is a single-approval loop over a Bitbucket PR's OPEN review comments. You act as a senior engineer triaging your own PR: read each unresolved comment fairly, decide whether you agree, and drive every open thread to a terminal state — fixed-and-resolved, or answered-and-left-open — in one batched human gate.

You own the whole loop: PR resolution, fetching and filtering comments, classification, the single batched presentation, and the post-approval apply/resolve/reply sequence. There is exactly ONE human gate (the batched approval); everything before it is read-only assessment, everything after it is mechanical execution of the approved dispositions.

Defaults (interface repo, per global CLAUDE.md): Bitbucket workspace `drovacorp`, repository `interface` (pass as `drovacorp/interface`), target branch `master`. PR comments are authored as Claude Code on behalf of Brian Pham. Write MCP payloads with bare `\n` newlines — the API renders them directly, while escaped `\\n` prints literal backslashes.

## Step A.0 — Preflight: confirm the Bitbucket MCP is available

Before anything else, load the Bitbucket MCP tool schemas — they are deferred: run `ToolSearch` with `select:mcp__bitbucket__get_current_user,mcp__bitbucket__list_pull_requests,mcp__bitbucket__get_pull_request,mcp__bitbucket__get_comments,mcp__bitbucket__get_comment,mcp__bitbucket__resolve_comment,mcp__bitbucket__add_comment,mcp__bitbucket__get_diff`. Calling a deferred tool without loading its schema fails with InputValidationError.

If the Bitbucket tools do not resolve (MCP not connected in this session), STOP immediately and tell Brian the Bitbucket MCP isn't available and to connect it — do NOT attempt git/API fallbacks. This is a hard precondition: every downstream step depends on these tools.

When you need a tool's exact signature or intended use while executing a step below, read `references/mcp-tools.md` (the tool registry).

## Step A. Resolve the target PR

> **Defaults (recap from the Overview above):** `repository = "drovacorp/interface"`, target `master`. Step A and Step F both consume this `repository` value; keep the literal here in sync with the Overview so a future platform swap is a two-line edit.

1. If `[PR-ID]` is provided → use the Defaults `repository`, `prId = <arg>`. Confirm it exists via `get_pull_request`; if it 404s, stop and tell Brian the id wasn't found rather than guessing.
2. If no `[PR-ID]` → auto-detect from the current branch:
   a. `current_branch = git rev-parse --abbrev-ref HEAD`.
   b. `list_pull_requests(repository="drovacorp/interface", state="OPEN")`, then match the PR whose `source.branch.name == current_branch`. (Prefer a server-side `q` filter on source branch if available; otherwise filter the returned page locally and paginate if needed.)
   c. **0 matches** → stop. Tell Brian no open PR was found for `<branch>` and ask whether to pass a PR id explicitly (single `AskUserQuestion`). Do NOT fabricate or pick an unrelated PR.
   d. **exactly 1 match** → use it.
   e. **>1 match** → emit a SINGLE `AskUserQuestion` listing the candidate PRs (id, title, source→target) and let Brian pick. Never guess.
3. Record `resolved = {repository, prId, source_branch, target_branch}` and echo a one-line confirmation ("Assessing PR #<id> <title> (<src>→<tgt>)") before fetching comments.

## Step B. Fetch and filter open comments

1. `get_comments(repository, prId, pagelen=100)`; paginate until exhausted. Hold every comment with its `id`, author, body, inline `{path, to/from}` if present, parent/child thread linkage, and resolution status.
2. **Filter to unresolved/open only.** Skip any comment whose thread is resolved (use the resolution-status field returned by `get_comments`). Skip deleted comments. A reply you intend to act on attaches to the TOP-LEVEL open comment of its thread — track thread roots so a resolve/reply targets the right `commentId`.
3. **Exclude your own comments** — drop comments authored by the `get_current_user` account (Claude-on-behalf replies from a prior run); they are not reviewer feedback. Identify the author once via `get_current_user`.
4. If a comment body is truncated in the list payload, re-fetch it with `get_comment` for the full text before assessing — never classify on a truncated comment.
5. **No open comments** → stop cleanly: report that there are no unresolved review comments on PR #<id> and exit. This is a success terminal state, not an error.

## Step C. Classification methodology

For each open comment, before deciding, pull the relevant code context: use the inline `{path, to/from}` to read the surrounding lines (Read the file in the working tree, and/or `get_diff(repository, prId, path)` for the reviewed hunk). A comment with no associated code (a general PR-level comment) is assessed on its text alone.

Classify into exactly one disposition:

- **AGREE** — the comment identifies a real problem or a clear improvement you'd make. Formulate a CONCRETE fix: the exact file and the change (what to edit, to what). Do NOT edit the working tree yet — only describe the fix. If the fix is non-trivial, state it precisely enough that applying it post-approval is mechanical.
- **DISAGREE** — you have a defensible reason not to make the change. Draft a concise push-back reply. **Counter-argument discipline:** first restate the reviewer's point fairly in one clause so the reply doesn't read as dismissive, then give the reason, then (if relevant) the alternative. Keep it decisive and hedge-free — this is the Decisive-Minimalist register, not a debate.
- **AMBIGUOUS** — you genuinely cannot classify (the comment is unclear, asks a question only Brian can answer, depends on product intent, or could go either way). **Abstain rather than guess** — surface it in the batch as AMBIGUOUS with a one-line note on what's unclear, and let Brian decide its disposition during approval.

Bias note: do not inflate AGREE to look agreeable, and do not inflate DISAGREE to look rigorous. The honest disposition is the correct one. When a comment bundles several asks, split them into separate rows so each gets its own disposition.

**Comment-type mapping (the three dispositions are by ACTION, not sentiment).** AGREE = "fix the code, then resolve, no reply." DISAGREE = "reply, leave the thread open." Map the common reviewer-comment types onto these:
- **A question that implies a change you'll make** ("shouldn't this handle null?") → AGREE (make the change; resolve).
- **A question you can answer without a code change** ("why this approach?") → handled like DISAGREE — post a concise answer and leave the thread open. You are not "disagreeing," but the mechanics are identical (reply, do not resolve). Restating-the-point discipline still applies.
- **A genuine question only Brian can answer** (product intent) → AMBIGUOUS.
- **A nit / clear small improvement** → AGREE (apply; resolve).
- **Praise / non-actionable remark** → no action: do not reply, do not resolve. List it in the batch as "no-op" so Brian sees it was considered.
- **Already-addressed in the working tree** → resolve with no reply (it's done); note "already addressed" in the batch row.

## Step D. Present ONE batched assessment (the single human gate)

Render the full assessment to chat as ONE human-readable table (prose-first — this is read by Brian, not parsed by a machine). One row per comment (or per split sub-ask). Columns:

| # | Comment (author, file:line, gist) | Disposition | Proposed fix / Draft reply |

- For AGREE rows: the proposed fix = file + the concrete change.
- For DISAGREE rows: the draft reply = the actual push-back text you'll post.
- For AMBIGUOUS rows: the open question for Brian.

Below the table, state the gate explicitly: "Approve to apply all AGREE fixes (silently resolving those threads) and post all DISAGREE replies (leaving them open). You can adjust any row first — change a disposition, edit a fix, or rewrite a reply — before approving." Then WAIT.

**Single-gate discipline (load-bearing):** present everything at once and wait for ONE approval. Do not action any row before approval. Do not ask per-comment. Brian may revise specific rows (flip a disposition, edit fix/reply text, drop a row); fold his changes in and proceed — re-present only if he asks. AMBIGUOUS rows MUST receive a disposition from Brian here; an AMBIGUOUS row that stays ambiguous after the gate is left untouched (no edit, no resolve, no reply), not guessed.

**Disposition-flip rule:** if Brian flips a row to a disposition that has no drafted artifact yet — e.g. AMBIGUOUS/DISAGREE → AGREE (no fix was drafted), or AGREE → DISAGREE (no reply was drafted) — draft the missing fix or reply and re-present THAT single row for a quick confirmation before executing it. A disposition flip is not a mechanical edit, so it does not violate the "execution after the gate is mechanical" invariant — the freshly drafted artifact still gets one look. If Brian rejects or further changes that re-presented artifact, fold in his change and re-present it once more — that becomes the gate for the row. If he rejects it outright, leave the row untouched and surface it as unresolved in the final summary; never execute an artifact he declined.

## Step E. Voice pass for push-back replies

Before posting, run every reply-and-leave-open draft (DISAGREE rows, plus answerable-question rows) through the `voice:voice` skill (invoke `voice:voice` via the `Skill` tool) — these are team-facing Bitbucket comments. Pass the drafted reply text; use the returned wording. The reply is authored as Claude Code on behalf of Brian Pham, per the interface rule. Do this for the approved set only (after the gate), so Brian's row edits are reflected in what gets voiced.

**Register precedence (resolves a spec conflict).** `voice:voice` defaults to a warmer, more hedged register; Step C requires these replies stay concise, fair, and hedge-free. Step C's register wins: use `voice:voice` for surface conventions (Brian's phrasing, team-appropriate tone, no robotic stiffness) but keep the reply short and decisive — the fair-restatement→reason structure and the no-hedging rule from Step C override any softening voice would add. If the voiced result reads as wishy-washy or padded, tighten it back toward the Step C draft.

## Step F. On approval — apply / resolve / reply

Execute the approved dispositions. Order: do the AGREE fixes first, then the DISAGREE replies, so a fix failure surfaces before any comment is posted.

For each AGREE row:
1. Apply the fix to the working tree (Edit/Write on the target file).
2. **Outcome self-check before resolving:** confirm the edit you just made actually addresses the comment's ask. If it only partially addresses it, do NOT resolve — leave the thread open and note the gap in the summary. "Silent resolve" must never hide a fix that missed the point.
3. Immediately `resolve_comment(repository, prId, commentId, resolve=true)` on that thread's root comment.
4. **Silent on agree (load-bearing):** post NO reply on an agreed thread. The fix + resolve is the entire action.

For each DISAGREE row — and each answerable-question row (Step C's "reply, leave open" type), which uses identical mechanics:
1. `add_comment(repository, prId, text=<voiced reply>, parentId=<comment root id>)` — threaded reply on that comment.
2. **Never resolve these threads** — leave them open for the reviewer to respond.

For each AMBIGUOUS row that Brian re-classified at the gate: treat it as AGREE or DISAGREE per his decision. If still ambiguous: leave it entirely untouched.

**Boundaries (hard stop):** after applying edits, STOP. Do not `git add`, commit, or push — Brian runs `brian:commit` separately. Report a final summary: which threads were fixed+resolved (**show the applied change per thread — file + a one-line diff gist — so Brian can eyeball what was resolved silently**), which got replies+left-open, which were left untouched/no-op, and any thread left open because its fix only partially addressed the comment. Remind Brian to review the working-tree changes and commit when ready.

## Step G. Edge cases

On any edge case in the loop above — MCP not connected, PR-id 404, no/many PRs for the branch, no unresolved comments, a truncated or code-less comment, an MCP auth/tool error, a rejected batch, a fix that fails to apply mid-execution, a reply that fails to post after fixes resolved, or an edit that doesn't fully address its comment — read `references/edge-cases.md` for the exact handling.
