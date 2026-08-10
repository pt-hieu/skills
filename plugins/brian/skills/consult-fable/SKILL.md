---
name: consult-fable
description: "Use at a fork you have named but cannot settle — two or more live branches where your own legwork ran out, or where a wrong branch is a one-way door (shipped schema, published contract, security boundary, unrecoverable data). Spawns one Fable consultation per gated fork — several forks means several consultants, run in parallel; the recommendation is advice, not binding. Only for the outer session talking to the user directly — a subagent surfaces the fork to its orchestrator instead. To stress-test a plan you have already settled on, use challenge instead."
---

## Step 1: Name each fork, and check the gate

**Name the fork first, and name it as two branches you can argue.** Write it as one question with two or more branches, each stated in one sentence. Nameable is not enough — you must be able to argue the losing branch on the material in front of you. An irreversible change whose branch is already settled by a constraint on the table is not a fork: the schema follows from a stated requirement, the signature follows from an existing caller, the boundary follows from a documented policy. Write that constraint in one sentence **and cite where it comes from** — a quoted requirement, an existing caller at `file:line`, a named policy. A constraint you cannot point at is not on the table; it is your own confidence in other clothes, and this test does not accept it. When you cannot argue the losing branch, you are not at a fork — decide and move on.

With a fork named, check the door before you check yourself. **The door swings one way** when a wrong branch is undone by more than an edit in this session: a shipped schema or migration, a published contract other code already calls, a security or permissions boundary, data you cannot regenerate. This test never consults your confidence, which is why it still fires when your confidence is wrong — feeling sure is not an exemption. Given a named fork, a one-way door is sufficient on its own; on its own it does not manufacture a fork out of irreversible routine work.

**The evidence ran out** is the secondary test, and it is self-reported: you did the legwork that should have settled it and can still argue each branch with the same material. Because it depends on judging your own certainty, it will under-fire exactly when you most need it.

Decide alone when the fork is reversible by editing and re-running — naming, local structure, which of two equivalent helpers to reuse, formatting, test placement, anything you would fix in the next commit without a migration.

**A situation can hold more than one fork, and each one earns its own gate.** Run the tests above on every fork separately and keep only the ones that pass; a fork that rides in on a neighbour's one-way door was never gated. Two forks that collapse into a single decision — where settling one settles the other — are one fork, so name them as one. How many forks survive this is your judgement, and the honest answer is often one.

**One escalation path per situation, and only from the outer session.** Consult Fable only when you are the session talking to Brian directly. A subagent surfaces the fork to its orchestrator and lets the orchestrator decide, because a subagent cannot answer for the disposition and nobody is watching its transcript. Concretely: inside a `challenge` run, Step 4 already puts every design gap to Brian as a decision with options and a recommendation, so a consultation would duplicate the gate the skill exists to reach; inside `autopilot`, no consultation at any level — including the outer orchestrator. That run is `no-human-in-the-loop` by design (`autopilot/SKILL.md`, opening line), so advice would surface to nobody until the PR. Autopilot already routes this case: T2's eligibility gate halts the run on an assumption that is low-confidence *and* high-blast-radius, "naming the coin-flip decision" (`autopilot/references/task-specs.md` § **T2 — Assumptions ledger**) — which is a fork under another name. Let that gate fire.

**One fork, one consultation** — apart from a single re-ask that closes a gap Fable itself named. When Fable has weighed in on a fork, the next move is yours, even if you dislike the answer. The budget is per fork, not per session: three gated forks earn three consultations, and none of them earns a second.

## Step 2: Consult

Launch one `brian:fable-consultant` per gated fork via the `Agent` tool. Do not pass `model` — the pin lives in the agent's frontmatter. When more than one fork survived Step 1, send every consultant in a single message so they run concurrently, and let each one see only its own fork: a consultant asked to settle three questions at once hedges across all three, which is the outcome this skill exists to avoid.

The agent is deliberately generic, so each prompt casts its own consultant — the engineer you would actually walk this fork over to, whether that is someone who lives in the data model, the permissions boundary, or the deploy path. Name that expertise in the prose and say why this fork wants it. Pick the expertise from the fork, not from the branch you are hoping for; stacking consultants who would all favour the same branch buys agreement rather than judgement.

Write the prompt as prose, not a form. Fable does better work when it is given the reason behind a request and left to choose its own route, so state the goal and the situation rather than a procedure. Cover:

- **The fork** as one question with its branches, exactly as you named it in Step 1.
- **Why this fork exists** — what made the choice arise at all.
- **What you already checked, and why it left the fork open.** This is what keeps the consultation from redoing your legwork.
- **What a wrong branch costs** — the specific door that swings one way.
- **The constraints that bind** — requirements, existing callers, policies, with their sources.
- **Where the code lives** — the paths worth reading, while leaving Fable free to read others.

When prior intent matters to the fork, run `brian:code-historian` (sonnet) first and attach its report. Fable has no `Bash` and cannot read git history itself — that exclusion is deliberate, and this is the substitute.

## Step 3: Persist, then surface

Append Fable's whole return to `{scratchpad}/consult-fable-{fork-slug}.md` **before** reporting it — one file per fork, named for that fork, so a reader can follow a single decision without untangling it from the others. Persistence survives compaction, and because the file holds the full return, a reader can check what reached chat against what was actually advised.

In the same turn you report back, cover each fork separately: what Fable recommended, the strongest case Fable made against itself, and your own disposition — following the advice, or departing and precisely why. Departing is a legitimate outcome; it costs one honest sentence naming what you know that Fable did not, or which of Fable's premises does not hold here. This obligation is self-enforced: nothing checks it, which is exactly why reporting only the half of the advice that agrees with the plan already in motion is the failure to watch for in yourself.

**When Fable declines to recommend and names what it would need instead**, the fork stays open: fetch what it named and consult once more with the gap closed. That is the only re-ask. If the second consultation also declines, or the evidence it named does not exist, this is not a fork Fable can settle — decide it, and record in one sentence what was missing so the next person at this fork does not spend two consultations rediscovering it.

**When a consultation returns nothing usable** — an error, an empty return, or a refusal — say so in one sentence, name the branch you are taking, and proceed. A fork that could not be consulted is still your decision to make, and an unmentioned failed consultation is the same omission as an unmentioned disagreement. When consultants ran in parallel, one failing says nothing about the others: report the failure against its own fork and take the rest at their word.

## It's working if

- Every fork appears in the transcript as a written question with named branches, before any consultation.
- Routine choices in the same session were decided without a consultation, and no fork sentence was written for them.
- A one-way-door fork triggers the gate even when you felt confident about the branch.
- Each consultant was given one fork and an expertise chosen to fit it, and concurrent consultants went out in one message.
- For every fork, Fable's recommendation, its counter-case, and its flip condition all reach chat — not only the half that agrees with the plan already in motion.
- One consultation file per fork sits in the scratchpad, and the disposition reported in chat matches what it records.
- No fork is consulted twice, apart from one re-ask that closes a named gap.
