# Validation Guide

The development runtime and v1 commands exist on the implementation branch. The feature is not yet converged; use this guide to complete the outstanding acceptance work.

## Prerequisites

Use a test Niri Wayland session with PipeWire, a working default sink, Quickshell 0.3.2, Qt 6 formatter/linter and QML Test. Record versions, hardware, output layout and scale factors. Do not automatically alter the user's Niri configuration or system installation.

## Pre-implementation feasibility gate

In a disposable test configuration, test a sensor at an outer edge and an edge shared by adjacent displays. Verify dwell, cancellation, normal window interaction, monitor crossing and pointer-over-OSD detection without full-screen input capture. Record results. If required behavior fails, return to the spec.

## Automated checks

Run these commands from the repository root. The feature source and QML tests
are implemented. Point the check script at the installed Qt/Quickshell paths
with `DOT_SHELL_QT_BIN` and `DOT_SHELL_QML_IMPORT` when needed; missing imports
are a failure, not a reason to suppress lint warnings.

```sh
tests/test-cli.sh
tests/test-commit-message.sh
scripts/check-qml.sh
tests/test-package.sh
qs -p src/shell.qml
```

The QML script compares formatter output without editing source, lints against installed Quickshell imports and runs software-rendered offscreen tests. Its narrowly documented metadata exceptions are reported in verification.md. Qt tool locations may differ by distribution. Offscreen tests do not replace compositor verification.

After packaging with `scripts/package-release.sh v2026.1.0` in a test checkout, extract the archive to a temporary directory and run `qs -p` against its `share/quickshell/dot-shell/shell.qml`. Verify the installed CLI selects that configuration, and verify checksums and CLI status without modifying global installation paths.

`tests/test-installed-runtime.sh` automates the live packaged-runtime lookup/status/state/show smoke check using a temporary named configuration with edge and external-change triggers disabled. It stops its own instance and sends no audio changes.

## End-to-end and visual checks

1. Test 20 external volume/mute changes and 20 edge dwell/cancellation trials; record latency from the initiating audio-command process invocation to the first visible response, including startup and IPC, as specified in SC-002.
   Repeat with external-change summoning disabled: shell audio actions must summon directly, external changes must not open the dormant OSD, and confirmed state must remain accurate. Record both modes' response latency so the user can choose based on evidence.
2. Exercise slider, mute dot, keys, rapid updates, hover timeout, output removal, audio failure, invalid configuration and recovery.
3. Record bright, dark, colorful and busy licensed fixtures and an open window, covering normal, hover, active and unavailable states. Compare the approved moving field, fading dots, fixed vertical chain, handwritten values and solid mute dot with the reviewed baseline. Check full transparency at non-screen boundaries under pointer motion. Record contrast measurements and visibility limits as diagnostics, not fixed-ratio gates; do not redesign the accepted theme to satisfy the superseded numbers.
4. Repeat on multiple outputs including adjacent edges and two scale factors, then repeat interaction and dismissal with reduced motion.
5. Record frame and idle observations with hardware and method; disclose untested compositor, output, hardware, GPU and visual cases.
