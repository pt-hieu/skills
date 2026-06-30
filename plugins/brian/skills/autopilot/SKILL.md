---
name: autopilot
description: "Autonomous, no-human-in-the-loop sibling of /kickoff: takes a requirement to a PR without entering plan mode."
disable-model-invocation: true
---

Autonomous, no-human-in-the-loop sibling of `brian:kickoff`. Takes a requirement all the way to a PR — plan → implement → verify → self-review → commit → PR — without ever entering plan mode, asking a clarifying question, or waiting for plan approval. The PR is the single human review gate.
See `instructions.md` for the full pipeline, gates, effort matrix, safety spine, and terminal states. The file is self-contained — the runtime agent reads only that file.
