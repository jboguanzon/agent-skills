---
name: forgejo-cli
description: "Manage Forgejo repositories from the terminal with the `fj` CLI (the Forgejo equivalent of GitHub's `gh`): create/edit/close issues, open and merge pull requests, fork/migrate/clone repos, manage labels, releases, tags, Forgejo Actions, orgs, teams, users, and auth. Use whenever the user wants to interact with a self-hosted Forgejo instance or Codeberg (e.g. \"file an issue\", \"merge that PR\", \"create a release\"). Verify commands with `fj <cmd> --help` when in doubt — the wiki lags the binary."
---

# forgejo-cli (`fj`)

`fj` is a CLI for Forgejo instances (self-hosted or Codeberg), written in Rust.
It mirrors `gh`'s workflows: issues, PRs, repos, releases, actions, orgs, users.

Full command tree: [references/commands.md](references/commands.md)

## Setup

```bash
brew install forgejo-cli   # macOS (already installed on this machine, v0.6.0)
fj completion zsh          # optional: generate shell completions
```

Verify: `fj --help` lists top-level commands. There is no `--version` flag.

## Authentication

Two ways (see `fj auth --help`):

1. **`fj auth login`** — OAuth in the browser. Only works for a built-in list of
   public instances (Codeberg, code.forgejo.org, Disroot, …). **Self-hosted
   instances are not on the list** — use method 2 instead.
2. **`fj auth add-token`** — application token. For self-hosted servers:
   - Create a token at `https://$FORGEJO_HOST/user/settings/applications`
     (grant it broad permissions — `fj`'s feature set follows the token scope).
   - Run `fj -H "$FORGEJO_HOST" auth add-token` and paste the token
     (or pass it as an argument; it's also read from stdin).

Other auth commands: `fj auth list` (which instances you're logged into),
`fj auth logout`, `fj auth use-ssh` (prefer SSH for supported instances).

**Verify login:** `fj -H "$FORGEJO_HOST" whoami` prints your username
or an error (`unauthorized: token is required` = not logged in).

## Picking the instance and repo

`fj` resolves the instance from, in order: the `-H, --host <HOST>` flag, then
the git remote of the current directory (`-C, --cwd` changes that directory).

- `-H <host>` — target a specific host (e.g. `-H "$FORGEJO_HOST"`)
- `-R, --remote <REMOTE>` — pick which local git remote to use (default `origin`)
- `-r, --repo <owner/name>` — operate on a specific repo (e.g. `-r <owner>/<repo>`)

### Per-machine instance

Export the instance host once per machine in your shell profile:

```bash
export FORGEJO_HOST=your-forgejo.example.com
```

**Always pass `-H "$FORGEJO_HOST"` explicitly.** The repo remotes can be SSH
to a private address (`ssh://git@<lan-ip>:222/...`), and without `-H` `fj`
would auto-detect that instead of the public HTTPS host. Use
`fj -H "$FORGEJO_HOST" <cmd>` everywhere; cloning/pushing still happens via
the SSH remote (`git clone`/`git push` are untouched by `fj`).

**Repo/issue IDs** are either a bare number (`42`) or owner-qualified
(`<owner>/<repo>#42`). PR IDs are usually *optional* when the
current branch is tracking the PR; prefix with `^` to target the parent/upstream
repo from a fork (e.g. `fj pr checkout ^16`).

## Core workflows

### Issues

```bash
fj issue create "Title"                       # --body or $EDITOR; --template <file> if repo requires it
fj issue create "Title" --web                 # create in the browser
fj issue templates                            # list available templates
fj issue edit <id> title "New title"          # or `body`; blank → $EDITOR
fj issue edit <id> labels --add "bug" --remove "wontfix"
fj issue assign <id> user1 user2              # / fj issue unassign
fj issue comment <id> "text"                  # / fj issue edit <id> comment <idx>
fj issue view <id> [comments|comment <idx>]
fj issue search                               # list/search issues in the repo
fj issue close <id> --with-msg "Done"         # optional closing comment
fj issue browse <id>
```

### Pull requests

```bash
git switch -c feature && git commit -m "..." 
git push --set-upstream origin feature
fj pr create "This is a PR!"                  # --body / --body-file / $EDITOR
fj pr create "WIP: ..."                       # "WIP: " prefix marks the PR as draft
fj pr create -A                               # --autofill: title/body from commits
fj pr create --base ^ "PR against upstream"   # ^ = parent repo (works from forks)
fj pr create -aA                              # --agit + --autofill; --agit files the PR
                                              # straight from local commits, no push needed
fj pr view | fj pr status --wait              # status: mergeability + CI, --wait blocks
fj pr checkout ^16                            # checkout a PR locally
fj pr edit labels --add "Priority/High"
fj pr merge -M rebase --delete                # -M merge|rebase|rebase-merge|squash|manual
fj pr close <id> --with-msg "outdated"
fj pr review list                             # NOTE: only `list` exists; can't submit reviews yet
```

### Repos, releases, tags, actions

```bash
fj repo create example --description "..." --private [--push --remote codeberg]
fj repo fork forgejo/forgejo --name myfork
fj repo migrate <URL> <NAME> --include issues,prs,labels,releases   # only *to* Forgejo
fj repo view | fj repo readme | fj repo clone <repo> [PATH]
fj repo labels ...                            # manage repo-level issue labels
fj repo star | unstar | star-status | watch | unwatch
fj repo edit | fj repo units ...              # settings; rename is web-only

fj release create|edit|delete|list|view|browse|asset ...
fj tag create|delete|list|view ...

fj actions tasks                              # list workflow runs
fj actions dispatch <workflow.yml> <ref> --inputs key=value
fj actions variables list|create <NAME> <VALUE>|delete <NAME>
fj actions secrets list|create|delete         # same shape; values never editor-typed
```

### Users & orgs

```bash
fj user view [user] | user repos | user orgs | user activity | user search
fj user follow | unfollow | block | unblock
fj user key upload <path-to-.pub> | key list | key view | key delete
fj user gpg ...                               # needs `gpg` on PATH

fj org create <name> [--full-name --visibility --email --website]
fj org view | org list | org members | org activity
fj org repo create <org> <repo>
fj org label add <name> <hexcolor> | list | edit | delete
fj org team create <org> <team> --read-permissions ... --write-permissions ...
fj org team member add|rm|list | org team repo add|rm|list
```

## Gotchas (verified against v0.6.0)

- **Wiki vs binary:** the wiki documents `fj auth add-key`; the installed
  binary uses `fj auth add-token`. The `fj auth login` error message also
  says `add-key` — that text is stale too. Trust `fj <cmd> --help` over both.
- **`fj auth login` only works for a built-in list of public instances**
  (Codeberg, code.forgejo.org, Disroot, …). For self-hosted hosts it fails
  with "Your installation of fj doesn't support `login` for …" — that's
  expected; use `fj auth add-token` instead.
- **No `--version` flag** — `fj --version` errors; use `fj version` instead.
- Omitting `--body`/`--body-file` opens `$EDITOR`.
- If a repo disables blank issues, `--template <file>` is **required** on create.
- `fj pr merge -m <msg>` takes an *optional* value; `-t` sets the merge commit title.
- First-time SSH hosts must be in `~/.ssh/known_hosts` or you get
  `invalid or unknown remote ssh hostkey` — fix with
  `ssh-keyscan -H <host> >> ~/.ssh/known_hosts`.
- Repo migration is one-way: **only into** Forgejo. Use GitHub's tooling to go the other way.
- `--style minimal` disables fancy output/colors (good for piping).
