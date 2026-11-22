#!/usr/bin/env sh
set -eu

root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
version=${1:-}

if ! printf '%s\n' "$version" | grep -Eq '^v[0-9]{4}\.[1-9][0-9]*\.[0-9]+$'; then
  printf 'usage: %s vYEAR.RELEASE.PATCH\n' "$0" >&2
  exit 2
fi

[ -f "$root_dir/src/shell.qml" ] || {
  printf 'release packaging requires src/shell.qml\n' >&2
  exit 1
}

dist_dir="$root_dir/dist"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dot-shell-package.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

package_dir="$tmp_dir/dot-shell"
mkdir -p "$package_dir/bin" "$package_dir/share/quickshell/dot-shell" "$dist_dir"

install -m 0755 "$root_dir/bin/dot-shell" "$package_dir/bin/dot-shell"
cp -R "$root_dir/src/." "$package_dir/share/quickshell/dot-shell/"
cp "$root_dir/LICENSE" "$package_dir/LICENSE"
cp "$root_dir/README.md" "$package_dir/README.md"
printf '%s\n' "${version#v}" > "$package_dir/VERSION"

archive="$dist_dir/dot-shell-linux.tar.gz"
tar -C "$tmp_dir" -czf "$archive" dot-shell
(
  cd "$dist_dir"
  sha256sum "$(basename "$archive")" > SHA256SUMS
)

printf 'Created %s\n' "$archive"
