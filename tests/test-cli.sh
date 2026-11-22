#!/usr/bin/env sh
set -eu

root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dot-shell-test.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

fake_bin="$tmp_dir/bin"
calls_file="$tmp_dir/calls"
mkdir -p "$fake_bin"

cat > "$fake_bin/qs" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$*" >> "$DOT_SHELL_TEST_CALLS"
case "$*" in
  *"ipc show"*) exit "${DOT_SHELL_TEST_STATUS:-0}" ;;
esac
exit 0
EOF
chmod +x "$fake_bin/qs"

export PATH="$fake_bin:$PATH"
export DOT_SHELL_TEST_CALLS="$calls_file"
export DOT_SHELL_CONFIG_NAME="dot-shell-test"
export XDG_DATA_HOME="$tmp_dir/data"
export XDG_STATE_HOME="$tmp_dir/state"

"$root_dir/bin/dot-shell" ipc call overlay show volume 42
grep -Fx -- '-c dot-shell-test ipc call -- overlay show volume 42' "$calls_file" >/dev/null

"$root_dir/bin/dot-shell" ipc call -- volume_v1 show
grep -Fx -- '-c dot-shell-test ipc call -- volume_v1 show' "$calls_file" >/dev/null

: > "$calls_file"
"$root_dir/bin/dot-shell" status >/dev/null
grep -Fx -- '-c dot-shell-test ipc show' "$calls_file" >/dev/null

version_output=$("$root_dir/bin/dot-shell" version)
[ "$version_output" = development ]

"$root_dir/bin/dot-shell" help | grep -F 'ipc call TARGET FN' >/dev/null

printf 'CLI tests passed.\n'
