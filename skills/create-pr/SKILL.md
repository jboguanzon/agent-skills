---
name: create-pr
description: >-
  Create a pull request for the current branch: read the entire branch's
  commits and their file changes, derive the issue numbers, write the PR
  title and description following PR-FORMAT.md, then open the PR on Forgejo
  using the forgejo-cli skill. Use when the user asks to create/open a PR,
  write a PR description, or "make a PR for this branch".
---

# Create a PR

## Workflow

### 1. Identify the branch and its base

- `git branch --show-current` — the branch to PR.
- `git remote show origin | grep "HEAD branch"` — the base branch (e.g. `main`).
- Fetch first if the remote base is stale: `git fetch origin`.

### 2. Read the entire branch's commits

- `git log --oneline origin/<base>..HEAD` — every commit the PR carries
  (not just the last few). If the branch isn't pushed yet this still works
  against the local remote-tracking ref.
- For each commit, read its file changes:
  `git show --stat --format="%h %s" <sha>` then skim the diff of the key
  files (`git show <sha> -- <path>`). These diffs are the source of truth
  for the `## Changes` section — never paraphrase commit subjects only.

### 3. Map commits to issues

- Collect `#N` issue references from the commit messages.
- Look up each issue's title via the forgejo-cli skill:
  `fj -H <host> issue view N` (see step 6 for the host).

### 4. Write the title and description

- Follow **PR-FORMAT.md** (in this skill directory) exactly: conventional
  title summarizing all features, then `## Summary`, `## Closes`,
  `## Changes` (grouped by issue, from the real diffs), `## Verification`
  (checks actually run this session — run the repo's standard checks if
  they haven't been run: typically `pnpm test`, `pnpm lint`,
  `npx tsc --noEmit`, plus `-p convex/tsconfig.json` when a `convex/`
  tsconfig exists).

### 5. Prepare the body file

Write the description to a temp file (e.g. `/tmp/pr-body.md`) and pass it
with `--body-file` when creating the PR. **Never pass the body inline or via
a shell heredoc** — backticks and `$` in markdown get shell-substituted and
mangle the body.

### 6. Create the PR via the forgejo-cli skill

Read the `forgejo-cli` skill (same skills directory) and follow its PR
workflow. Repo-specific notes for this machine:

- **Always pass `-H "$FORGEJO_HOST"`** (see the forgejo-cli skill; export
  `FORGEJO_HOST` once per machine) — the git remotes can be SSH to a LAN IP,
  and without `-H` `fj` targets the wrong host.
- Push the branch first if it isn't tracking a remote yet:
  `git push --set-upstream origin <branch>` (pushing uses the SSH remote;
  `fj` API calls use the `-H` host — they're independent).
- Create with explicit title/body:
  `fj -H "$FORGEJO_HOST" pr create "<title>" --body-file /tmp/pr-body.md`
  (from the repo directory; `fj` resolves the repo from the git remote).

### 7. Confirm

- `fj -H "$FORGEJO_HOST" pr view` from the branch — verify title,
  base, and that the `## Closes` lines list the right issues.
- Report the PR number and URL to the user.
