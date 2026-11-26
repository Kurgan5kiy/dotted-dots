# Validation Guide

The development runtime and volume-v1 commands exist on the implementation branch. Configuration schema v2 and the clarified multi-output routing are planned but not yet implemented. The feature is not converged; use this guide to validate the refinement after its tasks are approved and implemented.

## Prerequisites

Use Niri 26.04 with two physical outputs, PipeWire, a working default sink, Quickshell 0.3.2, Qt 6 formatter/linter and QML Test. Record versions, hardware, output names, layout and scale factors without copying private configuration into evidence. Empty-workspace pointer fallback requires an existing focus-follows-mouse setup on this baseline. Inspect and test that behavior, but do not automatically alter the user's Niri configuration or system installation.

## Pre-implementation feasibility gate

Before implementation, verify that `niri msg -j event-stream` reports initial
workspace/output state and focus changes on the target Niri version. In a
disposable test configuration, test one middle-third sensor at an outer edge
and one at an edge shared by adjacent displays. Verify exact third boundaries,
top/bottom pass-through, dwell, cancellation, normal window interaction,
monitor crossing and pointer-over-OSD detection without full-screen input
capture. Confirm that moving the pointer between empty workspaces updates the
focused output on the user's focus-follows-mouse setup. If any required behavior
fails, return to the spec rather than adding polling or capture.

Use configuration schema v2 for validation. The default already produces the
requested right/right behavior:

```json
{
  "schemaVersion": 2,
  "placement": { "fallbackOutput": "", "margin": 0 },
  "edge": {
    "enabled": true,
    "dwellMs": 100,
    "width": 1,
    "side": "right",
    "outputs": {}
  }
}
```

Also test an explicit copy and mirrored copy using non-private test output
names, following [configuration.md](contracts/configuration.md). Never write a
generated configuration over the user's file.

## Automated checks

Run these commands from the repository root after the refinement tasks are
implemented. Existing feature source/tests are present; the new routing,
configuration and zone tests are required additions. Point the check script at the installed Qt/Quickshell paths
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

1. Test 20 external volume/mute changes and 20 middle-third edge dwell/cancellation trials; record latency from the initiating audio-command process invocation to the first visible response, including startup and IPC, as specified in SC-002.
   Repeat with external-change summoning disabled: shell audio actions must summon directly, external changes must not open the dormant OSD, and confirmed state must remain accurate. Record both modes' response latency so the user can choose based on evidence.
2. Exercise slider, mute dot, keys, rapid updates, hover timeout, output removal, audio failure, invalid configuration and recovery.
3. Record bright, dark, colorful and busy licensed fixtures and an open window, covering normal, hover, active and unavailable states. Compare the approved moving field, fading dots, fixed vertical chain, handwritten values and solid mute dot with the reviewed baseline. Check full transparency at non-screen boundaries under pointer motion. Record contrast measurements and visibility limits as diagnostics, not fixed-ratio gates; do not redesign the accepted theme to satisfy the superseded numbers.
4. With a focused window, split 20 dormant non-pointer summons across both physical outputs and require all 20 to appear only on the focused-window output. Repeat 20 trials on empty workspaces with the pointer split across both outputs; require all 20 to appear only on the pointer output. Save Niri event-stream state and selected output without recording private window titles.
5. Test the right/right default, then explicit same-side copy and mirrored left/right profiles. Exercise ten middle-third dwells per output, ten top-third and ten bottom-third dwells, focus changes during emergence/interaction/retraction, output removal and a second sensor while one OSD is visible. Reserved thirds must not summon volume or intercept their test clicks.
6. Run pure geometry/routing tests at logical scales 1.0, 1.25, 1.5 and 2.0. Live evidence must cover both physical outputs and at least two scale factors. If the physical setup uses one scale, obtain explicit authorization for a temporary, non-persistent two-output test-session change to 1.0 and 1.25. Otherwise leave SC-006 open; a single-output nested run is supplemental only.
7. Repeat interaction and dismissal with reduced motion. Record frame and idle observations with hardware and method; disclose untested compositor, output, hardware, GPU, reserved-area and visual cases.
