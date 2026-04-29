#!/usr/bin/env bash
# Symlink every skill in ./skills into ~/.claude/skills/.
# Re-run anytime — existing symlinks are refreshed; real directories are left alone.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_root="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

mkdir -p "$target_root"

for skill_dir in "$repo_root"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  link="$target_root/$name"

  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "skip: $link exists and is not a symlink" >&2
    continue
  fi

  ln -sfn "${skill_dir%/}" "$link"
  echo "linked: $link -> ${skill_dir%/}"
done
