# Native presentation and edge trials

Result: the two 20-trial audio presentation groups, 20 edge dwells and 20 early
exits passed in the isolated nested-Niri setup below. This supplements the
earlier private-graph summon-policy tests and preserves the approved runtime.

## Environment and isolation

- Niri 26.04 (`8ed0da4`), nested Winit backend; Quickshell 0.3.2; Qt 6.12.0;
  Intel Core Ultra 5 125U / Mesa Intel Graphics (MTL).
- One private output: 934 × 1136 logical pixels, scale 1.0. OSD capture region:
  180 × 540 at (754,298). The backend reports transform Flipped180.
- Default normal motion: 100 ms edge dwell and 400 ms emergence. Reduced
  motion was explicitly checked false by the observation handler.
- A real fullscreen white application window covered the private output;
  the OSD's production overlay appeared above it. A generated background also
  ensured no personal artwork could enter a capture.
- Niri had its own temporary configuration/runtime directory and D-Bus
  session, without `--session`. PipeWire used its own null-sink server. Virtual
  pointer requests were restricted to the private Wayland socket. No host
  cursor movement, system audio write or user configuration edit occurred.

## Method

Command: `python3 tests/integration/test-native-timing.py --output
dist/verification/native-timing.json`. Full reproduction and limitations are in
`tests/integration/README.md`. The report's raw samples are published alongside
this document as `native-timing.json`.

Each audio trial began dormant with a verified white compositor capture. The
clock started immediately before spawning `pw-cli` for an external change or
the actual `bin/dot-shell ipc call volume_v1 setPercent` command for a direct
action. All clients selected the private audio graph and named test config.
The test captured the OSD region with `grim` using uncompressed PPM output.
An observable response required at least 16 pixels with red channel <= 251
against the white fixture. Times include process creation, command startup,
IPC, capture and detection; they conservatively bound this pixel response.
The test also checked the confirmed value and exactly one loaded/summoned OSD.

| Audio presentation group | Trials | Minimum | Median | Maximum | Under 500 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| External change, automatic summoning enabled | 20 | 95.252 ms | 126.049 ms | 184.362 ms | 20/20 |
| Direct public CLI action, automatic summoning disabled | 20 | 122.883 ms | 160.026 ms | 206.089 ms | 20/20 |

These satisfy SC-002's measured response target in this stated setup. They do
not measure shell-process startup, audio hardware confirmation, human
perception or physical display scanout. Nested Winit results are not direct
hardware-backend measurements or mixed-scale/multi-monitor evidence.

## Edge activation and cancellation

Each dwell trial reset dormant, moved the private pointer from the output
center to its rightmost logical pixel, then captured the first changed frame,
a middle frame and a settled frame. All 20 trials produced exactly one OSD
above the real application window. First captured response, including the
dwell, ranged from 243.093 to 331.862 ms (median 259.507 ms).

In every recorded sequence the minimum changed x-coordinate moved leftward
from first to middle to settled frame. The 60 original PPM frames are generated
under `dist/verification/native-timing-frames/`; the raw report lists their
filenames and measured coordinates. A representative native sequence is
published under `visual/native-edge.gif`. This is sampled motion evidence,
not a high-frame-rate smoothness or GPU presentation certification.

All 20 early-exit trials left before the 100 ms dwell expired: observed
entry-to-exit bounds ranged from 21.125 to 35.666 ms. Each waited beyond the
dwell afterward, observed no summon and retained the clean white capture.
SC-007 therefore passes for this single private output. Adjacent-output
crossing, physical output loss and mixed scale factors remain open in T003 /
T032; this result does not replace them.

## Verification boundary

The test uses an instrumented copy of the real shell for observation and reset,
plus synthetic fixture windows. Production services, trigger policy, routing,
lifecycle, OSD window/input region, visuals and motion defaults are unchanged.
Six non-GUI helper tests validate the pixel threshold, capture payload and
private-pointer guards, including host-socket and symlink-escape rejection.
No additional runtime dependency or product behavior was introduced.
