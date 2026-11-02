# Art style

Every scene is a hand-inked storybook illustration with a worn print finish, on warm cream paper. `assets/init.html` already sets the page's type, colours, and layout, and its `teachKit` helpers draw in this style, so draw with them.

## Look

- **Line:** black ink outlines with a slight wobble and uneven weight, as if drawn with a nib. `shape` and `line` produce this.
- **Colour:** flat, muted fills from the page's small palette. Each concept colour means one concept for the whole lesson, because a colour that holds its meaning teaches across levels. Leave out gradients, soft shadows, and glows.
- **Texture:** fine white speckle through coloured fills, with fills slightly out of line with their outlines. `shape` adds both. Set `speckle: 0` on paper-coloured fills and on anything very small.
- **Shading:** thin ink hatching along edges and in dark areas, using `shape`'s `hatch` style.
- **Subjects:** simple, rounded, friendly shapes with only the details that help recognition. Use `person` for the recurring character, so they look identical at every level. A thing keeps the same shape everywhere it appears.
- **Frame:** draw tight to the viewBox, with the art reaching its edges. Use 560 × 200 for animations, 360 × 200 for a still drawing beside prose, and 200 × 110 for a row of three small examples, because the rows are sized for these shapes.
- **Composition:** one small scene standing on a wooden ground line, with plenty of empty paper and only the objects the idea needs. Leave out background scenery, borders, and frames.
- **Lettering:** the page's typewriter serif at about 14 viewBox units for labels, because a scene scales up on large windows and larger text overpowers the prose. Use short labels in sentence case, and leave out all caps.

## Where illustrations go

Every lesson opens with a title illustration of the running example. Inside a level, pair a passage with a still drawing using `.row`, and vary which side has the art so the page keeps a rhythm. Use `.row.wide-left` or `.row.wide-right` to give an animation the larger share, and `.spots` for three small examples of one idea. A still drawing shows something the prose says: leave out art that only decorates. Draw stills with `teachDrawing`, using the same helpers and the same objects as the animations.

## Motion

- Each animation shows one idea in up to about six steps, which is what a newbie can follow in one loop. When a process needs more, split the idea across levels.
- Move one thing at a time, with slow easing. Each step's `focus` highlights the parts that matter and dims the rest, so the eye always knows where to look.
- Every movement teaches something: a message travelling, a value changing, a part lighting up. Leave out bounces, wiggles, flourishes, and entrance effects.
- Set each step's `hold` so its motion finishes and the caption can still be read at about four words per second. Hold the final step longest, because it shows the result.

## Captions

Write each caption as one plain sentence saying what is happening in that step. Name a term when the picture first shows it, and use it unchanged afterwards, because a newbie reads a new word as a new thing. Together with the picture, the captions must make the idea clear without the prose.
