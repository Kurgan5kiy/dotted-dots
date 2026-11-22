#!/usr/bin/env bash
set -euo pipefail
root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
cd "$root_dir"
qt_bin=${DOT_SHELL_QT_BIN:-/usr/lib/qt6/bin}
qml_import=${DOT_SHELL_QML_IMPORT:-/usr/lib/qt6/qml}
check_dir=$(mktemp -d "${TMPDIR:-/tmp}/dot-shell-qml-check.XXXXXX")
mkdir -p dist/visual
trap 'rm -rf "$check_dir"' EXIT
for qt_tool in qmlformat qmllint qmltestrunner; do
    test -x "$qt_bin/$qt_tool" || { printf 'Missing Qt tool: %s\n' "$qt_bin/$qt_tool" >&2; exit 1; }
done
test -s "$qml_import/Quickshell/qmldir" || { printf 'Quickshell QML imports are required.\n' >&2; exit 1; }
while IFS= read -r -d '' qml_file; do
    "$qt_bin/qmlformat" "$qml_file" > "$check_dir/formatted.qml"
    diff -u "$qml_file" "$check_dir/formatted.qml"
    # Quickshell 0.3.2's generated metadata marks its runtime PanelWindow
    # factory uncreatable and shadows its margins value type as opaque.
    # Accept only these exact known diagnostics; missing imports and all
    # other warnings remain failures. Live qs loading is checked separately.
    lint_status=0
    "$qt_bin/qmllint" -I "$qml_import" "$qml_file" > "$check_dir/lint.txt" 2>&1 || lint_status=$?
    if [ "$lint_status" -ne 0 ] && [ "$lint_status" -ne 255 ]; then
        cat "$check_dir/lint.txt" >&2
        exit "$lint_status"
    fi
    if [ "$lint_status" -ne 0 ] || [ -s "$check_dir/lint.txt" ]; then
        if ! awk -v file="$qml_file" '
            /^Warning:|^Error:|^Critical:/ {
                known = ($0 ~ /Type PanelWindow is not creatable\. \[uncreatable-type\]$/)
                if (file == "src/surfaces/volume/VolumeOsd.qml" && $0 ~ /Could not find property "(left|top)"\. \[missing-property\]$/) known = 1
                if (!known) bad = 1
                seen = 1
            }
            END {exit bad || !seen}
        ' "$check_dir/lint.txt"; then
            cat "$check_dir/lint.txt" >&2
            exit 1
        fi
        printf 'Known Quickshell metadata diagnostics only: %s\n' "$qml_file"
    fi
done < <(rg --files src tests/qml tests/visual tests/performance tests/integration/TimingControls.qml -g '*.qml' -0)
QT_QUICK_BACKEND=software "$qt_bin/qmltestrunner" -platform offscreen -input tests/qml
