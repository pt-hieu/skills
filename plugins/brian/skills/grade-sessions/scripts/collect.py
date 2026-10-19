"""Write a grade workflow's result to disk.

Usage: python3 -I collect.py <workflow-output-file> <out-dir>
Writes <out-dir>/report.md and <out-dir>/sessions.json, and prints the coverage line from the run.
"""
import json
import os
import sys

output_file, out_dir = sys.argv[1], sys.argv[2]
result = json.load(open(output_file))['result']
with open(os.path.join(out_dir, 'report.md'), 'w') as handle:
    handle.write(result['synthesis'])
with open(os.path.join(out_dir, 'sessions.json'), 'w') as handle:
    json.dump({key: value for key, value in result.items() if key != 'synthesis'}, handle, indent=1)
print(f"{len(result['sessions'])} sessions graded; ungraded: {result['ungraded'] or 'none'}")
