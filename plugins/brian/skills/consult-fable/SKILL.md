---
name: consult-fable
description: "Use to get Fable's read on something hard — Brian asked what Fable thinks of a design, a diagnosis, a plan, or a question you are sitting on, or you want a second read on one of your own. Spawns one consultant per question, in parallel when there are several; the answer is advice, not binding. Only for the outer session talking to the user directly — a subagent surfaces the question to its orchestrator instead. To stress-test a plan you have already settled on, use challenge instead."
---

## Step 1: Frame the question

Write the question in one sentence before you launch anything. Anything hard is fair game — a design you are unsure of, a diagnosis that does not fully explain the symptom, a plan you want read by someone who was not in the room, a choice you keep re-opening.

Decide alone when the answer is reversible by editing and re-running and you are not actually in doubt — naming, local structure, which of two equivalent helpers to reuse, formatting, test placement. A consultation is worth its turnaround when a second read could change what you do next; it is waste when you already know what you are going to do and want company.

**Only from the outer session.** Consult Fable when you are the session talking to Brian directly. A subagent surfaces the question to its orchestrator and lets the orchestrator decide, because a subagent cannot answer for what happens next and nobody is watching its transcript. Inside `autopilot` there is no consultation at any level, including the outer orchestrator: that run is `no-human-in-the-loop` by design (`autopilot/SKILL.md`, opening line), so advice would surface to nobody until the PR, and autopilot's own T2 eligibility gate is what should fire on a decision it cannot make (`autopilot/references/task-specs.md` § **T2 — Assumptions register**).

## Step 2: Consult

Launch one `brian:fable-consultant` per question via the `Agent` tool. Do not pass `model` — the pin lives in the agent's frontmatter. When you have more than one question, send every consultant in a single message so they run concurrently, and let each one see only its own: a consultant asked to settle three questions at once hedges across all three, which is the outcome this skill exists to avoid.

The agent is deliberately generic, so each prompt casts its own consultant — the engineer you would actually walk this over to, whether that is someone who lives in the data model, the permissions boundary, or the deploy path. Name that expertise in the prose and say why this question wants it. Pick the expertise from the question, not from the answer you are hoping for; stacking consultants who would all say the same thing buys agreement rather than judgement.

Write the prompt as prose, not a form. Fable does better work when it is given the reason behind a request and left to choose its own route, so state the goal and the situation rather than a procedure. Cover:

- **What you want a read on**, as one question. When the question genuinely has options, name them and say what makes each live; when it does not, do not invent branches to make it look like a decision.
- **Why you are asking** — what prompted it, and what you plan to do with the answer.
- **What you already checked, and what you already believe.** Say how sure you are, plainly. This keeps the consultation from redoing your legwork, and Fable's most useful move is disagreeing with you, which it can only aim at a position you stated.
- **What a bad answer costs** — how far the work would travel before a wrong read showed up, and whether anything here is hard to undo: a shipped schema or migration, a published contract other code already calls, a security boundary, data you cannot regenerate.
- **The constraints that bind** — requirements, existing callers, policies, with their sources.
- **Where the code lives** — the paths worth reading, while leaving Fable free to read others.

When prior intent matters, run `brian:code-historian` (sonnet) first and attach its report. Fable has no `Bash` and cannot read git history itself — that exclusion is deliberate, and this is the substitute.

**Follow-ups go back to the same consultant.** Continue the consultation with `SendMessage` to the consultant you already have, so it keeps everything it read and everything you told it; do not spawn a fresh one and re-explain. Do not spawn a second consultant on the same question hoping for a different answer — when Fable has weighed in, the next move is yours, even if you dislike the answer.

## Step 3: Persist, then surface

Append Fable's whole return to `{scratchpad}/consult-fable-{topic-slug}.md` **before** reporting it — one file per consultation, named for its question, so a reader can follow one thread without untangling it from the others. Persistence survives compaction, and because the file holds the full return, a reader can check what reached chat against what was actually advised.

In the same turn you report back, cover each consultation separately: Fable's read, the push-back it gave you, and what you are doing with it. Carry the push-back across even when you disagree with it, and especially when you had already decided otherwise — a read that only confirms you is the one worth reporting most carefully, because it is the one you had the least reason to check. Departing from the advice is a legitimate outcome; it costs one honest sentence naming what you know that Fable did not, or which of Fable's premises does not hold here.

This obligation is self-enforced: nothing checks it, which is exactly why reporting only the half of the advice that agrees with the plan already in motion is the failure to watch for in yourself.

**When Fable declines to answer and names what it would need instead**, the question stays open: fetch what it named and go back to the same consultant with the gap closed. If it declines again, or the evidence it named does not exist, this is not a question Fable can settle — answer it yourself, and record in one sentence what was missing so the next person here does not spend two consultations rediscovering it.

**When a consultation returns nothing usable** — an error, an empty return, or a refusal — say so in one sentence, name what you are doing instead, and proceed. A question that could not be consulted is still yours to answer, and an unmentioned failed consultation is the same omission as an unmentioned disagreement. When consultants ran in parallel, one failing says nothing about the others: report the failure against its own question and take the rest at their word.

## It's working if

- Every consultation appears in the transcript as a written question before it is launched.
- Routine choices in the same session were decided without a consultation.
- Each consultant was given one question and an expertise chosen to fit it, and concurrent consultants went out in one message.
- Fable's push-back reaches chat even when you are not acting on it.
- One consultation file per question sits in the scratchpad, and what is reported in chat matches what it records.
- Follow-ups continued the same consultant rather than spawning a new one.
