# Template: DESIGN-LANGUAGE.md

> Applies when the repo has a UI whose look Brian decides: one of his personal projects, not one whose design comes from a client, an employer, or another team's design system. Ask him when the survey cannot tell.
>
> Adapt: nothing. The file starts with exactly this text, and Brian's rules join it below as his feedback arrives.

Everything after this blockquote is the text of `DESIGN-LANGUAGE.md`.

# Design language

## What belongs here

A guideline earns its place by deciding something on screens beyond the one that prompted it. Feedback usually arrives about one screen ("too even", "too big", "don't cover the wordmark"); the guideline captures the taste behind that feedback.

- **Write the taste.** Ask what the feedback says about the product, and write that. The code holds each screen's parts, counts, sizes, and positions.
- **Say what to do.** Phrase each rule as what a screen does, so it reads as direction to follow.
- **Give the reason.** A rule with its reason applies to cases beyond the ones it names.
- **Check it against the other screens before adding it.** Where an existing screen breaks it, decide which one changes: the rule, or the screen through a filed issue. A rule the product follows is a rule people trust.
- **Put it where it generalises.** A rule about all art goes under the art rules, and an exception sits beside the rule it qualifies.
- **Keep how it is built in `CODING_STANDARDS.md` and `docs/agents/`**: tools, file formats, component names, and which repository owns what.
