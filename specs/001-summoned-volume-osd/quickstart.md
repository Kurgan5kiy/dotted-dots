# Validation Guide

Draft protocol: the feature runtime and its commands do not exist yet.

## Prerequisites

Use a test Niri Wayland session with PipeWire, a working default sink, Quickshell 0.3.2, Qt 6 formatter/linter and QML Test. Record versions, hardware, output layout and scale factors. Do not automatically alter the user's Niri configuration or system installation.

## Pre-implementation feasibility gate

In a disposable test configuration, test a sensor at an outer edge and an edge shared by adjacent displays. Verify dwell, cancellation, normal window interaction, monitor crossing and pointer-over-OSD detection without full-screen input capture. Record results. If required behavior fails, return to the spec.

## Automated checks

Once implemented, the following planned commands run from the repository root. `tests/qml/` and feature source files will be created by implementation tasks. Point `QML_IMPORT_PATH` at the installed Quickshell QML modules; missing imports are a failure, not a reason to suppress lint warnings.

```sh
tests/test-cli.sh
tests/test-commit-message.sh
/usr/lib/qt6/bin/qmltestrunner -platform offscreen -input tests/qml
rg --files src tests/qml -g '*.qml' -0 | xargs -0 -r /usr/lib/qt6/bin/qmlformat -i
git diff --exit-code -- src tests/qml
rg --files src -g '*.qml' -0 | xargs -0 -r /usr/lib/qt6/bin/qmllint
qs -p src/shell.qml
```

The formatter command is the CI formatting check and expects a clean, committed implementation checkout; during development review formatter changes before committing. Qt tool locations may differ by distribution. Unit tests must cover configuration, sink changes, lifecycle, dwell, pending-write confirmation and timers; offscreen tests do not replace compositor verification.

After packaging with `scripts/package-release.sh v2026.1.0` in a test checkout, extract the archive to a temporary directory and run `qs -p` against its `share/quickshell/dot-shell/shell.qml`. Verify the installed CLI selects that configuration, and verify checksums and CLI status without modifying global installation paths.

## End-to-end and visual checks

1. Test 20 external volume/mute changes and 20 edge dwell/cancellation trials; record latency from the initiating audio-command process invocation to the first visible response, including startup and IPC, as specified in SC-002.
   Repeat with external-change summoning disabled: shell audio actions must summon directly, external changes must not open the dormant OSD, and confirmed state must remain accurate. Record both modes' response latency so the user can choose based on evidence.
2. Exercise slider, mute dot, keys, rapid updates, hover timeout, output removal, audio failure, invalid configuration and recovery.
3. Record bright, dark, colorful and busy licensed fixtures and an open window. Measure contrast against the composited background (4.5:1 for volume text, 3:1 for essential indicators), covering normal, hover, active and unavailable states. Record the tool/method and results, fading edges and the mute dot's non-colour distinction.
4. Repeat on multiple outputs including adjacent edges and two scale factors, then repeat interaction and dismissal with reduced motion.
5. Record frame and idle observations with hardware and method; disclose untested compositor, output, hardware, GPU and visual cases.
