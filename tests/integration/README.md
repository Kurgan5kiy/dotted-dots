# Edge sensor diagnostic

This isolated diagnostic changes neither audio nor Niri configuration. It is not the final volume OSD or its visual design. It owns a one-logical-pixel input strip at each output's right edge and, when shown, the 300 × 120 test panel's input area. It does not reserve desktop space or take keyboard focus.

Run in a Niri Wayland session with Quickshell 0.3.2:

```sh
qs -p tests/integration/edge-sensor.qml
```

Hold the pointer at an output's right edge for 200 ms. A labelled panel should appear. It should stay while hovered and disappear two seconds after leaving. Test typing into another application, moving quickly past the edge, and crossing to an adjacent output if available. The experiment has a five-minute lifetime and makes no persistent changes.

From another terminal:

```sh
qs -p tests/integration/edge-sensor.qml ipc call edge_test count
qs -p tests/integration/edge-sensor.qml ipc call edge_test stop
```

Formatter: `/usr/lib/qt6/bin/qmlformat -i tests/integration/edge-sensor.qml`.
Linter: `/usr/lib/qt6/bin/qmllint -I /usr/lib/qt6/qml tests/integration/edge-sensor.qml`.
Qt 6.12's linter currently reports two `uncreatable-type` warnings for PanelWindow; the runtime loaded the same file successfully under Quickshell 0.3.2. This is an unresolved tooling discrepancy, not a clean lint result. Do not suppress import errors or turn these observations into a general compatibility claim.
