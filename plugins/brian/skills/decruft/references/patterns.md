# Cruft patterns

Four groups. "Signals" rows are greppable; run them over the inventory rather than eyeballing. Every applied edit must cite one row here plus a reason grounded in the target model's behaviour (see *Target-model facts* at the end).

## Group 1 — Dated prompt text

### 1a. Pressure language — say exactly what you mean, at normal volume

Older, less steerable models needed forcefulness; current models are highly responsive to the system prompt, so the same text over-applies. This cuts both ways: inflated emphasis causes over-triggering and rigid behaviour, while leftover hedges ("try to", "if possible") are read literally as permission to under-deliver.

| Written for older models | Current models |
| --- | --- |
| `CRITICAL: You MUST use this tool when...` | `Use this tool when...` |
| `IMPORTANT: NEVER do X` (several per prompt) | State the one or two real constraints plainly, with the reason |
| `If in doubt, use [tool]` / `Default to [tool]` | Delete, or: `Use [tool] when it would improve X` |
| `Be thorough. Do not be lazy. Do not stop early.` | Delete — current models are proactive by default |
| `Try to include a summary if possible` (when it is required) | `Include a summary.` |
| `You have a tendency to over-X, so...` / `Don't be too verbose` | State the desired behaviour: `Keep responses to the length the question needs.` |

When several instructions are each marked critical, the markers stop carrying information, and the prompt's register becomes the output's register: an anxious prompt produces a cautious, hedging model. Emphasis is not banned; it is a tested, scoped fix for one demonstrably underweighted instruction, not a default register.

Signals: density of `MUST|NEVER|ALWAYS|CRITICAL|IMPORTANT` in caps; `!!`; emphasis with no adjacent "because"; `try to|if possible|ideally` attached to actual requirements; `you (tend to|often|sometimes)` trait claims; `don't be too [adjective]`.

### 1b. Scaffolds replaced by API features — replace, don't rewrite

These are swapped for the feature that replaced them, not tuned down.

| Scaffold in the prompt or request code | Replacement |
| --- | --- |
| "Think step by step", `<scratchpad>` / `<thinking>` tag instructions | Adaptive thinking (`thinking: {type: "adaptive"}`) plus effort. On thinking models the incantation is redundant at best; control depth via configuration, not prose. |
| "Use the think tool to plan" / "plan before acting" | Delete — current models plan without being told, and these cause over-planning. If behaviour is still too aggressive after cleanup, lower effort rather than adding prose. |
| "Show your thinking" / required reasoning sections in the output | Read thinking blocks via the API. On Claude Fable 5.1, instructing reasoning reproduction can trigger a refusal (reasoning extraction). |
| Assistant-turn prefill (`{"role": "assistant", "content": "{"}`) and the JSON-forcing stack around it: stop sequences, regex extraction, retry-on-parse loops, "output ONLY valid JSON" | Structured outputs (`output_config.format`). Prefill returns 400 on 4.6-and-later Opus and Sonnet tiers and on Claude Fable 5.1; where it errors, the surrounding code is cruft too — fix the request builder, not just the prompt string. Only a trailing assistant turn is a prefill (a few-shot block ending on the assistant side counts); assistant turns mid-array are conversation history and stay. |
| "Summarize progress every N tool calls"; hard word caps (`at most N words`) | Delete and re-baseline: current models narrate appropriately, and output caps starve reasoning on hard problems. Prefer qualitative length guidance ("be concise") over numeric caps. |
| Inline lookup tables, point systems, arithmetic rubrics the model must compute | Data in files or tool results; arithmetic in code. Leave the model the judgement layer. |
| `budget_tokens`, non-default `temperature` / `top_p` / `top_k`, stale beta headers, dead 400-retry paths | See *Target-model facts*. Where a parameter errors, the retry or workaround code around it is removable too. |
| Forced tool use — `tool_choice: {type: "any"}` / `{type: "tool", name: ...}` — and JSON-via-forced-tool | A prompt instruction naming the tool under `tool_choice: auto` (steering), or structured outputs (extraction). Returns 400 on Claude Fable 5.1 / Mythos 5.1; elsewhere it works but is usually a prompt instruction in disguise (`strict: true` keeps the schema guarantee under `auto`). Fix the retry-on-missing-tool loop around it as well. |

Signals: `think step by step|take a deep breath`; `<scratchpad>|<thinking>` in instructions; `stop_sequences` guarding JSON; `json.loads` inside retry loops; `budget_tokens|temperature|top_p` in request code; `every \d+ (tool calls|messages)`; `at most \d+ (words|sentences)`.

