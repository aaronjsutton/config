---
name: pickup
description: Pick up the Jira ticket for the current Coder workspace (abc-123 → ABC-123) and carry it through plan, jj prep, implementation, verification, and review across the repos in ~/workspace. Use when the user says "pickup", "pick up this ticket", "start the ticket", or "start work on ABC-123" inside a ticket workspace.
---

# Pick up a Jira ticket

Runs in a Coder workspace named after the ticket, from `~/workspace`, which
holds several repos. Four phases: **Plan → Prepare → Implement ⇄ Verify →
Review.** Never write to Jira. Never push.

## Concurrency rules (apply throughout)

Many agents run at once. These rules prevent them from corrupting each other:

- **One owner per repo at a time.** Any `jj` or `git` command (even `jj log`,
  `jj diff`, `git status`) snapshots the working copy or takes locks. Only the
  repo's current owner may run VCS commands in it:
  | Phase | Owner |
  |---|---|
  | Plan | that repo's Explore agent (no VCS commands at all) |
  | Prepare | main thread, one repo at a time |
  | Implement | that repo's `ticket-implementer` |
  | Verify / fix | main thread |
  | Review | main thread (review agents get diff files, not repo access) |
- Touch a repo only after its previous owner has **reported back**. Repo A may
  move to Verify while repo B is still implementing.
- `test-runner` never runs VCS commands. After it returns, run `jj st` in that
  repo to catch files the checks generated; delete them or add them to
  `.gitignore`. Don't commit them by accident.
- Each agent gets its own scratch dir: `<scratch>/<KEY>/<repo>/`, where
  `<scratch>` is the session scratchpad (or `mktemp -d`).
- **Contract changes are a barrier.** Cross-repo contracts (API shapes, shared
  types, events, config keys) are fixed in the plan. If anyone finds one must
  change, wait for every running implementer to finish, update the contract,
  then re-run the affected repos. Never let one repo drift on its own.

## 1. Plan

1. **Ticket key.** Take `$CODER_WORKSPACE_NAME` (fall back to `hostname`) and
   uppercase it: `abc-123` → `ABC-123`. Any prefix is fine. If it doesn't
   match `<letters>-<digits>`, stop and tell the user.
2. **Digest.** Launch the `ticket-digest` agent with the key. It reads the
   ticket, comments, parent/epic, links, subtasks, and linked Confluence pages,
   and returns a digest. Keep the digest; every later agent gets it.
3. **Repo survey.** List the repos in `~/workspace` (directories containing
   `.git` or `.jj`). In one message, launch one `Explore` agent per repo
   (`model: haiku`) with the digest and this instruction: *"Read-only. Do not
   run git or jj. Report whether this repo is relevant to the ticket, which
   files/modules, and what would likely change."*
4. **Plan mode.** Enter plan mode and present:
   - the ticket summary and acceptance criteria from the digest,
   - the repos to change (and ones considered but excluded, with why),
   - **cross-repo contracts**, written out concretely before any code,
   - per repo, the logical stack of changes, in order,
   - open questions from the digest.
   Wait for approval. Only the approved repos go forward.

## 2. Prepare

Main thread, **one repo at a time**, for each approved repo:

1. `jj git init --colocate` if there's no `.jj`. If the clone had uncommitted
   edits they become the `@` change; note it for the user and leave it alone.
2. `jj git fetch` (all branches).
3. Base: `staging@origin` if `jj log -r 'present(staging@origin)'` finds it,
   else `main@origin`.
4. Check for existing work: `jj bookmark list --all-remotes <KEY>`. If only
   `<KEY>@origin` exists, `jj bookmark track <KEY>@origin`.
   - **Bookmark exists:** find the GitHub repo from
     `git remote get-url origin`, then use the GitHub MCP
     `list_pull_requests` with `head: "<owner>:<KEY>"`, `state: "all"`.
     - **Any PR (open, closed, or merged):** don't rebase. `jj new <KEY>` and
       resume from there.
     - **No PR:** `jj rebase -b <KEY> -d <base>`. If it conflicts, resolve the
       conflicts and note what you did. Then `jj new <KEY>`.
   - **No bookmark:** `jj new <base> -m "<KEY>: <ticket summary>"`, then
     `jj bookmark create <KEY> -r @`.
5. Record base, starting state (fresh / resumed / rebased / PR exists), and
   anything odd.

## 3. Implement ⇄ Verify

**Implement.** In one message, launch one `ticket-implementer` per approved
repo, every time (even for a single repo). Give each:
- the repo path, key, base, and the digest,
- its part of the plan (the stack of changes),
- the full contract section, verbatim,
- its scratch dir.

**Verify** each repo as soon as its implementer reports:
1. If the implementer reported a contract problem, apply the barrier rule.
2. **Fast pass, in parallel:** `test-runner` in `fast` mode (lint, typecheck,
   unit tests; nothing needing a database, docker, fixed ports, or services).
   Runners for different repos may run at the same time.
3. Run `jj st` in the repo to catch generated files.
4. Fix failures yourself in the main thread (as the repo's owner), keeping the
   stack logical: amend the change the fix belongs to (`jj squash --into`) or
   add a new described change, and keep `<KEY>` on the tip
   (`jj bookmark set <KEY> -r <tip>`). Re-run the fast pass until green.
5. **Integration pass, serial:** once the fast pass is green everywhere, run
   `test-runner` in `integration` mode **one repo at a time** for repos whose
   relevant suites need services. Fix and re-run as above.

Check the runner's report of which checks it put in each pass. If it
misclassified something that needs services as `fast`, re-run it serially.

## 4. Review

1. For each repo, write its diff to `<scratch>/<KEY>/<repo>/diff.patch` with
   `jj diff --git -r '<base>..<KEY>'`.
2. In one message, launch:
   - one `ticket-reviewer` per repo with the diff path, repo path, and digest
     (**not** the plan, so the review isn't anchored on it),
   - one `ticket-acceptance` with every diff path and the digest.
3. Fix real findings in the main thread (back through Verify for that repo).
   Report anything you decide not to fix.
4. Finish with a summary per repo: stack (`jj log -r '<base>..<KEY>'`),
   bookmark, check results per pass, conflicts resolved, review findings and
   what was done, the acceptance table, and any plan items dropped or
   changed. Then **stop**. The user reviews and pushes.
