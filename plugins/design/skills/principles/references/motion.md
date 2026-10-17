# Motion

Distilled from Emil Kowalski's [skills](https://github.com/emilkowalski/skills) (MIT License): `emil-design-eng`, `animate`, `review-animations`, and `apple-design`, keeping the judgment about whether and how things move. Every duration, curve, and spring comes from the design system's tokens.

## Whether it animates

Decide by how often the user sees it. Motion that charms the first time costs a little on every repeat, so the budget shrinks as frequency grows:

- Seen a hundred times a day, or triggered from the keyboard (command palette, shortcuts, list navigation): no animation. The state changes instantly.
- Seen tens of times a day (hover, row selection, tab switches): barely perceptible, or nothing.
- Occasional (opening a drawer or dialog, expanding a section): the system's standard motion.
- Rare or first-time (onboarding, a completed setup): the place for a showier moment, one per screen.

Motion has a purpose the user can name: it acknowledges their input, shows where something came from or went, makes a state change legible, or bridges content that would otherwise appear or vanish with a jolt. Motion the user did not trigger draws attention, so it marks one moment on a screen at most. A transition with none of these purposes is decoration and goes.

Data the user is reading or acting on holds still. Numbers that count up, charts that redraw for effect, and rows that shuffle for style pull the eye away from the values it is scanning (principle 5). A value that changed may flash or tint once to mark the change.

## How it moves

- **Interruptible.** Input during a transition retargets the motion from where the element is now, and the click it received takes effect. Use transitions or springs for anything the user can toggle quickly; keyframe animations restart from zero, which reads as a jump. Tailwind's `animate-in` utilities are keyframes.
- **From its origin.** A popover or menu grows from the control that opened it. A dialog stays centred, since it belongs to the page and to no single control. Enter from close to full size (around 0.95 scale with a fade); an element growing from a dot reads as a glitch.
- **Out the way it came.** An element leaves along its entry path, and exits run at the system's faster duration: the user has already decided, and the interface is responding.
- **Ease-out for responses.** Motion answering the user starts fast and settles, so movement begins the moment they act. Ease-in delays that first movement, the moment the user is watching most closely.
- **Peers swap in place.** Tabs, segmented controls, and scenario switches change content without a directional slide, because a slide claims a hierarchy the peers do not have.
- **Tooltips warm up.** The first tooltip waits its delay. Once one is open, moving to a neighbour opens it instantly with no animation, until the pointer leaves the group.
- **Name the properties.** A transition lists the properties it animates (`transition-colors`, `transition-transform`). `transition-all` animates whatever changes next, including padding and size changes that were never meant to move.
