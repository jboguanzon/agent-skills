#!/usr/bin/env bash
#
# install.sh - symlink every skills/<name>/ directory in this repo into each
# agent's skill directory, so all harnesses share one copy of each skill.
#
# Idempotent: rerun after `git pull` to add new skills, refresh links after a
# repo move, and prune links for skills that were removed from the repo.
# Real files or directories that collide with a skill name are backed up
# (name.bak.<timestamp>.<pid>) next to the collision, never deleted.
#
# pi and Claude Code both follow symlinked skill directories, so no copying
# is needed and every machine stays in sync with this repo.
set -euo pipefail

# Resolve this script's real location, following symlinks, so the repo can
# itself be cloned or symlinked anywhere.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  case "$SOURCE" in
    /*) ;;
    *) SOURCE="$DIR/$SOURCE" ;;
  esac
done
REPO="$(cd -P "$(dirname "$SOURCE")" && pwd)"

SKILL_ROOT="$REPO/skills"
# ~/.agents/skills is intentionally absent: the `npx skills` CLI owns that
# directory and manages installs and uninstalls there.
TARGETS=(
  "$HOME/.pi/agent/skills"
  "$HOME/.claude/skills"
)

backups=0

backup() {
  local dest="$1.bak.$(date +%Y%m%d%H%M%S).$$"
  mv "$1" "$dest"
  backups=$((backups + 1))
  printf '  backed up %s -> %s\n' "$1" "$dest"
}

main() {
  if [ ! -d "$SKILL_ROOT" ]; then
    printf 'install: no skills directory at %s\n' "$SKILL_ROOT"
    exit 1
  fi

  if [ -x "$REPO/validate.sh" ]; then
    "$REPO/validate.sh"
  else
    bash "$REPO/validate.sh"
  fi

  local linked=0 pruned=0
  local target entry skill link dest

  for target in "${TARGETS[@]}"; do
    [ -d "$target" ] || mkdir -p "$target"

    # Link each skill directory from the repo into this target.
    for entry in "$SKILL_ROOT"/*/; do
      [ -f "$entry/SKILL.md" ] || continue
      skill="$(basename "$entry")"
      link="$target/$skill"
      if [ -L "$link" ]; then
        dest="$(readlink "$link")"
        if [ "$dest" = "$entry" ]; then
          printf 'ok       %s\n' "$link"
          continue
        fi
        printf 'replacing %s -> %s\n' "$link" "$dest"
        backup "$link"
      elif [ -e "$link" ]; then
        printf 'conflict %s (real file or dir)\n' "$link"
        backup "$link"
      fi
      ln -s "$entry" "$link"
      printf 'linked   %s -> %s\n' "$link" "$entry"
      linked=$((linked + 1))
    done

    # Prune symlinks that point into this repo but whose skill is gone.
    for link in "$target"/*; do
      [ -L "$link" ] || continue
      dest="$(readlink "$link")"
      case "$dest" in
        "$SKILL_ROOT"/*) ;;
        *) continue ;;
      esac
      if [ ! -d "$dest" ]; then
        rm "$link"
        printf 'pruned   %s (stale symlink into repo)\n' "$link"
        pruned=$((pruned + 1))
      fi
    done
  done

  printf '\nDone: %d linked, %d pruned, %d backed up.\n' "$linked" "$pruned" "$backups"
  printf 'pi loads skills at the next session start; Claude Code reloads live.\n'
}

main "$@"