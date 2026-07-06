---
name: voice
description: "Use only when drafting outbound team-facing text the user will post on a public/team surface: Slack channel messages, PR announcements/descriptions, Bitbucket PR comments, or Jira comments. Code, code comments, plan files, chat replies to the user, and messages to external recipients (customers, vendors) all stay outside this voice."
---

# Voice

The communication style for outbound team-facing engineering messages. The triggering surfaces and the exclusions are set by the description above; one scope nuance to hold onto — in a chat reply the user is the audience, not the author, so it stays out of voice.

## 0. Readability first (overriding)

Readability outranks every other rule here. Voice serves the reader — when a voice element makes a message harder to scan or parse, soften it.

- **Structure between paragraphs is the priority.** One idea per paragraph, blank line between paragraphs. A long-form post should be scannable top-to-bottom: framing, then the why, then the what, then the ask — each as its own block.
- **Lead with the point, keep the ask findable.** The reader should locate what you want from them without hunting. Give the ask its own line or paragraph.
- **Comma-heavy is fine inside a paragraph, not across one.** Run related clauses together within a thought, but break to a new paragraph when the thought changes — never let a paragraph become an unbroken wall.
- **ESL tells and emoji stay as flavor, never at the cost of comprehension.** If a sentence is hard to follow, fix the clarity first; reintroduce flavor only where it doesn't slow the reader down.

When a voice rule and readability pull in opposite directions, soften the voice element — don't sacrifice the reader.

## Preserve the ESL fingerprint

**ESL tells — preserve, do not auto-correct.** These *are* the voice: `stuffs`, `regardlessly`, `had had` constructions, doubled intensifiers ("very very huge"), occasional preposition drop, "imo"/"imho" used freely, "Lemme" as a natural contraction. If a draft "sounds too polished," reintroduce one of these.

## Anti-patterns

- Open with `Hey folks` / `Hi team`, not `Hello team,` / `Hi everyone,` / `Greetings,` / `Dear team` / `Hi all`.
- Close with `Cheers` (or a sign-off emoji), not `Best regards,` / `Thanks in advance,` / `Sincerely,`.
- Chase a stale PR with `Nudging` / `bump`, not `Just wanted to check in` / `Following up`.
- Preserve the ESL fingerprint rather than "auto-correcting" it.

## Match the message type, then read that section of `references/style-guide.md`

Only one shape fires per message — pick it, then read that section of the full voice spec: PR announcement §D; review nudge §E; multi-paragraph channel share §F; short in-thread reply §G; quote-then-respond §H; worked examples §K. The reference also carries the emoji vocabulary (§C), lexicon (§I), and the full anti-pattern list (§J).
