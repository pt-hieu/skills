# Craft

Distilled from Anthropic's [`frontend-design`](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/frontend-design) skill (Apache License 2.0), keeping what applies once the design system has fixed palette, type, and motion.

## Ground the flow in its subject

Name the product's subject, its audience, and the job this flow does for them before laying out a screen. The subject's vocabulary and real content shape every label, fixture, and heading; a trip planner and a finance dashboard never share placeholder text.

## Structure carries information

Borders, dividers, numbering, and labels encode something about the content. Number items only when the content is a sequence. A label above a heading stays only when it tells the reader something the heading does not.

## Spend boldness in one place

Let one element of the flow be the memorable thing and keep everything around it quiet. Cut any decoration that does not serve the question the prototype answers. Non-user-triggered motion is for drawing attention to one moment; motion that answers the user's action is welcome when it shows what changed.

## Words

Words are in the interface to make it easier to understand and use.

- Write from the user's side: name things by what the user understands, not by how the system is built. A user manages notifications, not webhook config.
- A call to action says exactly what happens: `Save changes`, never `Submit`.
- An action keeps one name through the whole flow: the button says `Publish`, and the result says `Published`.
- An error states what went wrong and how to fix it, in the interface's voice. It does not apologize and is never vague.
- An empty screen invites an action.
- Plain verbs, active voice, sentence case, no filler. Each written element does one job.