### 1c. Over-specification — describe the goal, not the method

| Pattern | Why it is cruft now | Fix |
| --- | --- | --- |
| Step-by-step choreography for judgement tasks (`STEP 1: ... STEP 2: ...`) | Prescriptive scripts written for prior models degrade output on current ones; the model's own plan usually beats a hand-written script | State outcomes, constraints, and how to verify; keep numbered steps only where order truly matters |
| Prohibition lists ("do not X, never Y, avoid Z...") | Describing success beats enumerating failure; a prohibition against a failure the model was not going to make can anchor it toward that failure | Keep prohibitions whose failure reproduces on the target model; rewrite the rest as positive statements of intent |
| Example over-indexing: the single gold output; stale few-shot blocks | Examples are the strongest signal in a prompt — the model matches their length, tone, and structure — so examples written for an older model freeze that model's behaviour into the new one | Several deliberately varied examples, labelled illustrative; delete examples of judgement the model already owns; keep examples that pin a genuinely format-sensitive shape |
| Bullet walls and heavy formatting for behavioural guidance | Bullets flatten priority and sever rules from reasons, and prompt format bleeds into output format | Structure for reference data; prose for behaviour, carrying the "because" |
| Padding: generic virtues ("be accurate, thorough, clear"), repetition as reinforcement, kitchen-sink edge cases, limits with escape hatches | The model treats everything as actionable; asides get applied where they do not fit; duplicated rules cost reconciliation effort and inflate adaptive-thinking spend | Say it once, in the right place; cover the hard judgement calls instead of the easy parts |
| Grader and eval vocabulary ("you will be graded on...", "hidden tests") | Describes the scoring apparatus instead of the requirement and pushes effort toward being-watched | State every requirement the grader checks; never describe the grader |
| Strategy coaching next to task rules ("it's usually best to...") | The author's heuristics are wrong in some situations and the model's plan is usually better | If removing the sentence would not change what is legal or how success is measured, it is strategy — delete it |

Signals: `STEP \d` / numbered imperatives for non-fragile work; runs of 3+ `Do not|Never|Avoid` lines; `do not hallucinate` (re-test; removal here is low confidence, not a documented harm); single embedded gold outputs; near-duplicate sentences across sections; `Remember,|Again,|As stated above`; `grade|graded|rubric|hidden test`.

### 1d. Fossils — text that outlived its model

| Pattern | Why it is cruft now | Fix |
| --- | --- | --- |
| Model-version workarounds: formatting fixes, over-refusal softeners, retry hints, "known issue with [model]" comments, date-conditional guidance | Nobody owns the removal, so prompts accumulate the union of every generation's mitigations | Trace each mitigation to the model it patched; if that model is retired, remove and re-test |
| Migration-relative phrasing: "X now works differently", "also counts", "no longer" | The text is a diff against a previous prompt version the model never saw; relative phrasing implies phantom alternatives | Write as if the current rules are the only rules that ever existed |
| Patch accretion: many narrow conditionals, each traceable to one incident | The model navigates special cases instead of a principle and fails unpredictably between them; an eval win for adding a line on top of the stack is not evidence the stack should exist | Generalise the principle or fix the underlying context |
| Unenforced instructions: rules no code path, eval, or reviewer checks — visibly violated in the app's own transcripts | If nothing checks it and nobody noticed, it carries no signal; rules that could be hooks, allowlists, or schema validators are less reliable as prose | Enforce in code what can be; delete what nothing enforces and nobody misses |
| Identity stubs standing in for context ("You are a helpful assistant") | A role line is fine as a one-sentence focus-setter; the defect is identity substituting for audience, product, and quality bar | Do not flag a short role line; flag when it is the only context the prompt gives |
| Update suppressors written for chatty models: "hold all findings for the final response", "don't narrate", "no interim updates" | Tuned against models that over-narrated; current models (Claude Fable 5.1 especially) under-narrate with these present | Remove first and re-test; if more narration is wanted, replace with a specific line saying when user-facing text is wanted |
| Anti-formatting rules: "never use bullets", "no headers", "no bold" | Written against models that over-formatted; Claude Fable 5.1 already under-formats, so the rule strips formatting the reader wanted | Remove, or replace with a rule that says when formatting is appropriate |
| Instruction re-insertion every few turns ("reminder: ..." on a cadence in the harness) | A retention crutch for models that lost instructions over long sessions; current models retain a once-stated instruction, and each repeat costs tokens | Remove the repetition and re-test; where a genuinely per-turn reminder remains, send it as a turn-scoped system message or a text block after the tool results, and never delete earlier copies |

