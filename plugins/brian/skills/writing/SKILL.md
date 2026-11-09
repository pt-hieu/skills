---
name: writing
description: "Use when writing or revising prose a human reads: essays, posts, docs, and Brian's own drafts."
---

# Writing

Apply these rules to text you write or rewrite.

To audit a whole draft for machine prose, or when a rule's reason or replacement word is unclear, read [`references/ai-writing-patterns.md`](references/ai-writing-patterns.md). It is the reference these rules distil: a checklist ranked by evidence, its sources, and a word replacement table.

## Rules

**Write the current version.** When Brian corrects a fact in a draft, rewrite the passage as if the corrected fact had been there from the first draft. The reader starts from this version, so cut any sentence that denies, contrasts with, or reassures against an earlier one.

**Positive definition.** State what is true: define a thing by what it is and does. A denial defines it by what it is not or cannot do, and it counts whether it is in one sentence ("A, not B", "it is not B, it is A") or split across two ("A. It is not B."), because the split keeps the denial. Exclusion words make the same denial in fewer words: "only", "just", "nothing else", "on its own", "without", "no longer", and negative indefinites such as "nobody", "nothing", "never", or "no X". Replace them with the event that happens, and let the reader infer the excluded case from the positive claim, or drop it. Keep a denial or an exclusion word when the limit is itself the claim ("we only have a few favourite restaurants"), when it carries a joke, or when the reader held the denied idea and needs it corrected.

A concession is a different thing: two true facts that pull against each other, both of which the reader needs ("the event is saved, but it is still in Postgres"). Join them with "but", "yet", or "though", because the opposition is how they relate. Test a contrast by deleting its second half: if the reader loses a fact, it is a concession and keeps its "but"; if they lose a correction of something the text never claimed, it is a denial.

A sentence that keeps a denial or a limit says it with the plain word. A stand-in such as "and" for "but", "alone" for "only", or "makes no X" for "does not make X" keeps the same contrast and hides it, and the reader has to work out that the two halves disagree.

**Trust the reader.** Confirmations and concessions such as "and it does", "it is true, too", "to be fair", or "in fact" argue with an absent skeptic, and so do unrequested justifications: a "because" defending a structure the text already makes clear, a hypothetical about what would go wrong otherwise, or a reassurance that a margin or limit is enough. The writer's own feeling about a decision, such as pride, doubt, or annoyance, is part of the story and stays ("I am quite proud of this", "this can be wrong, but we're both happy with it"). Test each reason clause by deleting it: if the reader loses a fact they need to follow a decision, keep it; if what they lose is a defense, cut it. A reason that ties a decision back to the problem driving the piece is such a fact, because it holds the piece's thread. State the claim once and let it stand. Pre-emptive clarifications count too: a clause that settles a question the text has yet to raise, such as who did something by hand or how a result was judged. Put the fact where the reader first needs it, or drop it. Test each clause by asking what question it answers and whether the reader has reached that question yet.

**One thought, one sentence.** End a sentence where the thought ends. A thought chopped into short sentences reads as staccato and leaves the reader to rebuild the links between them, so write it as one sentence whose grammar holds those links. The opposite fault is the chain: a sentence that runs through several links (", so … , which … , and …") holds several thoughts, so end it at the first link the reader has to stop and take in. Use a short sentence for a point meant to land with weight. A short sentence closing paragraph after paragraph spends that weight, so most paragraphs end on a sentence of ordinary length.

**Embrace dread.** When there is a part of the piece you resist writing, name what you resist and work out why. The resistance points at what the piece is about, so put it on the page and learn from it.

**Narrator on the page.** In a first-person piece, the writer is the subject of the sentences: I guessed, I checked, I was wrong, I did this because I wanted that. A tool, a diagnosis, or an audit that "found" something hides what the writer was doing and thinking at the time, so put their action or belief in the sentence and let the reader hold their wrong guess with them until it breaks. Other prose keeps the voice it has.

