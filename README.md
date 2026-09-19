# agent-skills

Personal, agent-agnostic skills shared between AI coding agents. One copy of
each skill, symlinked into every harness that runs on this machine.

Supported harnesses:

| Harness | Link target |
|---|---|
| pi | `~/.pi/agent/skills/` |
| Claude Code | `~/.claude/skills/` |

`~/.agents/skills/` is deliberately not a target: the `npx skills` CLI owns
that directory and manages installs and uninstalls there.

## Layout

```
agent-skills/
├── install.sh      # link skills into every harness (idempotent)
├── uninstall.sh    # remove only the links this repo created
├── validate.sh     # lint skills against the spec; install.sh runs it first
└── skills/
    └── <name>/     # one directory per skill
        └── SKILL.md
```

## Install

```bash
git clone <url> ~/agent-skills   # or however you want to place it
cd ~/agent-skills
./install.sh
```

Install is idempotent: re-run after `git pull` to pick up new skills and
prune removed ones. Colliding real files are backed up with a `.bak.` suffix,
never deleted. Uninstall with `./uninstall.sh`.

## Adding a skill

```bash
mkdir skills/<name>
```

Write `skills/<name>/SKILL.md`:

```markdown
---
name: <name>
description: What the skill does and when to use it. One line, ≤ 1024 chars.
---

# <Name>

Instructions the agent follows. Use relative paths from this directory to
reference scripts/ and references/ files.
```

Rules, enforced by `validate.sh`:

- `name` **must equal the directory name**. It must be 1-64 chars of lowercase
  `a-z`, `0-9`, and single hyphens. Claude Code derives its `/command` from the
  directory name, and the spec requires both to agree.
- `description` must be a single line, non-empty, at most 1024 chars. Put the
  key use case first; that is what the agent sees before the skill loads.
- Keep shared content harness-agnostic: no `${CLAUDE_*}` or `$ARGUMENTS`
  substitution variables and no shell-injection syntax specific to one agent.
  Scripts should take arguments and env vars.
- Helper scripts and docs go under the skill's own `scripts/`, `references/`,
  `assets/` subdirectories, referenced by relative path.

## Notes

- **Security**: skills are arbitrary instructions/scripts the agent runs.
  Review any skill before adding it to this repo, and when pulling changes.
- **Live updates**: pi scans skills at startup; Claude Code reloads edits to
  already-loaded skills mid-session. After `git pull && ./install.sh`, restart
  pi sessions to pick up changes.
- **Secrets**: keep API keys in environment variables or `~/.config/<name>/`,
  never in this repo.