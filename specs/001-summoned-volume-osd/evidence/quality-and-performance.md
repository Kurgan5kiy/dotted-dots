# Refactoring and performance review

Status: the user accepted this part after the refactoring pass ("cool, this
part's done"). The current-Niri visual and interaction preview is accepted for
this stage. This is not final feature convergence or release acceptance.

## Findings and changes

- `VolumeField.qml` combined all pointer state, animations, geometry, rendering
  and audio-control input. It now composes `FieldLight.qml`, `VolumeChain.qml`
  and `MuteDot.qml`. Motion has no system-service dependency; controls emit
  adjustment/drag/toggle signals, and the surface connects them to audio.
- Every decorative dot repeated ellipse geometry and feather calculations on
  each update. `FluidShape.prepare` now computes shared coefficients once per
  geometry update. Sampling skips square roots outside the feather region and
  skips zero-opacity layers. Hidden decorative nodes do not sample the field.
  Unused legacy dot-falloff branches were removed.
- Unconditional lifecycle/request diagnostics formatted messages and geometry
  on every audio event. Those development logs were removed; configuration and
  failure diagnostics remain.
- Reduced motion now stops an already running liquid animation immediately.
- The Arch QML CI job lacked `diff`, preventing its checks from running.
  `diffutils` is now an explicit dependency. The new profiling/parity helpers
  are included in syntax, formatting and lint checks where applicable.

Cached backdrop images, fixed input regions, node population cap, finite
animations and Loader-based unloading are preserved. No shader build step,
native helper, compositor change or runtime package was added.

## Reproducible measurements

Method and commands: [performance probe guide](../../../tests/performance/README.md).
The baseline is a complete copy of the user-approved working source immediately
before this refactor, not the older branch commit. Probes run sequentially in
the live Niri session with fake audio and a click-through temporary overlay.

Environment: Intel Core Ultra 5 125U, Mesa Intel Graphics (MTL), OpenGL 4.6,
Mesa 26.3.1, Niri 26.04 (`8ed0da4`), Quickshell 0.3.2, Qt 6.12.0. Qt reported
a threaded render loop with a 16.66 ms vsync interval. Single trials with
diagnostic logging are observations, not a controlled statistical study.

| Ten-second continuous motion | Before | After |
| --- | ---: | ---: |
| Default grid: CPU, percent of one core | 27.20% | 24.90% |
| Default grid: GUI preparation p95 | 2 ms | 1 ms |
| Default grid: sync + render p95 | 1 ms | 1 ms |
| Default grid: prepared frames | 600 | 600 |
| Dense grid: CPU, percent of one core | 73.81% | 64.81% |
| Dense grid: GUI preparation p95 | 6 ms | 4 ms |
| Dense grid: sync + render p95 | 8 ms | 7 ms |
| Dense grid: prepared frames | 600 | 600 |

Default geometry has 300 decorative-grid delegates; dense geometry has 1,850.
After refactoring, the motion-period maximum GUI preparation was 2 ms at the
default size and 5 ms in the dense case. After the finite motion settled, both
sizes scheduled zero measured frames in the ten-second settled period and used
0–0.1% of one CPU core. The unloaded period likewise prepared zero frames;
CPU was about 0.1% default and 0.4% dense, including teardown.

Resident memory at motion end was about 192/194 MiB before/after at default
geometry and 227/231 MiB dense. Refactored unloaded measurements were about
182 MiB default and 192 MiB dense. This includes Quickshell, Qt and driver
caches; the pass did not establish a memory saving or perform a long-duration
leak test.

The diagnostic data shows headroom in the tested visual workloads, with no
observed recurring animation or rendering once settled/unloaded. CPU costs
scale with configured dot population. Qt's integer-millisecond GUI/render
timings are not GPU execution timestamps; prepared frame counts do not prove
that every frame was presented. Real audio/IPC latency, thermal behavior,
mixed-scale outputs, other GPUs and long sessions remain unverified here.

One dense diagnostic run overlapped an automated test; it was discarded from
the table and repeated without competing test processes. Raw probe JSON/logs
remain temporary local evidence, without desktop image captures.

## Regression checks

- `scripts/check-qml.sh`: formatting, import-aware lint and 64 passing Qt Test
  results. Numeric equivalence tests compare the optimized sampler with the
  previous formula across moving composite fields and opacity settings to
  1e-9 tolerance. Existing animation, endpoint, hover/re-entry, reduced-motion
  and transparent-boundary regressions pass.
- `bash tests/test-visual-parity.sh BASELINE_SRC`: eight passing Qt Test results,
  including six complete image comparisons: bright, dark, colorful, busy,
  pointer-following and translucent backdrop. Each pixel differs by at most one
  RGB channel value; no personal wallpaper is used.
- CLI, commit-message and package/checksum tests passed. Installed-runtime
  smoke test passed against a temporary extracted package with show/state
  calls only; no volume or mute command was sent.
- Shell/Python syntax checks and `git diff --check` passed. The development
  preview reloaded successfully and accepted show-only IPC.

Remote QML CI awaits a subsequent branch update. User acceptance of the
refactored preview is recorded; it does not establish unmeasured hardware
behavior. Existing hardware/delivery tasks remain open, and the full feature
has not yet been reported as Converged.
