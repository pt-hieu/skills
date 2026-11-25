---
name: dev-server
description: "Use when starting a long-running process inside a Rex terminal: a development server, a file watcher, or a long build."
---

# Dev server

`dev-server` keeps a long-running process out of Brian's way and puts the page it serves beside the conversation, so the two of you look at the same page.

It applies inside a Rex terminal, where `REX_SESSION` and `REX_BLOCK` are set. A long-running process is anything that keeps running while you work.

## Done

- **Process.** Each long-running process runs in its own floating layer of your window, and the layer is minimized. Minimized, the process stays out of Brian's way, and he can open the layer whenever he wants to watch it. `session.new_layer` creates the layer from a `com.superlogical.terminal.shell` block whose `options` carry the `cwd` and the `command`, and `session.set_layer_state` minimizes it. `rex api describe` prints the schema of each.
- **Page.** When the process serves a web page, one `terminal-browser` tab shows that page in a split to the right of your pane. Brian then watches the page change while you work, and what you check is what he sees. The `terminal-browser` skill has the commands. `terminal-browser ls` tells you whether a tab already shows the URL; reuse that tab, because each `open` or `new-tab` adds another one.
- **Focus.** Your pane has focus. A new split takes it, and until `rex focus -s "$REX_SESSION" "$REX_BLOCK"` returns it, Brian's typing lands in the page.

## Reading

Read the process's output with `rex capture` on the layer's block.

Read the page with `terminal-browser action` (`snapshot`, `eval`, `screenshot`), and look for runtime errors in its `console` output, because its `errors` command comes back empty for them. `rex capture` returns nothing for the browser pane, which holds pixels and no text.

## Verify

- `rex session inspect "$REX_SESSION" --json` shows the process's layer with `state` `minimized`, and `focused_block_id` is your `REX_BLOCK`.
- The process is ready: its captured output shows the startup message, or its URL answers a request.
- For a served page, `terminal-browser ls` lists exactly one tab with the URL, and `terminal-browser action -- snapshot` returns the page's own content.
