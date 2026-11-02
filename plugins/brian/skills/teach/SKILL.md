---
name: teach
description: "Use when Brian wants to learn a concept from scratch."
argument-hint: "[concept]"
---

Build a lesson that takes a complete newbie from knowing nothing about a concept to the depth it needs: one scrolling desktop HTML page, written to `<topic>-lesson.html` in the current directory unless Brian names another place. Keep going until the lesson is finished, and stop to ask only when the request doesn't identify a concept to teach. You may launch up to five subagents, the cap Brian set for a run, all `general-purpose` with `model: "opus"`.

## The lesson

The reader is meeting the concept for the first time and reads the page alone.

- **The right model only.** Present what is true and leave out misconceptions, including "you might think X" and "a common mistake is X". A newbie can't easily tell the right idea from the wrong one, and naming a wrong idea can plant one they never had.
- **Accurate.** Base every claim on a primary source: specifications, official documentation, and original papers ahead of blogs. A newbie takes every claim as true.
- **Levels from simple to complex.** Each level adds one idea to the last. Level 1 assumes no background.
- **Four parts per level, in this order.** Why this level: what the last level couldn't do, or for level 1, what the concept is for. An animation of the level's key idea with synced captions. An explanation of a few short paragraphs, with a concrete example before any formal term. A recap of one or two sentences to take into the next level.
- **Illustrated throughout.** Beyond each level's animation, give still drawings to whatever the prose describes that can be pictured: a drawing beside a passage, or a row of small examples. A newbie understands a picture before a paragraph.
- **Every term defined before its first use**, including in captions, because one undefined word can stop a newbie.
- **One running example** that grows through the levels, so attention stays on each new idea.
- **Reading only.** Animations start and loop by themselves. Leave out controls, sliders, quizzes, collapsible asides, and saved progress, so the reader starts learning as soon as the page opens.
- **One voice.** Write all the copy with the `brian:writing` skill: the title, prose, captions, labels, and recaps.
- **One look.** Start from `${CLAUDE_PLUGIN_ROOT}/skills/teach/assets/init.html` and keep its libraries, styles, and helpers as they are. [`references/art-style.md`](references/art-style.md) sets the style and the limits on animations and captions, and [`references/example-scene.md`](references/example-scene.md) shows a finished level.

## Done when

- Every level has all four parts, and no `{{PLACEHOLDER}}` or marker comment remains.
- You have confirmed the lesson's claims against their sources.
- At 1440×900 and 1920×1080 the page has no console errors, and in every still drawing and every captured animation step the text is inside its shapes, nothing overlaps by accident, and the caption matches the picture.
- With reduced motion on, and with `cdn.jsdelivr.net` blocked, the page shows the numbered captions.
- With the prose hidden, each animation and its captions still make the level's key idea clear.
- A subagent given only the page, with none of your research or plan, reads it as someone who has never met the concept and finds no undefined terms, unexplained jumps, animations too quick to follow, or mentions of a wrong idea.

Then open the lesson with `open` and tell Brian where it is, how many levels it has, what the last level reaches, and anything you couldn't verify.
