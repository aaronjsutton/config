## Version control

- Before any VCS operation, check whether the repo is a colocated jj repo
  (`.jj/` next to `.git/`). If it is, use jj only.
- Organize work as a jj stack of small, focused commits on top of the base
  branch, each one building and passing tests on its own. Put prep work like
  refactors and test setup in commits below the feature that needs it.
- Don't push, open PRs or move remote bookmarks.
- Never abandon or rewrite commits Claude didn't make without asking; check
  `jj op log` to see who did what.
