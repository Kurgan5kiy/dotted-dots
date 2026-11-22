#!/usr/bin/env sh
set -eu

REPOSITORY=${DOT_SHELL_REPOSITORY:-Kurgan5kiy/dotted-dots}
VERSION=${DOT_SHELL_VERSION:-latest}

data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
bin_home=${DOT_SHELL_BIN_DIR:-"$HOME/.local/bin"}
install_root=${DOT_SHELL_INSTALL_ROOT:-"$data_home/dot-shell"}
versions_dir="$install_root/versions"
current_link="$install_root/current"
config_link="$config_home/quickshell/dot-shell"

die() {
  printf 'dot-shell installer: %s\n' "$*" >&2
  exit 1
}

for command_name in curl tar sha256sum mktemp; do
  command -v "$command_name" >/dev/null 2>&1 || die "$command_name is required"
done

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dot-shell-install.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

if [ "$VERSION" = latest ]; then
  release_base="https://github.com/$REPOSITORY/releases/latest/download"
else
  release_base="https://github.com/$REPOSITORY/releases/download/$VERSION"
fi

archive=dot-shell-linux.tar.gz
printf 'Downloading Dot Shell (%s)...\n' "$VERSION"
curl -fsSL "$release_base/$archive" -o "$tmp_dir/$archive"
curl -fsSL "$release_base/SHA256SUMS" -o "$tmp_dir/SHA256SUMS"

(
  cd "$tmp_dir"
  expected=$(grep "  $archive\$" SHA256SUMS || true)
  [ -n "$expected" ] || die "release checksum does not list $archive"
  printf '%s\n' "$expected" | sha256sum -c -
  tar -xzf "$archive"
)

package_dir="$tmp_dir/dot-shell"
[ -r "$package_dir/VERSION" ] || die "release archive has no VERSION file"
resolved_version=$(sed -n '1p' "$package_dir/VERSION")
case "$resolved_version" in
  ''|*[!0-9A-Za-z._-]*) die "release contains an invalid version" ;;
esac

mkdir -p "$versions_dir" "$bin_home" "$(dirname "$config_link")"
destination="$versions_dir/$resolved_version"

if [ ! -e "$destination" ]; then
  mv "$package_dir" "$destination"
fi

ln -sfn "$destination" "$current_link"
ln -sfn "$current_link/bin/dot-shell" "$bin_home/dot-shell"

if [ ! -e "$config_link" ] && [ ! -L "$config_link" ]; then
  ln -s "$current_link/share/quickshell/dot-shell" "$config_link"
elif [ -L "$config_link" ]; then
  current_config_target=$(readlink "$config_link")
  expected_config_target="$current_link/share/quickshell/dot-shell"
  if [ "$current_config_target" != "$expected_config_target" ]; then
    printf 'Keeping existing Quickshell configuration link: %s\n' "$config_link"
  fi
else
  printf 'Keeping existing Quickshell configuration directory: %s\n' "$config_link"
  printf 'Link it to %s when ready.\n' "$current_link/share/quickshell/dot-shell"
fi

printf '\nDot Shell %s installed.\n' "$resolved_version"
printf 'CLI: %s/dot-shell\n' "$bin_home"
printf 'Quickshell config: %s\n' "$config_link"
printf '\nDot Shell does not edit your Niri configuration.\n'
printf 'Add `spawn-at-startup "dot-shell" "start"` yourself when desired.\n'