Signals: retired model names in prompts or comments (`claude-2|claude-3|claude-instant|3\.5|3\.7`); `hold (all )?(findings|results)|don't narrate|no interim`; `never use (bullets|headers|bold)|no (bullet|header)`; `reminder:` on a turn cadence; `before|after [date]` conditionals; `now|no longer|instead of` attached to behavioural rules; rules whose reason nobody remembers; `^You are (a|an) (helpful|expert)` with nothing task-specific following.

### 1e. Prohibition clusters — judge by provenance

A run of unconditional "never / don't / must not" lines is judged line by line on one question: does it carry a stated reason or encode a real business or policy constraint? Not "does the target model still need this guardrail?", which keeps everything because nothing is harmful to say. Prohibitions that encode observable constraints (refund caps, data rules, compliance language, promises the business must not make) stay, ideally with the reason beside them. Prohibitions that merely describe an undesirable output style with no provenance — banned phrases, tic lists, "don't start with 'Certainly'" — are cruft: restate the desired style positively in one line, or attach the real reason if there is one. A surrounding cluster of legitimate reasoned prohibitions does not justify the unreasoned ones mixed into it.

### 1f. Output-shaping choreography — one pattern, remove it whole

Fixed interim-update cadences ("after every third tool call, post a progress note"), numeric output ceilings ("under 120 words", "at most five bullets"), and cut-the-detail instructions are the same over-constraint pattern, written for models that padded or rambled. Remove them together. A stated operational reason ("queue throughput", "supervisors skim") does not turn a numeric clamp into a keeper: re-express the goal as audience and outcome framing without the number ("replies are scannable and answer only what was asked"), and keep any genuinely format-sensitive requirement as a format instruction, not a word count. Removing the cadence while keeping the ceilings leaves the pattern in place.

## Group 2 — Brittle skill files

Skill files (SKILL.md, CLAUDE.md, rule files) inherit everything in Group 1, plus failure modes of their own. Skill size is a tax paid on every trigger.

| Pattern | Why it is cruft now | Fix |
| --- | --- | --- |
| Verbose SKILL.md explaining things the model already knows | Every paragraph must justify its token cost; general programming knowledge does not | Apply the step 4 deletion rule paragraph by paragraph |
| Wrong degrees of freedom | Exact scripts for judgement calls over-constrain; vague prose for fragile operations under-constrains | Match specificity to fragility: prose heuristics for open fields, exact commands (`do not modify this command`) only for narrow bridges |
| The recency trap: one session's stumble encoded as a permanent rule | The next session steps around a pothole that is not there | Before keeping a rule, ask: would this have helped most recent sessions, or just the one that wrote it? |
| Volatile specifics: hardcoded paths, flags, version numbers, API claims with no verification date | Skills rot factually as code ships; nothing re-checks them | Encode architecture, data models, and workflows; verify surviving factual claims against current code during the pass |
| Time-sensitive content ("if before [date]...", option menus, duplicated info across SKILL.md and reference files) | Dates rot; menus of alternatives dilute; duplicates drift apart | An "old patterns" section instead of dates; one default plus an escape hatch; information lives in exactly one place |
| History narratives: past tense, incident IDs, PR numbers, pinned model names | A rule's authority is the behaviour it prescribes, not the incident that motivated it; pinned model names silently degrade after the next release | State the current rule; drop the archaeology |
| Trigger-case enumeration: description lists of near-synonymous example queries, growing one phrase per missed trigger | Descriptions ride in every request; enumeration taxes every token budget and generalises worse than intent categories | Name generalised categories of intent; see Group 3 for the trigger/behaviour split |

Signals: SKILL.md not readable in one sitting; hardcoded paths and version pins; past tense in instruction files; descriptions that only ever grow in git history.

## Group 3 — Tool descriptions

The rubric here is precision and contract accuracy, not brevity. This is where a trim instinct most often points the wrong way: detailed descriptions are the most important factor in tool performance, and the most common failure is under-description. What changed on current models is which content belongs there: contract and mechanics in, behavioural steering and worked examples out. A tool description is a man page — what the tool does, when to use it and when not to, what each parameter means, caveats, what it does not return.

