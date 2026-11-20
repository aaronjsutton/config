## Version control

- Before any VCS operation, check whether the repo is a colocated jj repo
  (`.jj/` next to `.git/`). If it is, use jj only. Plain git commands that move
  HEAD or change the working tree (checkout, switch, pull, stash, reset, clean)
  conflict with jj's working-copy snapshots and can lose uncommitted work.
  Read-only git commands are fine.
- Organize work as a jj stack of small, focused commits on top of the base
  branch, each one building and passing tests on its own. Put prep work like
  refactors and test setup in commits below the feature that needs it.
- After finishing a stack, leave an empty working-copy commit (`jj new`) on top
  so later edits don't amend a finished commit.
- Commit message format: `<TICKET-KEY>: <short imperative summary>`, a single
  line with no body. Keep each commit small enough that the summary says it
  all; if it needs a body, split the commit.
- One bookmark per stack, named exactly the ticket key (e.g. `ABC-123`), on the
  top commit. No per-commit or descriptive bookmarks.
- Don't push, open PRs or move remote bookmarks unless asked.
- Never abandon or rewrite commits Claude didn't make without asking; check
  `jj op log` to see who did what.
