# MCP Tool Registry (single source of truth)

Read this when you need a Bitbucket MCP tool's exact signature or intended use while executing a step. The schemas themselves are loaded once in Step A.0's `ToolSearch` `select:...` preflight; this table is the signature/use reference.

| tool | signature | use |
|---|---|---|
| `get_current_user` | `()` | identify the author for self-comment filtering |
| `list_pull_requests` | `(repository, state=OPEN, q?, sort?, page?, pagelen?)` | find the PR for the current branch (match source branch) |
| `get_pull_request` | `(repository, prId)` | PR metadata + source/target branch confirmation |
| `get_comments` | `(repository, prId, page?, pagelen? max 100)` | all comments incl. resolution status; paginate |
| `get_comment` | `(repository, prId, commentId)` | full untruncated single comment |
| `resolve_comment` | `(repository, prId, commentId, resolve=true)` | resolve agreed threads |
| `add_comment` | `(repository, prId, text, parentId?, inline?{path,to\|from})` | post threaded push-back replies |
| `get_diff` | `(repository, prId, path?, contextLines?)` | pull surrounding code to assess a comment |