**Vary the pace.** Spend words where the stakes are and compress the familiar. The scene that mattered gets room, a dull stretch gets a clause, and events of unequal weight get unequal space. A date, count, or version number stays where it changes what the reader understands; elsewhere write "a week later" or drop it. A run of "On [date], X happened" sentences is a changelog.

**One thread.** Open the piece with the problem that drives it, and open each section by saying how its part answers that problem. Join sentences with words that name how they relate, such as "so", "but", "since", or "the reason is". "And" says that the second fact adds to the first, so use it for that, and give two facts with another relation the word for it, and two facts with no relation a sentence each. A link word that opens sentence after sentence stops telling the reader anything, so leave out "So" where the order of two sentences already shows the consequence. Facts with no stated link read as a story told one sentence per person, and the reader has to rebuild the thread themselves.

**Say it where you raise it.** A sentence that announces a cost, a catch, a difference, or a count of reasons, and leaves the content to the next sentence, makes the reader wait for it: "It has one cost, and the scene shows it", "A slot also has a duty", "There are two ways to keep it". Open with the content itself ("A crash between the two steps sends the event twice"). Keep an announcement when a long list follows and the reader needs the count to keep their place in it.

**One definition at a time.** Define a term where the reader first needs it, in a sentence of its own or in one appositive. A sentence that stops to gloss two terms on the way to its point ("`test_decoding`, an example output plugin, the module that formats decoded changes, that ships with Postgres") buries the point, so define the second term in a sentence before this one.

**Break the mould.** A sentence frame reused for every term or section becomes visible as a frame: each new term named with "This is X" after its demonstration, each section opened by restating the last one and turning to a new problem, each summary shaped "X, so Y". Use a frame where the material calls for it, and write the other passages in the order their own content runs.

**Group by topic.** Put everything about one part of the thing in its section, even when the work on it happened at different times. Use a timeline only when the order of events is the story, because a timeline splits one topic across several sections.

**Sections end on the event.** End a section on the event, the image, or the open question. State a lesson once, in the place where it was learned, and end the other sections on their own material; cut a closing line that draws the lesson, calls back an earlier phrase, or restates what the paragraph showed. Headings name the content ("The hangs"), and an aphorism or reversal as a heading gives the section's ending away.

**Quote for the words.** Quote a log, a brief, or a commit message when the reader needs its words, and say the rest in the writer's own voice. A quote placed at the end of a paragraph to land the point is a punchline. A paragraph stitched from quoted fragments, each a few words set inside the writer's sentence, hands the telling to the sources: quote the one phrase whose wording matters, and say the rest in your own words with the source named.

**Odd counts.** Lists come in the number the material has. A third item added to make three, or a before-and-after pair built for symmetry, reads as pattern.

**Plain words.** Use the word a careful engineer says aloud: "use" for "leverage", "is" for "serves as" or "stands as", "has" for "carries", "means" for what a line of code "says", "cause" for "root cause", "a lot" for "enormously". Save a ten-dollar word for the moment that needs it. The words that mark Claude's own register in 2026 are "quietly", "genuinely", "plainly", "deliberate", "load-bearing", "seam", "carries", "sits", "stood", "nobody", "nothing", "survives", "earns its keep", "rests on", "of its own", "exactly", "in practice", "this matters", "matters because", and code that "argues", "refuses", "tells", or "judges". Keep each of them for its literal sense. The full table with replacements is Part 3 of the reference.

**The ending stops.** A loss stays a loss, an open question stays open, and the last line states a fact or the writer's own take on one part, and leaves the verdict on the whole to the reader. The ending may return to the problem the piece opened with, since that closes the thread. A close that reframes failure as growth, or that re-teaches the lessons, is the strongest single sign of machine prose.

## Finish

Reread every passage you wrote or rewrote against each rule, applying the rules' own tests: delete each reason clause and see what the reader loses, ask what question each clause answers and whether the reader has reached it, and check every flagged word for its literal sense. Stop when a full pass leaves the text unchanged.
