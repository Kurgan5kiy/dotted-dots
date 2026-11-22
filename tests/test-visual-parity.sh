#!/usr/bin/env bash
set -euo pipefail
root_dir=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
baseline_dir=${1:?Provide an absolute path to a before-refactor src copy}
probe_dir=$(mktemp -d "${TMPDIR:-/tmp}/dot-shell-parity.XXXXXX")
trap 'rm -rf "$probe_dir"' EXIT
python3 - "$root_dir" "$baseline_dir" "$probe_dir/tst_parity.qml" <<'PY'
import json
from pathlib import Path
import sys
root, baseline, output = map(Path, sys.argv[1:])
if not (baseline / "surfaces/volume/VolumeField.qml").is_file():
    raise SystemExit("Baseline VolumeField.qml is missing")
output.write_text('import ' + json.dumps((root / "tests/visual").as_uri()) + '\n'
                  'Parity { baselinePath: ' + json.dumps(str(baseline.resolve())) + ' }\n')
PY
QT_QUICK_BACKEND=software "${DOT_SHELL_QT_BIN:-/usr/lib/qt6/bin}/qmltestrunner" \
    -platform offscreen -input "$probe_dir"
