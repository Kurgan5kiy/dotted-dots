#!/usr/bin/env bash
set -euo pipefail

root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
validator="$root_dir/scripts/validate-commit-message.py"

python3 "$validator" 'Add the requested behavior.' >/dev/null
python3 "$validator" $'Add the requested behavior.\n\nDocument the resulting contract.' >/dev/null
python3 "$validator" $'Add the requested behavior.\n\nCo-authored-by: Dot Shell <dot-shell@example.com>' >/dev/null
python3 "$validator" $'Add the requested behavior.\n\nSigned-off-by: Dot Shell <dot-shell@example.com>\nCo-authored-by: Contributor <contributor@example.com>' >/dev/null

if python3 "$validator" 'add invalid behavior.' >/dev/null 2>&1; then
  printf 'Expected lowercase sentence to fail validation.\n' >&2
  exit 1
fi

if python3 "$validator" $'Add invalid behavior\n\nCo-authored-by: Dot Shell <dot-shell@example.com>' >/dev/null 2>&1; then
  printf 'Expected missing period before a trailer to fail validation.\n' >&2
  exit 1
fi

printf 'Commit-message validation tests passed.\n'