| Pattern | Direction | Fix |
| --- | --- | --- |
| Vague one-liners; parameters without descriptions; no when-not-to-use | Under-described — add | 3–4+ sentences minimum; the description must precisely match actual behaviour (a contract/behaviour mismatch sends the model down paths no prompt text can fix) |
| `CRITICAL: You MUST use this tool when...` | Over-steered — dial back | Plain `Use this tool when...`; triggering boosters written against under-triggering models now cause over-triggering |
| Worked examples, fake dialogue turns, embedded protocols (numbered workflows, HEREDOCs) in the description, in any quantity | Misplaced — move | Examples constrain the exploration space and cost tokens on every request; move teaching material to skills or progressive disclosure; make parameters expressive (well-named enums carry intent) |
| Scolding cross-references (`ALWAYS use X, NEVER use Y for this`) and behaviour-smuggling ("after showing results, always recommend...") | Misplaced — move or delete | A description is a contract about functionality, not a channel for conversational instructions; put a preference for tool X in X's description, not in its rivals |
| Tool names in the system prompt; prose lists that shadow the real tool list | Duplicated — delete | The system prompt should not name tools, so enabling or disabling one never leaves a dangling reference. Do not expose tools that are invalid in the current configuration |
| Near-duplicate overlapping tools; bloated response payloads; 30+ always-loaded tools | Structural | Fewer, clearly bounded tools with explicit boundaries in both descriptions; high-signal responses; past a few dozen tools use tool search or deferred loading |

One deliberate split: trigger text is not behavioural text. Text whose job is routing — a skill's frontmatter description, a trigger block — may legitimately carry calibrated urgency, because skills currently under-trigger. Text whose job is behaviour should explain rather than shout. These look identical to a grep, so classify by function before editing.

Signals: descriptions under ~3 sentences (add); `MUST|ALWAYS|NEVER` steering behaviour inside descriptions (dial back); fake dialogue or worked examples in descriptions (move); tool names in system-prompt prose (delete).

## Group 4 — Request config and architecture

These surface next to prompt cruft; fix or report them even though they are not prompt text.

- **API fossils**: parameters and headers that error or are deprecated on the target model. See *Target-model facts*.
- **Cache-hostile ordering**: timestamps, UUIDs, per-user content interpolated above stable content. Grep the prompt assembly for `datetime|Date\(|uuid|user_id|session_id` above the stable system text; move volatile content to the end or into the user turn.
- **Budget countdowns rendered into context**: surfacing remaining-token counts to the model can cause premature wrap-up. Remove where possible.
- **An LLM executor for a deterministic plan**: in every pipeline, batch job, or agent loop, count the model-call sites and ask of each whether its inputs fully determine its output. Routing, tallying, normalising, filtering, and formatting go back into plain code; keep exactly one model call where the work is genuinely adaptive (classifying the ambiguous remainder, writing the judgement summary). Zero model calls is an over-fix when a judgement step exists — name the one call that stays.
- **Redundant specialist sub-agents**: two agents doing the same task with the same tools and near-duplicate prompts, differing only in a filter or a payload field, are one agent that should take the distinction as input. The fix is a roster edit — delete the redundant definition and fold its one real difference into the survivor's prompt or payload.
- **No token accounting**: without per-surface cost visibility, every other issue here is invisible. If the project has none, say so in the report as the prerequisite for measuring any cleanup.

## Target-model facts

Per-model behaviour the reasons above depend on. Verify against the current Anthropic docs when a claim decides an edit and the project pins an older target.

**Claude Fable 5.1 (and Mythos 5.1)**

- Assistant-turn prefill returns 400. Also true on Opus and Sonnet from 4.6 onward. Replace with structured outputs.
- `tool_choice: {type: "any"}` and `{type: "tool", name: ...}` return 400. Use `auto` with a prompt instruction, or structured outputs; `strict: true` on the tool keeps the schema guarantee.
- Instructing the model to reproduce its reasoning in the output can trigger a reasoning-extraction refusal. Read thinking blocks via the API instead.
- Under-narrates between tool calls and under-formats compared with earlier generations. Update suppressors and anti-formatting rules now remove text the reader wanted; when re-baselining, add one specific line saying when user-facing progress text or formatting is wanted.
- Follows instructions literally. Hedges ("try to", "if possible") become permission to skip; inflated emphasis becomes rigidity in gray areas.
- Plans and uses tools proactively without prompting; "plan first" and "think step by step" cause over-planning. Control depth with `thinking: {type: "adaptive"}` and effort, not prose.

**Earlier generations (Claude 3.x, 4.0–4.5)** are retired targets. Any mitigation traceable to them by blame or by naming is a presumptive removal on a 4.6+ or Fable target.
