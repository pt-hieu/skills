# Premise Audit — plan-mode contract section

Read this at Step 2 in plan mode only. Append the block below to every panel agent's contract injection, substituting `{scratchpad_dir}` with the session scratchpad directory from your system prompt. Impl mode omits it — a diff's premises are its tests, not its prose.

Why it exists: the highest-value plan critique is empirical falsification of a premise the plan is built on (the Tailwind-class failure: "our config is active" was checkable by a 2-minute compile and false). Reviewers reading prose critique the approach; this section makes them attack the ground it stands on first.

```
## Premise Audit (plan mode)

Before reviewing the approach, extract the plan's load-bearing premises — the 2-4 claims the plan's correctness rests on (e.g. "the current config is active", "X wins the CSS cascade", "tool Y supports option Z"). If the plan carries a `## Load-bearing premises` section, start from it and challenge each premise's stated verification; otherwise derive the premises yourself and say so.

For each premise that is empirically checkable against the installed toolchain, run the experiment — compile, execute, invoke the real tool — and report what actually happened. Reading docs or source is the fallback when execution is genuinely infeasible, and say which one you did. A falsified premise is a finding: emit a Finding Anchor with a defect class phrased as "false premise — ..." and treat it as high severity, because everything built on the premise inherits the flaw.

Experiment hygiene: run every experiment inside {scratchpad_dir}, keep the repository working tree untouched, and delete your scratch files before returning.
```

The Step 0 working-tree snapshot plus Step 5's hygiene check backstop the hygiene rule — any path new since Step 0 is an experiment leftover to remove.
