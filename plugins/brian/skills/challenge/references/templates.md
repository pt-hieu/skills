# Render Templates — Step 5 closing renders

Read this at Step 5, when turning the user's directions into PR comments (review-only) or the closing chat turn (implementer). Use these blocks verbatim; project from the merged finding list and the directions the user gave — do NOT re-derive fields.

The Step 4 tension block (`➡️` / `🛑` / `？`) is not here: it is canonical in SKILL.md Step 4, together with the rules that govern it.

## Review-only — PR comments

Append to the run file, one entry per direction the user chose to raise:

```
## PR Review Comments

**HIGH** {file}:{line} — {description}

{suggestion, including code snippet if available}

---
**MEDIUM** {file}:{line} — {description}
...
```

Then in chat:

```
## PR Review Comments — N ready
- ❌ HIGH {file:line}: {one-sentence issue}
- ⚠️ MEDIUM {file:line}: {one-sentence issue}

Full comments with code snippets in: <run_file>
Post via Bitbucket MCP, or copy from the file.
```

A tension the user directed you to drop produces no comment — it appears in `## Directions Applied` only.

## Implementer — closing turn

```
## Challenge Complete — {N} tensions, {M} applied · artifact: <run_file>
- {tension title}: {direction taken} → {what changed, plan section or file:line}
- {tension title}: left as proposed — {the reason the user gave}
```

One line per tension, hard cap. Multi-line detail stays in the run file's `## Directions Applied`.

If any tension was left open on purpose and carries real risk, add one line under the list naming the risk that now ships. State it plainly; do not re-argue the decision.
