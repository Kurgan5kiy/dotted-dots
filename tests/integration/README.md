# Live integration checks

## Native pixel latency and edge cancellation

```sh
python3 tests/integration/test-native-timing.py --output dist/verification/native-timing.json
python3 tests/integration/test_timing_helpers.py
```

Requires the installed Niri, Quickshell, PipeWire tools, `grim`,
`dbus-run-session` and libwayland-client. No package installation is performed.
The test opens one nested Niri window with its own configuration, runtime
directory and D-Bus session; it never uses `--session`. A minimal Python
virtual-pointer client connects explicitly to that owned private socket and
rejects host sockets or paths escaping through symlinks. Your desktop cursor
is not moved. Audio clients use the private null-sink server described below.

The actual shell runs in a temporary copy with observation/reset handlers and
a synthetic white background plus a real fullscreen white application window.
Production audio, trigger, placement, lifecycle, visual components and motion
defaults are retained. The direct-action trials invoke the real `bin/dot-shell`
wrapper through a temporary named configuration.

Each latency trial starts immediately before spawning its audio command. The
test then captures only the OSD region inside the private compositor, using
uncompressed PPM output from `grim`. A visible response requires at least 16
pixels whose red channel changes from white by at least four code values.
Reported times include command startup, IPC, capture and detection overhead,
so they are conservative observed upper bounds for that pixel response. They
do not measure human perception, physical display scanout, hardware audio
confirmation or shell-process startup.

There are 20 external-audio and 20 direct-CLI trials, each required to respond
within 500 ms. Twenty edge dwells verify one summon each and record first,
middle and settled compositor frames showing leftward field expansion. Twenty
early exits must leave before the 100 ms dwell and produce neither a summon
nor changed pixels. Resetting waits for a clean white capture, and output
geometry must stay fixed during measurement.

The JSON contains all raw samples; its sibling `*-frames/` directory contains
60 synthetic PPM frames. No host desktop image or private artwork is captured.
`--trials 1` is a smoke test only, not a 20-trial acceptance pass. Both the
nested compositor and all test clients/servers are stopped on exit; the test
shell also has a two-minute watchdog. This is Niri's nested Winit backend at
one scale, not evidence for multiple physical displays or the direct hardware
backend. The protocol ABI is based on the public
[wlr virtual-pointer specification](https://github.com/swaywm/wlr-protocols/blob/master/unstable/wlr-virtual-pointer-unstable-v1.xml).

## Private audio-service and trigger checks

Run `python3 tests/integration/test-private-audio.py` in the Wayland session
with Quickshell, PipeWire, `pw-dump`, `pw-cli` and `pw-metadata` installed.
The script starts a separate PipeWire server using `private-pipewire.conf` in
a private temporary runtime directory. It loads two null sinks only: no ALSA,
PulseAudio, session manager or hardware discovery. Every client explicitly
selects this private remote; the script checks the exact sink names before any
write. No system volume, user configuration or global service is changed.

It exercises the actual `AudioService.qml`: a confirmed null-sink write,
injected unconfirmed pending state reaching the real 1000 ms deadline,
default-sink switch cancelling a pending request, sink removal, rejection while
unavailable and recovery. The pending state is injected through a test-only
handler; this is not a real hardware write-failure simulation.

It then launches an instrumented temporary copy of the real shell root with
edge triggering disabled and an input-transparent left-side OSD. Twenty trials
each verify external summoning, direct-action summoning and suppressed external
summoning when disabled, including confirmed values and a single loaded OSD.
Only test observation/reset handlers and the window input mask differ from the
production copy. The temporary instance and server are stopped on exit; a
30-second watchdog also bounds each Quickshell stage.

These tests establish private-graph service and trigger behavior on the stated
environment. They do not establish physical device compatibility, keyboard
binding installation, actual backend rejection, edge behavior or first-pixel
presentation latency. Full latency trials remain separate acceptance work.

## Edge sensor diagnostic

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
