#!/usr/bin/env python3
"""scrutinize HTML renderer.

Usage:
    python3 html-render.py <out_path>

Reads a single JSON payload from stdin of shape:
    {"template": "<raw html template with {{SENTINEL}} markers>",
     "data":     {<scrutinize data dict — see Step E of instructions.md>}}

Writes the rendered HTML to <out_path>. Exits non-zero with a clear stderr
message if the template references a sentinel not in VALUES, if any sentinel
is left unsubstituted, or if the payload is malformed. No imports beyond the
stdlib.
"""

import html
import json
import re
import sys


def esc(v):
    return html.escape(str(v), quote=True) if v is not None else ""


def render_findings(data, level):
    rows = [f for f in data.get("findings", []) if f.get("confidence") == level]
    if not rows:
        return f'<p class="empty">No {level} findings.</p>'
    out = []
    for f in rows:
        axes = ", ".join(esc(a) for a in f.get("axes", []))
        ev = f.get("evidence", {}) or {}
        out.append(
            f'<details class="finding sev-{level.lower()}" open>'
            f'<summary><span class="sev">{level}</span> '
            f'<span class="dc">{esc(f.get("defect_class", ""))}</span> '
            f'<span class="file">{esc(f.get("file", ""))}:{esc(f.get("line", ""))}</span> '
            f'<span class="axes">[{axes}]</span> '
            f'{esc(f.get("summary", ""))}</summary>'
            f'<div class="body">'
            f'<p><strong>Claim:</strong> {esc(f.get("claim", ""))}</p>'
            f'<p><strong>Evidence:</strong> {esc(ev.get("file_line", ""))}</p>'
            f'<pre><code>{esc(ev.get("snippet", ""))}</code></pre>'
            f'<p><strong>Fix:</strong> {esc(f.get("fix", "—"))}</p>'
            f"</div></details>"
        )
    return "\n".join(out)


def render_header(data):
    skipped = "; ".join(
        f'{esc(s["axis"])} ({esc(s["reason"])})' for s in data.get("axes_skipped", [])
    )
    abstained = "; ".join(
        f'{esc(s["axis"])} ({esc(s["reason"])})' for s in data.get("axes_abstained", [])
    )
    return (
        '<div class="meta">'
        f'<div>repo: <code>{esc(data.get("repo_root", ""))}</code></div>'
        f'<div>sha: <code>{esc(data.get("short_sha", ""))}</code> · '
        f'ts: <code>{esc(data.get("iso_timestamp", ""))}</code></div>'
        f'<div>tier: <code>{esc(data.get("tier", ""))}</code></div>'
        f'<div>dispatched: {", ".join(esc(a) for a in data.get("axes_dispatched", []))}</div>'
        f'<div>skipped: {skipped or "—"}</div>'
        f'<div>abstained: {abstained or "—"}</div>'
        "</div>"
    )


def render_footer(data):
    c = data.get("counts", {})
    return (
        '<div class="footer">'
        f'HIGH: {esc(c.get("high", 0))} · MEDIUM: {esc(c.get("medium", 0))} · '
        f'LOW themes: {esc(c.get("low_collapsed_themes", 0))} · '
        f'LOW dropped: {esc(c.get("low_dropped", 0))}'
        "</div>"
    )


def main(argv):
    if len(argv) != 2:
        print("usage: html-render.py <out_path>", file=sys.stderr)
        return 2

    out_path = argv[1]
    try:
        payload = json.loads(sys.stdin.read())
    except json.JSONDecodeError as e:
        print(f"scrutinize: malformed JSON payload on stdin: {e}", file=sys.stderr)
        return 3

    try:
        template = payload["template"]
        data = payload["data"]
    except KeyError as e:
        print(f"scrutinize: payload missing required key: {e}", file=sys.stderr)
        return 3

    values = {
        "HEADER_META": render_header(data),
        "FINDINGS_HIGH": render_findings(data, "HIGH"),
        "FINDINGS_MEDIUM": render_findings(data, "MEDIUM"),
        "FINDINGS_LOW": render_findings(data, "LOW"),
        "FOOTER_META": render_footer(data),
    }

    def replace_sentinel(m):
        key = m.group(1)
        if key not in values:
            raise KeyError(f"template references unknown sentinel: {{{{{key}}}}}")
        return values[key]

    html_out = re.sub(r"\{\{([A-Z_]+)\}\}", replace_sentinel, template)

    leftover = re.findall(r"\{\{[A-Z_]+\}\}", html_out)
    if leftover:
        print(f"scrutinize: unsubstituted sentinels: {leftover}", file=sys.stderr)
        return 4

    with open(out_path, "w") as fh:
        fh.write(html_out)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
