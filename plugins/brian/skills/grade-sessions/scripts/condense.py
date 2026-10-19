"""Condense Claude Code transcripts into graded-sized markdown files and balance them into batches.

Usage: python3 -I condense.py <out-dir> [--since YYYY-MM-DD] [--project SUBSTRING] [--batches N] [--min-messages N]
Writes <out-dir>/condensed/*.md and <out-dir>/batches.json, and prints a one-line summary.
"""
import argparse
import glob
import json
import os

ROOT = os.path.expanduser('~/.claude/projects')
SKIP_PREFIXES = ('<local-command-caveat>', '<local-command-stdout>', '<system-reminder>')


def short(text, limit):
    text = text.strip()
    return text if len(text) <= limit else text[:limit] + f' …[+{len(text) - limit} chars]'


def tool_summary(block):
    name = block.get('name')
    tool_input = block.get('input') or {}
    detail = (tool_input.get('command') or tool_input.get('file_path') or tool_input.get('pattern')
              or tool_input.get('description') or tool_input.get('query') or '')
    if name in ('Agent', 'Workflow'):
        prompt = str(tool_input.get('prompt') or tool_input.get('script') or '')
        detail = f"{tool_input.get('subagent_type', '')} {tool_input.get('description', '')} :: {short(prompt, 400)}"
    if name == 'Skill':
        detail = f"{tool_input.get('skill')} {tool_input.get('args', '')}"
    return f'[tool {name}] {short(str(detail), 300)}'


def condense(path):
    lines, human_count, first_time, last_time = [], 0, None, None
    for raw in open(path, errors='replace'):
        try:
            entry = json.loads(raw)
        except json.JSONDecodeError:
            continue
        if entry.get('type') not in ('user', 'assistant') or entry.get('isSidechain'):
            continue
        timestamp = entry.get('timestamp')
        first_time = first_time or timestamp
        last_time = timestamp or last_time
        content = entry['message'].get('content')
        blocks = [{'type': 'text', 'text': content}] if isinstance(content, str) else content
        for block in blocks:
            kind = block.get('type')
            if entry['type'] == 'user':
                if kind == 'text':
                    text = block['text']
                    if text.startswith(SKIP_PREFIXES):
                        continue
                    if text.startswith('Base directory for this skill'):
                        lines.append(f'[skill body loaded: {short(text.splitlines()[0], 200)}]')
                    elif text.startswith('<command-'):
                        human_count += 1
                        lines.append(f'USER COMMAND: {short(text, 300)}')
                    elif text.startswith('[Request interrupted'):
                        lines.append('USER INTERRUPTED')
                    else:
                        human_count += 1
                        lines.append(f'\n### USER:\n{short(text, 4000)}\n')
                elif kind == 'tool_result' and block.get('is_error'):
                    result = block.get('content')
                    result = result if isinstance(result, str) else json.dumps(result)
                    lines.append(f'[tool error] {short(result, 300)}')
            elif kind == 'text' and block['text'].strip():
                lines.append(f'\n### CLAUDE:\n{short(block["text"], 2500)}\n')
            elif kind == 'tool_use':
                lines.append(tool_summary(block))
    return lines, human_count, first_time, last_time


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('out_dir')
    parser.add_argument('--since')
    parser.add_argument('--project')
    parser.add_argument('--batches', type=int, default=30)
    parser.add_argument('--min-messages', type=int, default=3)
    options = parser.parse_args()

    condensed_dir = os.path.join(options.out_dir, 'condensed')
    os.makedirs(condensed_dir, exist_ok=True)
    sessions = []
    for path in glob.glob(f'{ROOT}/*/*.jsonl'):
        project = os.path.basename(os.path.dirname(path))
        if options.project and options.project not in project:
            continue
        lines, human_count, first_time, last_time = condense(path)
        if human_count < options.min_messages or not first_time:
            continue
        if options.since and last_time[:10] < options.since:
            continue
        session = os.path.basename(path)[:-len('.jsonl')]
        out_path = os.path.join(condensed_dir, f'{project}__{session}.md')
        body = '\n'.join(lines)
        with open(out_path, 'w') as handle:
            handle.write(f'# Session {session}\nProject: {project}\nTime: {first_time} → {last_time}\n'
                         f'Human messages: {human_count}\n\n{body}\n')
        sessions.append((out_path, len(body)))

    batch_count = max(1, min(options.batches, len(sessions)))
    batches = [{'files': [], 'size': 0} for _ in range(batch_count)]
    for out_path, size in sorted(sessions, key=lambda item: -item[1]):
        lightest = min(batches, key=lambda batch: batch['size'])
        lightest['files'].append(out_path)
        lightest['size'] += size
    batch_files = [batch['files'] for batch in batches if batch['files']]
    with open(os.path.join(options.out_dir, 'batches.json'), 'w') as handle:
        json.dump(batch_files, handle)
    total = sum(size for _, size in sessions)
    print(f'{len(sessions)} sessions, {len(batch_files)} batches, {total // 1000} KB condensed, '
          f'largest batch {max((batch["size"] for batch in batches), default=0) // 1000} KB')


main()
