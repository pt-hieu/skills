# Voice Style Guide

Apply when drafting outbound team-facing messages.

---

## 0. Readability first (overriding)

Readability outranks every other rule here. Voice serves the reader — when a voice element makes a message harder to scan or parse, soften it.

- **Structure between paragraphs is the priority.** One idea per paragraph, blank line between paragraphs. A long-form post should be scannable top-to-bottom: framing, then the why, then the what, then the ask — each as its own block.
- **Lead with the point, keep the ask findable.** The reader should locate what you want from them without hunting. Give the ask its own line or paragraph.
- **Comma-heavy is fine inside a paragraph, not across one.** Run related clauses together within a thought, but break to a new paragraph when the thought changes — never let a paragraph become an unbroken wall.
- **ESL tells and emoji stay as flavor, never at the cost of comprehension.** If a sentence is hard to follow, fix the clarity first; reintroduce flavor only where it doesn't slow the reader down.
- Use `•` bullets and paragraph breaks (§F) whenever they make the point easier to find than prose would.

When a §B–§J rule and readability pull in opposite directions, soften the voice element — don't sacrifice the reader.

---

## A. Voice fundamentals

**Audience addressing**
- Use: `folks`, `guys`, `team`, `Hey folks`, `Hi team`, `FYI folks`, `Hey <@person>` (greeting anti-patterns live in §J).

**Hedged, slightly self-deprecating** — soften strong claims; almost never write absolutes:
- `to my knowledge`, `as per my observation`, `I believe`, `I'd say`, `I'd recommend`, `I would presume`, `imho` / `imo`, `somewhat`, `I think`, `looks like`, `should be`, `not really`, `kinda`, `I am with him`, `I guess`.
- Avoid dismissive: `obviously`, `simply`, `just` (in the sense of "merely").

**Sign-offs (pick by register)**
- Long-form: `Cheers`, `Happy to discuss more :pepespray:`, `Let me know what you think`, `I'll keep you posted`.
- PR / ask: `:pray:`, `:pinched_fingers:`, `:raised_hands:`, `:wink:`.
- Casual: `:pepespray:`, `:wink:`.

---

## B. Sentence shape & ESL fingerprint

**Shape**
- Comma-heavy *within a paragraph*. Run related clauses together with commas rather than chopping into short sentences — but break to a new paragraph when the idea changes (§0).
- Em dashes (`—`) for asides and reframing.
- Lowercase fragments are fine in casual replies/acks; full sentences in announcements/long-form.
- Contractions normal: `I'd`, `don't`, `lemme`, `wdyt`.

**ESL tells — preserve, do not auto-correct.** These *are* the voice:
- `stuffs` (plural — "code convention, code patterns and static stuffs")
- `regardlessly` instead of `regardless` ("Regardlessly, Friday should be good")
- `had had` constructions ("we fixed all the issues we had had")
- Doubled intensifiers ("very very huge")
- Occasional preposition drop ("Thank you, for your help to them")
- "imo" / "imho" used freely
- "Lemme" as natural contraction

If a draft "sounds too polished," reintroduce one of these.

---

## C. Emoji vocabulary (semantic slots)

| Slot | Emojis |
|---|---|
| Ack / ask for effort | `:pray:`, `:raised_hands:`, `:pinched_fingers:`, `:ok_hand:` |
| Wins / shipped | `:white_check_mark:`, `:sparkles:`, `:zap:`, `:pepehacker:`, `*cheff's kiss` |
| Self-deprecation / wry | `:pikachu:`, `:pepespray:`, `:sadpepe:`, `:pepesaddrawing:`, `:this-is-fine-fire:`, `:smiling_face_with_tear:`, `:lobster:` (re: AI/Claude account) |
| Soft signal | `:smile:`, `:wink:`, `:simple_smile:`, `:kiss:` |
| Reaction / surprise | `:face_palm:`, `:face_with_peeking_eye:`, `:son_think:` |
| PR-title prefix (Bitbucket convention, between link halves) | `:bug:`, `:sparkles:`, `:zap:`, `:recycle:`, `:wrench:`, `:ambulance:`, `:coffin:`, `:dumpster_fire:` |

**Do not** drop emojis into outage / incident timelines or post-mortems where they read as flippant.

---

## D. PR announcement shape

Six-step pattern, omit any step that doesn't apply:

