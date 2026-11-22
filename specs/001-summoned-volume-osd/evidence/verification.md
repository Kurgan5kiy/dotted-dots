# Implementation Checkpoint

Branch: `feature/06-volume-osd-runtime`. Status: working development preview; visual acceptance and full convergence are pending.

## Implemented and exercised

- Versioned preferences, tracked PipeWire default-sink state, request accumulation/confirmation logic, typed `volume_v1` IPC and show-only invocation.
- Per-output edge sensor, one bounded non-focus-taking overlay, explicit lifecycle, hover/drag timeout suspension, vertical node-snapping controls and separate mute indicator.
- User review drove the vertical layout, grid-aligned reached line, slow right-to-left bloom, light Fira Code typography and broader backdrop/dot feathering. Final appearance is still being reviewed.
- The user reported working behavior during live single-display previews. Observed audio state updated through the real PipeWire integration; the automated interaction tests use simulated audio and do not mutate system sound.

## Automated verification

- `scripts/check-qml.sh`: 37 passing Qt Quick Test results on Qt 6.12.0 using the software backend. Covers configuration validation, lifecycle timers and hover/drag, edge cancellation/rearm, audio request bounds/accumulation/confirmation, output selection/logical scales, node-snapping pointer controls, mute and four rendered backgrounds.
- QML formatting matches formatter output. Lint accepts only the documented Quickshell 0.3.2 metadata diagnostics: PanelWindow's runtime factory and VolumeOsd's opaque margins metadata. Other warnings, import errors and unexpected exit codes fail the check. These exceptions are not a claim of a warning-free upstream metadata set.
- CLI forwarding and commit-message tests pass. IPC calls are explicitly delimited with `--` to avoid Quickshell treating the function name `show` as its own subcommand.
- Package contents and SHA-256 tests pass. `tests/test-installed-runtime.sh` launched a temporary extracted package through its named config, checked CLI status/state/show, stopped it and removed its temporary files. Edge and automatic-audio triggers were disabled in that test; it sent no volume or mute changes.
- Synthetic bright/dark/colorful/busy captures are reproducible at `dist/visual/` and contain original generated fixtures only. Personal desktop captures remain private temporary files outside the repository.

## Not yet established

- Objective text and essential-control contrast on all backgrounds/states, particularly after widening the gradient; visual review is not a substitute for those measurements.
- Full normal/reduced-motion capture matrix, end-to-end latency for 20 external and 20 binding-driven changes, actual audio-write failure/recovery and sink-switch integration tests.
- Adjacent physical outputs, hotplug and fractional compositor scaling. Logical-size unit tests do not establish hardware compatibility.
- Named-hardware frame/idle resource observations and complete structured edge/cancellation trials.
- Remote QML CI and final user visual acceptance at this checkpoint.

No claim of Converged is made. Open tasks and subsequent convergence findings remain required before review for merge or release.
