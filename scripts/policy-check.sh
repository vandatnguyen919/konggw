#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$ROOT_DIR/teams}"
failed=0

files=()
if [[ -f "$TARGET_DIR" ]]; then
  files=("$TARGET_DIR")
elif [[ -f "$TARGET_DIR/kong.yaml" ]]; then
  files=("$TARGET_DIR/kong.yaml")
else
  files=("$TARGET_DIR"/*/kong.yaml)
fi

for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue
  team="$(basename "$(dirname "$file")")"
  [[ "$team" == "fixtures" ]] && team="$(basename "$(dirname "$(dirname "$file")")")"
  expected_tag="team:$team"
  if ! awk -v file="$file" -v tag="$expected_tag" '
    function check_entity() {
      if (entity != "" && !has_tag) {
        printf "FAIL %s: entity %s is missing required %s tag\n", file, entity, tag > "/dev/stderr"
        failed = 1
      }
    }
    /^[ ]*- name:/ {
      indent = match($0, /[^ ]/) - 1
      if (entity != "" && indent <= entity_indent) check_entity()
      entity = $0
      entity_indent = indent
      has_tag = 0
      next
    }
    index($0, tag) > 0 { has_tag = 1 }
    END {
      check_entity()
      exit failed
    }
  ' "$file"; then
    failed=1
  fi
  if grep -Fq "owner:platform" "$file"; then
    echo "FAIL $file: team config touches a platform-owned entity" >&2
    failed=1
  fi
  if ! grep -Eq 'name:[[:space:]]*key-auth([[:space:]]|$)' "$file"; then
    echo "FAIL $file: every team service must define key-auth" >&2
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi
echo "Policy passed for $TARGET_DIR."
