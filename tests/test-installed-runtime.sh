#!/usr/bin/env bash
set -euo pipefail
root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/dot-shell-installed-test.XXXXXX")
test_cli="$test_dir/dot-shell/bin/dot-shell"
cleanup() {
    if [ -x "$test_cli" ]; then
        XDG_CONFIG_HOME="$test_dir/config" "$test_cli" stop >/dev/null 2>&1 || true
    fi
    rm -rf "$test_dir"
}
trap cleanup EXIT
test -n "${WAYLAND_DISPLAY:-}" || { printf 'A live Wayland session is required.\n' >&2; exit 1; }
"$root_dir/tests/test-package.sh"
tar -xzf "$root_dir/dist/dot-shell-linux.tar.gz" -C "$test_dir"
mkdir -p "$test_dir/config/quickshell" "$test_dir/config/dot-shell"
cp "$root_dir/tests/fixtures/runtime-config.json" "$test_dir/config/dot-shell/config.json"
ln -s "$test_dir/dot-shell/share/quickshell/dot-shell" "$test_dir/config/quickshell/dot-shell"
export XDG_CONFIG_HOME="$test_dir/config"
qs -d -c dot-shell --no-color
"$test_cli" status
"$test_cli" ipc call volume_v1 state | jq -e '.version == 1 and (.available | type == "boolean")' >/dev/null
"$test_cli" ipc call volume_v1 show | jq -e '.status == "accepted"' >/dev/null
"$test_cli" ipc call bar_v1 reveal "" | jq -e '.version == 1 and .status == "accepted"' >/dev/null
"$test_cli" stop
printf 'Installed runtime lookup, IPC and lifecycle smoke test passed.\n'
