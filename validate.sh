#!/usr/bin/env bash
#
# validate.sh - check every skills/<name>/SKILL.md against the Agent Skills
# spec rules that matter for cross-harness use, where the strictest reader
# wins:
#
#   - frontmatter block with `name` and `description`
#   - `name` equals the parent directory name (spec requirement; Claude Code
#     derives its invokable command from the directory name)
#   - `name` is 1-64 chars of lowercase a-z, 0-9, and single hyphens
#   - `description` is a single line, non-empty, at most 1024 chars
#
# Prints a summary and exits 1 if any skill fails. install.sh runs this
# before touching anything.
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

fail=0
count=0

# Prints the YAML frontmatter block (between the opening and closing ---
# lines) of the file in $1. The block must start on line 1.
frontmatter() {
  awk '
    NR == 1 && $0 == "---" { c = 1; next }
    c == 1 && $0 == "---"  { c = 2; next }
    c == 2                  { exit }
    c == 1                  { print }
  ' "$1"
}

# First value of a top-level YAML field in a frontmatter block.
field() {
  printf '%s\n' "$2" | sed -n "s/^$1:[[:space:]]*//p" | head -n 1
}

error() {
  printf 'validate: %s: error: %s\n' "$1" "$2"
  fail=$((fail + 1))
}

if [ ! -d "$SKILL_ROOT" ]; then
  printf 'validate: no skills directory at %s\n' "$SKILL_ROOT"
  exit 1
fi

for entry in "$SKILL_ROOT"/*/; do
  [ -f "$entry/SKILL.md" ] || continue
  dir="$(basename "$entry")"
  file="$entry/SKILL.md"
  count=$((count + 1))

  fm="$(frontmatter "$file")"
  if [ -z "$fm" ]; then
    error "$dir" "SKILL.md must begin with a '---' frontmatter block on line 1"
    continue
  fi

  name="$(field name "$fm")"
  desc="$(field description "$fm")"

  if [ -z "$name" ]; then
    error "$dir" "missing 'name' in frontmatter"
  elif [ "$name" != "$dir" ]; then
    error "$dir" "frontmatter 'name: $name' does not match directory name '$dir'"
  fi
  if [ -n "$name" ] && ! printf '%s' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    error "$dir" "name '$name' must be lowercase a-z, 0-9, and single hyphens"
  fi
  if [ -n "$name" ] && [ "${#name}" -gt 64 ]; then
    error "$dir" "name '$name' exceeds 64 characters"
  fi
  if [ -z "$desc" ]; then
    error "$dir" "missing 'description' in frontmatter"
  elif [ "${#desc}" -gt 1024 ]; then
    error "$dir" "description exceeds 1024 characters"
  fi
done

if [ "$fail" -gt 0 ]; then
  printf 'validate: %d of %d skill(s) failed\n' "$fail" "$count"
  exit 1
fi
printf 'validate: %d skill(s) OK\n' "$count"