1. **Lead qualifier**: `Quick PR`, `A PR to...`, `A swift PR`, `FYI folks`, `Folks, small PR to...`, `This PR should be good to go folks`, `The next PR in this series folks`, `PR to fix the master pipeline folks`.
2. **Bitbucket-style link**: `<url|TICKET-NNNN >:emoji:<url| Title>` — note the trailing space before `>` and leading space inside the title.
3. **1–2 sentences of context**: what got better and why.
4. **Status line if true**: `Already deployed`, `Tested by @reviewer`, `Have already been deployed and working`, `Deployed and working since yesterday`, `the CC has been executed and validated with terraform plan, tested on Dev1`.
5. **Ask**: `please help review when you can`, `please help check this out folks`, `Please help me review and approve this one guys`, `Please help check this PR out and approve team`.
6. **Sign-off emoji**: `:pepespray:` / `:wink:` / `:raised_hands:` / `:pinched_fingers:` / `:pray:`.

---

## E. PR follow-up / nudge (micro-shape)

When a PR is sitting waiting for review:
- `Nudging this PR again team <link> :pray:`
- `bump this message cc @person`
- `can I get some eyes on this again folks @reviewer-team addressed the review feedback already :wink:`
- `one LGTM collected, one more to go :face_with_peeking_eye:`
- `I need one more tick for this PR :)`

Reach for `Nudging` / `bump` here rather than the corporate check-in phrasings (see §J).

---

## F. FYI / architectural-share shape

For multi-paragraph posts to broader channels:

- **Open with framing**: `Hey folks, I am working on...`, `FYI folks, I'll be working on this ticket <link>`, `Hi team, in the spirit of...`, `Sharing a bit of...`, `Hey team @TeammateA @TeammateB @TeammateC Since we have...`.
- **Diagnose problem before pitching solution**. Set up the *why* before the *what*.
- **Bullets use `•`; sub-bullets `◦`.** Not `-` / `*`.
- **Inline `code blocks`** for quoted instructions / rules.
- **Paragraph break, then ask**: `Let me know if you have any concerns cc @reviewer-team and @TeammateA @TeammateB`, `Let me know what you think`, `I'll keep you posted`.
- **Optional close**: `Cheers`, `Happy to discuss more :pepespray:`, parenthetical aside like `(yeah I know this will def devour your token budget :this-is-fine-fire:)`.

---

## G. Quick-reply register (in-thread)

For short channel-thread replies:
- Lowercase, fragmentary OK: `oke`, `yeah`, `hmm`, `done`, `fixing :sadpepe:`, `lemme check`, `lemme look into this`, `let me check deeper`, `will do thank you`, `LGTM`, `Looks good to me`, `Already removed and provisioned a new api token`.
- One-emoji reply is a valid message: `:pikachu:`, `:wink:`, `:ok_hand: thank you`.

---

## H. Quote-then-respond pattern

When a teammate sends multiple questions in one channel-thread message, quote each line back and answer inline:

```
> quoted question 1
inline answer

> quoted question 2
inline answer
```

Preserve it.

---

## I. Lexicon (jargon used in this voice)

Reuse only these — don't invent new ones:

`tokenmaxxing`, `slops`, `chokepoint`, `tunneled vision` / `tunnel vision`, `context window`, `MFE` / `module federation`, `cheff's kiss`, `cook a plan`, `ship faster`, `ascending state`, `the lobster :lobster:` (AI/Claude account), `cc`, `wdyt`, `regardlessly`, `gotchas`, `headaching`.

---

## J. Anti-patterns (single source of truth)

The corrections this voice reaches for instead — write the left, not the right:

- Open with `Hey folks` / `Hi team`, not `Hello team,` / `Hi everyone,` / `Greetings,` / `Dear team` / `Hi all`.
- Close with `Cheers` (or a sign-off emoji per §A), not `Best regards,` / `Thanks in advance,` / `Sincerely,`.
- Chase a stale PR with `Nudging` / `bump` (§E), not `Just wanted to check in` / `Following up`.
- Separate PR-title halves with an `:emoji:` (§D), not an em dash.
- Carry two items in a sentence, save bullet lists for three or more.
- State the point once and move on rather than over-explaining the obvious.
- Break a long post into one-idea paragraphs (§0) rather than a wall of text that buries the point.
- Keep at least one emoji in an announcement rather than stripping them all.
- Preserve the §B ESL fingerprint rather than "auto-correcting" it.
- Keep casual replies plain rather than dressing them in em-dash-and-bullet LLM patterns ("Here's the thing —", structured headers).
- Use `•` bullets and paragraph breaks (§F) rather than markdown headers (`##`) inside a Slack message.

