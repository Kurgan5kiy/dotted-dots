#!/usr/bin/env sh
set -eu

root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)

command -v uv >/dev/null 2>&1 || {
  printf 'uv is required. Install it from https://docs.astral.sh/uv/\n' >&2
  exit 1
}

if ! command -v specify >/dev/null 2>&1; then
  uv tool install specify-cli
fi

cd "$root_dir"
specify version
specify init --here --force --integration codex --script sh

printf '\nSpec Kit initialized for Codex. Review the generated diff before committing.\n'
