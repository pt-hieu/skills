---
name: diagnose
description: "Use when investigating bugs, reviewing fixes, running post-incident analysis, or verifying a fix lands on root cause rather than a symptom."
---

# Diagnose

`diagnose` keeps digging past the first plausible cause until it reaches bedrock, and proves that cause with a reproduction that fails because of it. A cause you cannot make fail on demand is a hypothesis; the reproduction is what turns it into a finding.

## The result

One line each, so the answer reads at a glance:

- **Root cause**, at bedrock: an explicit design decision (cite where it was made), an external constraint, a missing abstraction nobody has built, or the point where asking "why does this exist?" only circles back. Anything short of that is an intermediate cause, and a fix aimed at it is a patch.
- **Defect class**: the pattern in plain words, free of this instance's names ("external input reaches a DB query unvalidated", not "handleSearch doesn't sanitize"). The class is what you grep for siblings with.
- **Where the fix lands** on the chain: at the root, or at an intermediate cause, and in that case what the root-level fix would be.
- **Reproduction**: `path::test name` or the command, or `UNABLE TO REPRODUCE — why, and what would make it possible`.
- **Sibling instances**: every `file:line` that shares the defect class.
- **Confidence**, only when it is low or contested, plus a one-line suggestion when one helps.

Show the full reasoning when the user asks to see the work. When an orchestrator such as `brian:kickoff` or `brian:autopilot` hands you its own output shape, use that shape.

## How to know it is right

The reproduction is the check, so build it before committing to a hypothesis. A guess made without one becomes the thing you defend.

- **Investigating**: find the cheapest command that shows the failure on demand. Prefer a test in the existing harness. When no test fits, use a curl call, a script, a headless browser run, or `git bisect run`. It must fail *because of* the named cause and pass once that cause is removed. If it fails for another reason, the chain is wrong. For an intermittent failure, raise the reproduction rate (loop it, run it in parallel, add load) rather than chasing a clean one-shot.
- **Reviewing a fix**: the diff must carry a regression test that reaches the named cause and would have failed before the fix. A missing test is a high-severity finding.
- **Cannot reproduce** (prod-only data, hardware, missing infrastructure): say so on the Reproduction line, and confidence stays low.

Then ask three questions of the root cause. Each "yes" means you have not reached it yet:

1. With this cause gone, could the symptom still arise by another path?
2. Fixing only this cause, could the same defect class recur somewhere else? Then the root is a missing systemic control.
3. Do the intermediate causes still need fixes of their own? Then the chain branches and you have mapped only one branch.

Finally, argue honestly that your root is one more intermediate cause. If evidence cannot refute the argument, dig deeper or lower your confidence.

Every claim cites a `file:line`, a grep result, a test run, or a commit, because the reader acts on the conclusion without redoing the trace. Drop any claim you cannot cite.

## Prior intent

When the cause might be a deliberate decision, spawn `brian:code-historian` (sonnet) on the implicated paths: commits and tickets often name the decision outright, and a reverted earlier fix is an alternative explanation to rule out. An empty history is itself a signal that the root is a missing abstraction.

## Done

The work is done when:

- the reproduction fails on the cause and passes without it, or UNABLE TO REPRODUCE is stated;
- all three questions come back "no";
- siblings were searched by the class pattern, not by this instance's code;
- every debug log and scratch harness you added is gone.
