# Snapshot replay and retention

On-demand branches of the `$scrutinize_dir` snapshot lifecycle (Step B). `$scrutinize_dir` is the per-repo subdirectory under `/tmp` computed in Step B; all paths below resolve under it.

## Retention prune (Step B.4)

After the run completes (end of Step F), prune `$scrutinize_dir` to keep the 30 most recent of each artifact class by mtime:

```
ls -t "$scrutinize_dir/"*.diff 2>/dev/null | tail -n +31 | xargs -r rm --
```

## Replay mode — `--input <sha-ts>` (Step B.5)

If `replay_input` is set, skip B.1–B.3 and instead:

```
snapshot="$scrutinize_dir/${replay_input}.diff"
test -s "$snapshot" || { echo "scrutinize: snapshot not found: $snapshot" >&2; exit 5; }
diff_text=$(cat "$snapshot")
```

Replay uses the cached snapshot verbatim; the diff is canonical because the snapshot file is what the prior run reviewed.
