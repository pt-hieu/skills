---
name: consult-fable
description: "Use to get Fable's read on something hard — Brian asked what Fable thinks of a design, a diagnosis, a plan, or a question you are sitting on, or you want a second read on one of your own. Spawns one consultant per question, in parallel when there are several; the answer is advice, not binding. Only for the outer session talking to the user directly — a subagent surfaces the question to its orchestrator instead. To stress-test a plan you have already settled on, use challenge instead."
---

`consult-fable` puts one hard question in front of one Fable consultant and brings the whole answer back to Brian, the push-back included. The answer is advice: departing from it is a legitimate outcome, and hiding it is not.

## The result

For each question consulted:

- **On disk**: Fable's whole return in `{scratchpad}/consult-fable-{topic-slug}.md`, one file per question, written before anything is reported. The file survives compaction, and it lets a reader check what reached chat against what was advised.
- **In chat**, each consultation covered separately: Fable's read, the push-back it gave you, and what you are doing with it. The push-back is carried across even when you disagree with it, and especially when you had already decided otherwise: a read that only confirms you is the one you had the least reason to check. Departing from the advice costs one sentence naming what you know that Fable did not, or which of Fable's premises does not hold here.

Nothing checks the chat report against the file. Reporting only the half of the advice that agrees with the plan already in motion is the failure to watch for in yourself.

## What is worth a consultation

Anything hard: a design you are unsure of, a diagnosis that does not fully explain the symptom, a plan you want read by someone who was not in the room, a choice you keep re-opening. A consultation is worth its turnaround when a second read could change what you do next.

Decide alone when the answer is reversible by editing and re-running and you are not in doubt: naming, local structure, which of two equivalent helpers to reuse, formatting, test placement. Consulting when you already know what you are going to do buys company, not judgement.

**Only from the outer session.** Consult Fable when you are the session talking to Brian directly. A subagent surfaces the question to its orchestrator, because a subagent cannot answer for what happens next and nobody is watching its transcript. Inside `autopilot` there is no consultation at any level, the outer orchestrator included: that run has no human in the loop, so advice would surface to nobody until the PR, and the assumptions register in `autopilot/SKILL.md` is what handles a decision the run cannot make.

## The consultant

Each question gets its own `brian:fable-consultant`, launched with the `Agent` tool and no `model` argument, because the pin lives in the agent's frontmatter. Several questions go out in one message so they run concurrently, and each consultant sees only its own: a consultant asked to settle three questions hedges across all three.

The agent is generic, so each prompt casts its consultant: the engineer you would walk this question over to, whether that is someone who lives in the data model, the permissions boundary, or the deploy path. Name that expertise and say why this question wants it. Pick it from the question, not from the answer you are hoping for.

The prompt is prose that states the goal and the situation and leaves the route to Fable. It carries:

- **What you want a read on**, as one question. When the question has real options, name them and say what makes each live; when it has none, invent none.
- **Why you are asking**: what prompted it, and what you plan to do with the answer.
- **What you already checked and what you already believe**, with how sure you are. Fable's most useful move is disagreeing with you, and it can only aim at a position you stated.
- **What a bad answer costs**: how far the work would travel before a wrong read showed up, and whether anything is hard to undo, such as a shipped schema or migration, a published contract other code calls, a security boundary, or data you cannot regenerate.
- **The constraints that bind**: requirements, existing callers, policies, with their sources.
- **Where the code lives**: the paths worth reading, with Fable free to read others.

Fable has no `Bash` and cannot read git history; that exclusion is deliberate. When prior intent matters, the prompt carries a `brian:code-historian` (sonnet) report.

One consultant answers each question. A follow-up goes to that same consultant with `SendMessage`, so it keeps everything it read and everything you told it. When Fable has weighed in, the next move is yours, even if you dislike the answer; a second consultant on the same question is a search for agreement.

## When there is no answer

- **Fable declines and names what it would need.** The question stays open: fetch what it named and go back to the same consultant. If it declines again, or the evidence it named does not exist, answer the question yourself and record in one sentence what was missing, so the next person does not spend two consultations rediscovering it.
- **The consultation returns nothing usable** (an error, an empty return, a refusal). Say so in one sentence, name what you are doing instead, and proceed. A failed consultation left unmentioned is the same omission as an unmentioned disagreement. One parallel consultant failing says nothing about the others.

## Verify

- Each question appears in the transcript as one written sentence before its consultant was launched.
- Each consultant got one question and an expertise chosen to fit it, and concurrent consultants went out in one message.
- One file per question sits in the scratchpad, and what chat reports matches what the file records, push-back included.
- Follow-ups continued the same consultant.
- Routine choices in the same session were decided without a consultation.
