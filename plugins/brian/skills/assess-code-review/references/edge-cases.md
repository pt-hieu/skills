# Step G — Edge cases (consolidated table)

| situation | handling |
|---|---|
| Bitbucket MCP not connected | Step A.0 preflight stops; tell Brian to connect it; no fallback |
| `[PR-ID]` given but not found | stop; report the id 404'd; don't fall back to auto-detect |
| no open PR for current branch | stop; ask once whether to pass a PR id |
| >1 open PR for branch | single `AskUserQuestion` to pick; never guess |
| no unresolved comments | clean success exit; nothing to do |
| comment with no associated code (general/PR-level) | assess on text alone; no `get_diff` needed |
| truncated comment in list | re-fetch via `get_comment` before classifying |
| your own prior reply in the thread | excluded via `get_current_user` author match |
| MCP auth failure / tool error | stop and report the failed tool + what failed; do NOT silently skip a comment or treat a failed fetch as "no comments" |
| Brian rejects the whole batch | apply/post nothing; leave every thread untouched; exit |
| fix fails to apply mid-execution | stop before posting any reply; report what applied and what didn't; leave already-resolved threads as-is and surface the partial state |
| reply fails to post after AGREE fixes already resolved | do NOT un-resolve the fixed threads; report which replies posted and which didn't, and print the unposted pushback text in chat so Brian can post it manually; surface the partial state explicitly |
| edit applied but doesn't fully address the comment | leave that thread UNRESOLVED (per Step F self-check); note the gap in the summary rather than resolving |
