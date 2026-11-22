#!/usr/bin/env bash
set -euo pipefail
root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/dot-shell-package-test.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
"$root_dir/scripts/package-release.sh" v2026.1.0
(cd "$root_dir/dist" && sha256sum -c SHA256SUMS)
tar -xzf "$root_dir/dist/dot-shell-linux.tar.gz" -C "$test_dir"
test -s "$test_dir/dot-shell/share/quickshell/dot-shell/shell.qml"
test -s "$test_dir/dot-shell/share/quickshell/dot-shell/config/Validation.js"
test -s "$test_dir/dot-shell/share/quickshell/dot-shell/services/AudioService.qml"
test -s "$test_dir/dot-shell/share/quickshell/dot-shell/visual/FeatheredBackdrop.qml"
DOT_SHELL_INSTALL_ROOT="$test_dir/dot-shell" "$test_dir/dot-shell/bin/dot-shell" help >/dev/null
printf 'Package content and checksum tests passed.\n'
