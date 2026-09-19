# `fj` command reference (forgejo-cli v0.6.0)

Compiled from `fj <cmd> --help` on this machine + the project wiki
(<https://codeberg.org/forgejo-contrib/forgejo-cli/wiki>). Where the wiki and
the binary disagree, the binary wins.

## Global flags

```
fj [OPTIONS] <COMMAND>
  -H, --host <HOST>      instance to target (else resolved from git remote of cwd)
  -C, --cwd <CWD>        working directory to resolve the git remote from
      --style <STYLE>    fancy (default) | minimal (no unicode/colors; auto in pipes)
  -h, --help             print help (use for any subcommand)
```

Repo-scoped command groups (`issue`, `pr`, `release`, `tag`, `actions`, `wiki`, …)
additionally accept:

```
  -R, --remote <REMOTE>  local git remote name to operate on (default origin)
  -r, --repo <REPO>      target repo as owner/name (overrides remote detection)
```

> **Per machine:** always add `-H "$FORGEJO_HOST"` to `fj` commands, with
> `FORGEJO_HOST` exported per machine (see SKILL.md). The repo remotes can be
> SSH to a private address (`ssh://git@<lan-ip>:222/...`), which would
> otherwise auto-detect the LAN IP instead of the public HTTPS host. `fj` API
> calls go to `$FORGEJO_HOST`; git clone/push still uses the SSH remote
> untouched.

## Top-level commands

```
repo       repositories: create, fork, migrate, view, clone, labels, edit, units, …
issue      issues: create, edit, comment, assign, close, search, view, templates, browse
pr         pull requests: create, view, status, checkout, edit, merge, close, review, …
wiki       repo wiki: contents, view, clone, browse
actions    Forgejo Actions: tasks, variables, secrets, dispatch
whoami     print current user (auth check)
auth       login, logout, add-token, use-ssh, list
release    releases: create, edit, delete, list, view, browse, asset
tag        tags: create, delete, list, view
user       users: view, search, follow, block, key, gpg, …
org        orgs: create, view, teams, labels, repos, …
version    print version
completion generate shell completions (bash|elvish|fish|power-shell|zsh|nushell)
```

## auth

```
fj auth login          OAuth browser flow; only for supported public instances
fj auth add-token      application token; arg or stdin. THE method for self-hosted
                       (wiki calls this `add-key`; binary name is add-token)
                       → per machine: `fj -H "$FORGEJO_HOST" auth add-token`,
                         token from https://$FORGEJO_HOST/user/settings/applications
fj auth logout         delete login info for an instance
fj auth list           list instances you're logged into
fj auth use-ssh        enable/disable SSH-by-default per instance
fj whoami              verify login / print current user (add -H "$FORGEJO_HOST")
```

## issue

```
fj issue create <TITLE> [--body <TEXT> | --body-file <FILE>] [--template <FILE>]
                         [--no-template] [-r <owner/name>] [--web]
                         # no --body → $EDITOR; --template required if blank issues disabled
fj issue edit <id> title <TEXT>        # blank TEXT → $EDITOR
fj issue edit <id> body <TEXT>
fj issue edit <id> labels --add <L> [--add <L>...] --remove <L> [...]
fj issue comment <id> <TEXT>           # no TEXT → $EDITOR
fj issue edit <id> comment <idx>       # edit a specific comment
fj issue assign <id> <user>...         # / fj issue unassign <id> <user>...
fj issue close <id> [--with-msg <MSG>]
fj issue search                        # list/search issues in the resolved repo
fj issue view <id>                     # + `comments`, `comment <idx>`
fj issue templates                     # list repo's issue templates
fj issue browse <id>                   # open in browser
```

IDs: bare number `42` or owner-qualified `owner/repo#42`.

## pr

```
fj pr create [TITLE] [--body <TEXT> | --body-file <FILE>] [--base <BRANCH>] [--head <BRANCH>]
                  [-A/--autofill] [-a/--agit] [-w/--web] [-r <owner/name>]
                  # "WIP: " title prefix → draft PR
                  # --base ^ → file against upstream from a fork
fj pr view [ID]                        # body, changed lines, …
fj pr status [ID] [--wait]             # mergeability + CI; --wait until checks finish
fj pr checkout <ID>                    # checkout in new local branch (^ID = parent repo)
fj pr comment <ID> <TEXT>              # / fj pr edit <ID> comment <idx>
fj pr assign <ID> <user>...            # / fj pr unassign
fj pr edit [ID] title|body <TEXT>
fj pr edit labels --add <L> --remove <L>
fj pr close [ID] [--with-msg <MSG>]    # close without merging
fj pr merge [ID] [-M merge|rebase|rebase-merge|squash|manual] [-d/--delete]
                 [-t <commit-title>] [-m [<commit-msg>]]
fj pr browse <ID>
fj pr review list [ID]                 # only `list` — cannot submit reviews via CLI yet
```

PR ID is optional when the current branch tracks the PR.

## repo

```
fj repo create <NAME> [--description <TEXT>] [--private] [--remote <NAME>] [--push]
fj repo fork <owner/name> [--name <NEW>]
fj repo migrate <URL> <NAME> [--service <SVC>] [--include lfs,wiki,issues,prs,milestones,labels,releases]
                            [--token|--login] [--lfs-endpoint <URL>] [--mirror] [--private]
                            # --token/--login read from stdin; migration is into Forgejo only
fj repo view <owner/name>              # name, description, language, stars, issue/PR counts
fj repo readme <owner/name>
fj repo clone <owner/name> [PATH]
fj repo star|unstar|star-status|watch|unwatch|watch-status
fj repo delete <owner/name>            # irreversible
fj repo browse <owner/name>
fj repo labels ...                     # repo-level issue label management
fj repo edit ...                       # description, private/archived, …
fj repo units ...                      # per-unit settings (issues, wiki, …)
```

## release / tag

```
fj release create|edit|delete|list|view|browse
fj release asset ...                   # attach/manage release files
fj tag create|delete|list|view
```

## actions

```
fj actions tasks                          # list workflow runs (current + past)
fj actions dispatch <WORKFLOW> <REF> [--inputs key=value]   # e.g. publish.yaml main --inputs version=10
fj actions variables list|create <NAME> [<VALUE>] [--force] | delete <NAME>
fj actions secrets   list|create <NAME> [<VALUE>] | delete <NAME>   # never editor-typed
```

## user

```
fj user search <QUERY>
fj user view [USER]                       # username, full name, pronouns, followers, bio, join date
fj user browse [USER]
fj user repos|orgs|followers|following|activity [USER]
fj user follow|unfollow <USER>
fj user block|unblock <USER>
fj user edit ...                          # your own settings
fj user key upload <path-to-pubkey> | key list | key view <ID> | key delete <ID>
fj user gpg ...                           # email/key-ID based; needs `gpg` on PATH; --no-verify
```

## org

```
fj org create <NAME> [--full-name <TEXT>] [--email --location --website] [--visibility private|limited|public]
fj org edit <ORG> ...                    # rename is web-only
fj org view <ORG> | org list [--only-member-of] | org members <ORG> | org activity <ORG>
fj org visibility                        # your membership visibility (private/public)
fj org repo list|create <ORG> <REPO>     # create takes same flags as repo create
fj org label add <NAME> <HEXCOLOR> [--description <TEXT>] | label list | label edit | label delete
                                         # exclusive scope via "{scope}/{name}" label names
fj org team create <ORG> <TEAM> [--read-permissions <CSV>] [--write-permissions <CSV>]
                                [--can-create-repos] [--admin] [--include-all-repos]
fj org team edit | team list | team view [--list-permissions] | team delete
fj org team member add|rm|list
fj org team repo add|rm|list
```

Permissions (for team create/edit): `wiki, ext_wiki, issues, ext_issues, pulls,
projects, actions, code, releases, packages`.

## wiki

```
fj wiki contents | view "<PAGE>" | clone | browse
```

## Gotchas

- `fj --version` errors — use `fj version`.
- Wiki says `auth add-key`; binary v0.6.0 uses `auth add-token`.
- Unknown SSH host → `invalid or unknown remote ssh hostkey`; add host to
  `~/.ssh/known_hosts` (`ssh-keyscan -H <host> >> ~/.ssh/known_hosts`).
- `pr review` is read-only (`list` only).
- `--style minimal` for script-friendly output.
