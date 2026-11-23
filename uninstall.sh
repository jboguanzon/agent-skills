#!/usr/bin/env bash
#
# uninstall.sh - remove only the symlinks this repo created. Anything else
# (real files, directories, backups) is left untouched.
set -euo pipefail

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

removed=0
for target in "${TARGETS[@]}"; do
  if [ ! -d "$target" ]; then
    continue
  fi
  for link in "$target"/*; do
    [ -L "$link" ] || continue
    dest="$(readlink "$link")"
    case "$dest" in
      "$SKILL_ROOT"/*) ;;
      *) continue ;;
    esac
    rm "$link"
    printf 'removed %s -> %s\n' "$link" "$dest"
    removed=$((removed + 1))
  done
done

printf '\nRemoved %d symlink(s). Backups created by install.sh live in <target>-backup/ and are left in place for you to review.\n' "$removed"