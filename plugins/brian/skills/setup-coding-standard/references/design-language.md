# Template: design language in CLAUDE.md

> Applies when the repo has a UI whose look Brian decides: one of his personal projects, not one whose design comes from a client, an employer, or another team's design system. Ask him when the survey cannot tell.
>
> Adapt: `<build docs>` becomes the repo's files for how it is built, from the survey, such as `CODING_STANDARDS.md`, a code map, and a glossary, each named with what it holds. Everything else is copied as written. The block goes under the heading that holds the `CODING_STANDARDS.md` pointer, or at the end of the file when there is none, the pointer line first.

Everything after this blockquote is the block written into `CLAUDE.md`.

Every rule for how the product looks is in `DESIGN-LANGUAGE.md`. Those rules are the product's taste. The code records each screen's parts, labels, counts, sizes, and positions.

Add or change a design rule when feedback shows a taste. Feedback usually comes about one screen ("too even", "too big", "don't cover the wordmark"), so work out what it says about the product and write that.

- **A rule outlives its screen.** Write a sentence in `DESIGN-LANGUAGE.md` if it stays true after the screen that prompted it is redesigned. "The settings page lists Profile, Billing, then Delete account" is a spec for the code; "an action on a thing itself goes in a menu beside it" is a rule.
- **A feature that follows the rules adds no text.** When a change fits the existing rules, leave `DESIGN-LANGUAGE.md` as it is. Adding the feature's details to the nearest rule turns the file into a feature list.
- **Two or three sentences per rule.** State what a screen does and why. The reason lets the rule decide cases it does not name, and a rule that grows past three sentences is collecting a spec.
- **Check a new rule against the other screens.** Where a screen breaks it, decide which changes: the rule, or the screen through a filed issue. That keeps the file describing the product as it is.
- **One rule, one place.** Put a rule where it generalises, and put an exception beside the rule it qualifies.
- **How it is built goes elsewhere.** Tools, file formats, component names, and code locations go in <build docs>.
