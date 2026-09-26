# Agent prompts

This covers prompts for an agent that reads data, reaches a judgment, and reports back. The rules in `SKILL.md` still apply; this file adds what such a prompt must ask of the agent.

## Role and task

Name the domain, the method the agent follows, what it is judging, and who reads the result. "You are a reviewer of database migrations; you check each migration for lock duration and rollback safety, and an on-call engineer reads your report before deploying" gives the model a method and a reader. "You are an expert assistant" gives it nothing.

## Hand it computed numbers

Code computes every number: arithmetic, ratios, thresholds, scores, aggregates. The prompt hands the model the results and asks it to interpret them. Arithmetic done by a model reads fluently and is often wrong, and a figure it computes cannot be traced to a source.

Present numbers for reading: round to meaningful precision (`18.2x`, not `18.23456789`), include units, and put the change next to the absolute value (`82.5, up 4.2 from last week`). Group the input by kind (measurements, assessments, surrounding context) so that the signals are not buried.

Put current facts into the context through tools or input data. The model's own knowledge is months old and it does not know which parts are stale.

## What to ask of its reasoning

Ask for each of these in prose, with its reason. Include only the ones the agent's data can actually fail on.

- **Missing data.** When the data behind a claim is missing, stale, zero, or unverifiable, the agent marks it as unconfirmed, says where it looked, and names what would resolve it. A skipped analysis is better than an invented one. Use a literal marker such as `INSUFFICIENT DATA` only if code branches on it.
- **Conflicts.** Before concluding, the agent lists the signals that contradict each other and says how it weighed them. Give it the order of precedence (for example, measured data over reported opinion). A summary like "on balance" comes after that list, not in place of it.
- **The case against.** The agent states the strongest argument against its own conclusion, at its real weight. Models overweight evidence that supports the conclusion they are forming.
- **Confidence with its basis.** "High, because all three sources agree" tells the reader something; "fairly confident" does not. Ask for a fixed HIGH/MEDIUM/LOW scale only when code reads it.
- **Citation.** Each factual claim names the tool or input field it came from, so the reader can check it. A claim the agent cannot trace to a source should be dropped.
- **A verification pass.** After drafting, the agent rereads each claim, traces it to the input, and removes or flags any claim that does not trace.

## Scope of one prompt

Give the agent the whole task with its finish line; Opus 5.5 carries long, multi-part work to the end. Split the job only where something outside the model must happen between stages, such as code computing the numbers the next stage interprets. When the work is large and made of independent units (one service, one file, one vendor each), give each unit to its own subagent, and have the orchestrator check each subagent's evidence before accepting its result.

## Asking for the output

Describe the content you need and the reader it is for, and let the model write it as prose. Set the bar for what is worth reporting, and say what the reader needs for each item in order to act: "List only problems you would block the merge for. For each one, give the file and line, why it is wrong, and how to show it fails." For example:

> Write a short analysis for the on-call engineer who decides whether to deploy. Start with anything they must do before deploying. Say what you recommend and how confident you are, and what that confidence rests on. Give the strongest reason for your recommendation and the strongest reason against it. Cite the input field behind each figure you mention. If signals disagreed, say which ones and how you weighed them. A few paragraphs are enough.

Use a schema only when non-LLM code parses the output. In that case, constrain the values code branches on (an action, a status) to exact enums, and leave the reasoning as free-text fields.

## Diagnosing bad output

- **Vague**: no reader named, no method in the role, or confidence requested without a basis.
- **Stops early or never finishes**: no finish line the agent can check.
- **Reports everything**: no bar for what is worth reporting.
- **Overconfident**: no case against required, or confidence stated without what it rests on.
- **Invented facts or figures**: no path for missing data, the model left to do arithmetic, or current facts expected from its own knowledge.
- **Contradictions smoothed over**: no instruction to list conflicts before concluding.
- **Padded or rigid**: a schema or template imposed on output that only an LLM or a person reads.
