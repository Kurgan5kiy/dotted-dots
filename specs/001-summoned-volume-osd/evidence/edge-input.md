# Edge Input Experiment

## Environment

- Niri 26.04; Quickshell 0.3.2 installed by the user from the configured package repositories; Qt tooling 6.12.0.
- One reported output, logical size 1920 × 1200, scale 1.0. No adjacent-output or mixed-scale test is available in this configuration.
- Diagnostic: `tests/integration/edge-sensor.qml`; see its README for launch and stop commands.

## Observed results

- Quickshell reported `Configuration Loaded` in the real Wayland session without a QML load error.
- The final IPC counter reported ten edge summons. Captured initial dwell logs show 201–202 ms between pointer entry and timer activation, close to the configured 200 ms. This measures event-to-timer delay, not presentation or audio-change latency.
- The user reported that the diagnostic worked as described: the panel appeared on dwell, stayed while hovered and dismissed after leaving; no typing interference was reported. This is a user-observed single-display result, not complete UX acceptance.
- Formatter ran successfully. Qt's linter reported two PanelWindow `uncreatable-type` warnings, although Quickshell loaded those instances. Resolve or narrowly explain this tooling difference before claiming the required lint checks pass.
- The diagnostic has a five-minute lifetime and an explicit IPC stop command. The test was stopped through that scoped IPC command after user confirmation. It wrote no Niri configuration and sent no audio changes.

## Pending evidence

Structured cancellation trials, presentation/audio response latency, edge clicks, fractional scales, output removal and adjacent-output crossing have not been verified. T003 is incomplete; this document is partial evidence only. No final OSD visual design or animation is exercised by the labelled diagnostic panel.
