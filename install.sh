#!/usr/bin/env bash
#
# install.sh - symlink every skills/<name>/ directory in this repo into each
# agent's skill directory, so all harnesses share one copy of each skill.
#
# Idempotent: rerun after `git pull` to add new skills, refresh links after a
# repo move, and prune links for skills that were removed from the repo.
# Real files or directories that collide with a skill name are backed up
# (<target>-backup/<name>.bak.<timestamp>.<pid>), outside the skills directory
# so harnesses never load the backup as a duplicate skill, and never deleted.
# A symlink that already resolves to the repo's own copy is left alone.
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

# Absolute, symlink-free form of a path, trailing slashes ignored. Empty when
# the path cannot be resolved.
resolved() {
  local path="$1"
  while [ "${path%/}" != "$path" ]; do path="${path%/}"; done
  realpath "$path" 2>/dev/null || true
}

backup() {
  local target="$1" path="$2"
  local dir="$target-backup"
  local dest
  dest="$dir/$(basename "$path").bak.$(date +%Y%m%d%H%M%S).$$"
  mkdir -p "$dir"
  mv "$path" "$dest"
  backups=$((backups + 1))
  printf '  backed up %s -> %s\n' "$path" "$dest"
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
        if [ "$(resolved "$link")" = "$(resolved "$entry")" ]; then
          printf 'ok       %s\n' "$link"
          continue
        fi
        printf 'replacing %s -> %s\n' "$link" "$dest"
        backup "$target" "$link"
      elif [ -e "$link" ]; then
        printf 'conflict %s (real file or dir)\n' "$link"
        backup "$target" "$link"
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