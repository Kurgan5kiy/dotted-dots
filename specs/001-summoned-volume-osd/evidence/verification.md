# Implementation Checkpoint

Branch: `feature/06-volume-osd-runtime`. Status: current-Niri visual and interaction preview accepted after refactoring; remaining verification, CI and full convergence are pending.

## Implemented and exercised

- Versioned preferences, tracked PipeWire default-sink state, request accumulation/confirmation logic, typed `volume_v1` IPC and show-only invocation.
- Per-output edge sensor, one bounded non-focus-taking overlay, explicit lifecycle, hover/drag timeout suspension, vertical node-snapping controls and separate mute indicator.
- User review drove the vertical layout, grid-aligned reached line, pointer-following fluid field, bundled Allura typography and broader backdrop/dot feathering. The user accepted the appearance and subsequently accepted the refactored preview as complete for this stage.
- The user reported working behavior during live single-display previews. Observed audio state updated through the real PipeWire integration; the automated interaction tests use simulated audio and do not mutate system sound.

## Automated verification

- `scripts/check-qml.sh`: 64 passing Qt Quick Test results on Qt 6.12.0 using the software backend. Covers configuration validation, lifecycle timers and hover/drag, edge cancellation/rearm, audio request bounds/accumulation/confirmation, output selection/logical scales, node-snapping controls, animated values, pointer-follow/re-entry, sampler equivalence, transparent boundaries and four rendered backgrounds. Eight additional parity-test results cover before/after image comparisons; see [quality and performance](quality-and-performance.md).
- QML formatting matches formatter output. Lint accepts only the documented Quickshell 0.3.2 metadata diagnostics: PanelWindow's runtime factory and VolumeOsd's opaque margins metadata. Other warnings, import errors and unexpected exit codes fail the check. These exceptions are not a claim of a warning-free upstream metadata set.
- CLI forwarding and commit-message tests pass. IPC calls are explicitly delimited with `--` to avoid Quickshell treating the function name `show` as its own subcommand.
- Package contents and SHA-256 tests pass. `tests/test-installed-runtime.sh` launched a temporary extracted package through its named config, checked CLI status/state/show, stopped it and removed its temporary files. Edge and automatic-audio triggers were disabled in that test; it sent no volume or mute changes.
- Private PipeWire integration passed confirmed writes, the service deadline,
  stale-sink cancellation, unavailable rejection and recovery. The instrumented
  real shell passed 20 external, 20 direct-action and 20 disabled-trigger trials
  against null sinks; see [actions.md](actions.md). Host audio was untouched.
- Native pixel-response verification also passed twenty trials per audio mode
  above a real opaque window in nested Niri: maxima 184.362 ms external and
  206.089 ms through the public CLI. Twenty edge dwells showed leftward
  emergence; twenty early exits cancelled. See [feedback.md](feedback.md) for
  raw samples, thresholds and backend limitations. Six Python helper checks
  cover capture validation and private-pointer safety.
- Synthetic bright/dark/colorful/busy captures are reproducible at `dist/visual/` and contain original generated fixtures only. Personal desktop captures remain private temporary files outside the repository.

## Not yet established

- The complete visual-state and normal/reduced-motion capture matrix under
  revised SC-004. The user directed the spec to preserve the accepted design;
  contrast limits remain documented diagnostics, not the superseded fixed
  ratio gate or an accessibility certification.
- Direct hardware-backend presentation latency and actual hardware refusing
  an audio write. The nested compositor's twenty-trial pixel measurements and
  private-graph recovery/switch checks now pass in their stated environments.
- Adjacent physical outputs, hotplug and fractional compositor scaling. Logical-size unit tests do not establish hardware compatibility.
- Physical adjacent-edge crossing and output removal. Structured edge dwell
  and cancellation trials now pass in the private nested compositor. Named
  visual CPU/frame observations are in [quality and performance](quality-and-performance.md);
  compositor pixel captures are not physical scanout/GPU timestamp measurements.
- Remaining hardware/delivery acceptance work. GitHub validation and QML CI
  passed for the accepted implementation update; subsequent evidence updates
  are verified against their own head commit before handoff. Current
  single-display preview acceptance is recorded above.

No claim of Converged is made. Open tasks and subsequent convergence findings remain required before review for merge or release.
