# Design Principles

Non-negotiable rules governing all UI design decisions.

### 1. Consistency Creates Trust
One visual language, everywhere. Cards, strips, panels, and dialogs share the same skeleton; spacing, padding, font sizes, and card anatomy stay constant across the page. Strict 8px grid for spacing. Differentiate with subtle signals — color labels, column spans, tints — never different anatomy. If two things look structurally different, users assume they ARE different, and unintentional variation makes them question whether they're looking at the same type of data.

### 2. Hierarchy Is the Product
When everything screams at the same volume, nothing communicates. Pick what matters most and give it visual dominance — size, position, color intensity. High-value items get real estate; low-value items compress. The top of the page answers "what matters right now" — the entry point gets the most polished, most scannable treatment. The user should know where to look in the first 2 seconds without reading anything.

### 3. Show Relationships, Not Just Data
Two parallel lists that share keys is data. Clicking an item and seeing connected items appear is intelligence. Always ask: "how does this item relate to other items, and can the user discover that?" Cross-link via shared keys (IDs, dates, categories). The value is in the connections.

### 4. Match Interaction Model to Usage Pattern
Modals force context switches — use side panels to preserve context when users scan and click through items. Match the UI mechanic to how people actually work, not to what's easiest to implement.

### 5. Design for Scanning
If a user has to read the UI to understand it, the design isn't done. Every element — tags, badges, scores, dots — must do clear, scannable work; a colored dot with no legend is visual noise. Scores: bars, not just numbers. Types: color/width/position, not just labels. Sentiment: tint/icon, not just hover. Fewer, meaningful signals beat more, ambiguous ones. Design for peripheral vision first, focused reading second.

### 6. Visual Weight Tracks Data State
Never display a value neutrally when the system knows whether it's good or bad, live or stale. A current value next to a target condition encodes whether the condition still holds — colored and styled accordingly. When a condition is no longer met, data has aged past relevance, or an item has been superseded, dim the entire container — don't just annotate with a label. Dead items at full opacity compete with live items for attention. The user shouldn't have to do the comparison mentally; color and style encode the interpretation.

### 7. Escalation Proportional to Severity
The entire page shape should change with severity, not just the status bar. Define tiers (info → warning → alarm) across all visual layers — banners, containers, content opacity. 2 alerts ≠ 30 alerts. High counts change banner shape (escalation rows, bulk actions, named callouts). A page that looks the same at 2 and 30 is lying about urgency.

### 8. Group by Decision Entity, and Grouping Is Insight
Triage UIs group by the thing you act on (entity, customer, issue), not the event that generated the data (run, batch, date). N alerts for M entities = M collapsible rows, not N cards. When the same entity repeats, collapse — don't repeat — and surface what the grouping reveals: repeat count, source diversity, temporal pattern. "Same signal across 4 sources" tells the user something they couldn't see before. Grouping should generate insight ("4× this week"), not just save space.

### 9. Every Drill-Down Needs a CTA
Expanding a row or section for context without offering an action creates a dead-end triage loop: scan → expand → learn → close → go elsewhere to act. Every expanded section needs at minimum one primary action (dismiss, act, snooze) anchored to the scope of the expanded content, not a generic page-level action. Information without a next step is a cul-de-sac.