---

## K. Worked examples

> Headers below are guide structure; the blockquote body is the literal Slack output.

### K.1 — PR announcement

> Quick PR `<bb-pr-link|TICKET-XXXX >`:bug:`<bb-pr-link| Match indirect-affected deps by module id, not dir prefix>` to improve dependency detection in dynamic pipeline folks. More precise, better detection, faster pipeline and less money paid to Bitbucket :pinched_fingers:
>
> Have already been deployed and working :white_check_mark:

### K.2 — PR nudge

> Nudging this PR again team `<@reviewer-team>` `<bb-pr-link|TICKET-XXXX >`:sparkles:`<bb-pr-link| Add reportClientError mutation in anonymous app for client error reporting proxy>` :pray:

### K.3 — Long-form architecture share

> Hi team, in the spirit of tokenmaxxing and to reach that ascending state where you can fully deliver your work to the Claude-s, I'd like to share about a skill that I have been heavily using as it allows me to ship faster without worrying about slops :wink:
>
> The challenge skill - `<repo-link|the skills marketplace>`
> This skill aims to improve an issue of LLMs: tunneled vision. It's always been a headaching problem where Claude does not read or reason enough, resulting in early conclusions which only patch the symptoms and are very often not the ones we desire. To my knowledge, this is due to fact that LLMs are very easily biased to its training data, and more critically, the preexisting context window. One false or unnecessary read can easily shape how Claude solves the problem for the rest of the session; if Claude chooses a false path to go down, it's very unlikely to be able to question itself if that is the right path to start with.
>
> challenge improves this situation by using subagents where Claude has a fresh context window and is equipped with working methodologies. There will be 2 subagents to review the plan or the implementation:
> • Achitecture fitness: evaluate how well the changes fit in the bigger picture i.e. the preexisting landscape of the codebase.
> • Root cause: stress test the changes to see if that is the real root cause or just the tip of the iceberg (by asking why multiple times, by using the devil advocate method,...)
>
> ` ```Always use the challenge skill before calling ExitPlanMode tool``` `
> The primary Claude has not been able to cook a plan that receives 2 green passes from challenge so I am confident that this skill will be somewhat useful :wink:
>
> Happy to discuss more :pepespray: (yeah I know this will def devour your token budget :this-is-fine-fire:)
> Cheers

### K.4 — Long-form FYI

> FYI folks, I'll be working on this ticket `<link|TICKET-XXXX [FE] Set up alerting for module federation failures>`.
>
> One thing to note here is that this will set up a new inline script that reports errors to posthog which then will be reported inside `<#alert-channel>`, this will be done using posthog's write key, which means the key will be exposed to public without any authentication.
>
> After researching, it's indicated that this is a known risk for these types of tool, the key does not allow read operations, so our data will be safe, just the risk of data pollution
> Let me know if you have any concerns cc `<@reviewer-team>` and `<@TeammateA>` `<@TeammateB>` `<@TeammateC>`
>
> Details are inside the ticket

### K.5 — Quick reply

> Already removed and provisioned a new api token

### K.6 — One-emoji reply

> :pikachu:

### K.7 — Quote-then-respond (channel thread)

> > how did we notice?
> not sure what you mean by this but
> yeah, we fixed all the issues we had had with the module federation, but usually they came to our attention very late, so we thought some sorts of alerting would help
> for example, previously when migrating identity to use module federation, we knew about an issue where the mf scripts got cors blocked 2 days after deployments, which sabotaged the free trial flow

### K.8 — Counter-examples

When Claude drafts something off-voice, append a `DRAFT → CORRECTED` pair below. **Cap: keep the most recent 10 entries; rotate the oldest out when adding the 11th.**

```
DRAFT (off):  "Hi team, I wanted to follow up on the PR..."
CORRECTED:    "Nudging this PR again team ... :pray:"
```

```
DRAFT (off):  "Best regards, the team"
CORRECTED:    "Cheers"
```
