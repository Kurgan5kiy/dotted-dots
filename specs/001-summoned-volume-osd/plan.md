# Implementation Plan: Summoned Dot-Field Volume OSD

**Branch**: `feature/02-summoned-volume-osd` | **Date**: 2026-11-22 | **Spec**: [spec.md](spec.md)

**Status**: Artifacts and constitution merged in PR #6; implementation and the refactored current-Niri preview are accepted. Convergence has returned outstanding contrast, structured integration and display-verification work to tasks.md.

## Summary

Build a bounded Quickshell overlay with a tracked default audio sink, reusable feathered field and path, stable volume controls and an edge-dwell trigger. Observe external volume changes and offer versioned actions for user-configured Niri bindings without taking keyboard focus.

Try automatic audio-change summoning first. Measure latency separately for external changes and direct shell actions. Provide `triggers.externalAudioChanges` so users can disable passive summoning if delayed and use bindings that invoke audio mutation and OSD presentation together. Keep audio-state observation in both modes to preserve confirmation and external-state accuracy; never replace it with guessed values.

## Technical Context

- **Language**: QML and JavaScript on Qt 6; POSIX shell for the existing CLI.
- **Dependencies**: Niri, Wayland, PipeWire and Quickshell 0.3.2 as the initial validation baseline, matching the repository package and its Qt 6.12 support. Other versions remain unverified. No C++ or additional runtime dependency is approved.
- **Storage**: Versioned user-local configuration; no shell persistence of audio state.
- **Testing**: QML Test for state and configuration, CLI tests, `qmlformat`, `qmllint`, live Niri/PipeWire integration and recorded visual tests.
- **Performance**: First visible response within 500 ms in 20 measured changes; record frame timing and idle resource behavior on named hardware. Avoid full-screen redraws and polling.
- **Scope**: One default audio output and one visible OSD across connected displays, including mixed scales. No adjacent shell surfaces or embedded-wallpaper mode.
- **Input design**: One transparent, non-exclusive, one-logical-pixel right-edge sensor per output; `WlrLayershell.layer` set to Overlay and keyboard focus None. The sensor necessarily owns input in its narrow strip. A separate bounded OSD surface owns input over its visible field, allowing hover to suspend timeout; outside that field and the sensor, input passes through. No pointer constraint or full-screen capture. Adjacent-output crossing and fractional-scale reachability require live verification.

## Constitution Check

Initial and post-design review against draft 2.0.0:

- **I — Identity**: A feathered dark backdrop with a potentially opaque center complies with constitution 2.0.0, merged in PR #6.
- **II — Access**: Pointer controls and externally bound volume/mute actions preserve focus. An optional show-only action can be bound by the user and defaults to unbound. Test hover, active, failure, reduced motion, scale and multiple outputs.
- **III — Architecture**: Separate service, platform adapter, visuals, lifecycle and versioned IPC/configuration. No native code or extra dependency is approved.
- **IV — Performance**: Use bounded visual regions and timers; collect reproducible latency, frame and idle observations.
- **V — Slices**: Specification, planning, checklist, tasks, analysis and implementation stages were completed for the bounded volume OSD. Convergence tracks remaining verification and product decisions explicitly.
- **VI — Delivery**: Nonvisual tests, visual evidence, CI, convergence and honest disclosure are required.

**Gate status**: The amendment and artifacts were merged in PR #6, and the user confirmed the initial single-display sensor diagnostic. Implementation may proceed under the user's explicit go-ahead. Crossing between outputs and scale validation remain acceptance obligations; they are not claimed complete by the local diagnostic. Failure returns to the spec instead of silently reducing behavior. The narrow strip's input ownership is a documented tradeoff.

## Project Structure

### Documentation (this feature)

`specs/001-summoned-volume-osd/` contains the specification, this plan, research, data model, contracts, quickstart, checklists, implementation tasks and verification evidence.

### Source Code (repository root)

Boundaries: `src/shell.qml` for runtime; `src/services/AudioService.qml` for tracked PipeWire state; `src/platform/EdgeSensor.qml` and `OutputRouter.qml` for input and placement; `src/config/` for validated preferences; `src/ipc/VolumeActions.qml` for the typed v1 contract; `src/visual/` for reusable dots, backdrop and path; `src/surfaces/volume/` for OSD and lifecycle. Keep deterministic state/configuration functions in testable JavaScript. Extend `bin/dot-shell` and `tests/` as needed. Existing packaging already copies all of `src/` into `share/quickshell/dot-shell/`; validate the installed CLI against that layout, not just a source checkout.

## Rendering and interaction

Render a bounded dark field with three cached soft Canvas layers, rebuilt only on geometry or appearance settings. Move the field and gradient together from outside the right edge, reversing on dismissal. A finite settling animation drifts and deforms the layers independently to produce a gently fluid boundary, without per-frame Canvas repaint or a new shader/build dependency. Share the composite-alpha model with the decorative dots so they never outlive their dark background. Controls stay fixed. Initialize the path to the current level before emergence completes; later grey-node opacity follows the animated endpoint in both directions. Stop work when dormant and unload the surface; retain only sensors and service subscriptions.

Use explicit lifecycle states and one active OSD. A repeated change updates confirmed state, resets idle and never reconstructs moving hit targets during a drag. Edge invocation always selects the entered display; a visible OSD stays on its current display during interaction. The mute dot is solid grey at 6 logical pixels when muted and solid white at 8 otherwise, with a fixed minimum 32-logical-pixel invisible target. Animate the colour and size over 120 ms; reduced motion updates directly.

Numeral changes use a reusable slide/crossfade component that retargets to the latest confirmed value. Reduced motion updates directly. Bundle the unmodified Allura font and OFL-1.1 license/provenance under `src/assets/fonts/allura/` for calligraphic numerals; it is an asset, not a system package or native runtime dependency. Typography and motion remain configurable.

For the authorized Niri 26.04 preview, use surface-local HoverHandler position
events and a pure JavaScript bounded-follow/departure model. Smooth small
backdrop offsets, retain the last outward direction on leave, and shrink/fade
the same cached shapes during retreat. The fixed window and controls never
follow the patch. Share transformed shape alpha with decorative dots, grey
nodes, the trace gradient, endpoint, label and mute indicator. No screen capture,
native helper, global cursor polling or new package is involved. Pointer leave
starts retreat immediately; keyboard-only appearances retain the idle timeout.
Reduced motion disables tracking travel and shrink. The user accepted the
current-Niri approximation after refactoring; it does not provide exact
outside-surface tracking.

Constrain each moving ellipse's radii to leave a two-logical-pixel transparent
inset at the local surface's left, top and bottom boundaries. Preserve the
pointer-following center; contract an overflowing radius instead of clipping
nonzero alpha at the native rectangle. Keep the physical right edge attached.
Use the fitted shapes for both cached backdrop transforms and dot/control alpha.
Regression captures must cover maximum follow range and liquid deformation at
all three non-screen boundaries.

The user approved a behavior-preserving quality/performance pass before retest.
Extract `visual/FieldLight.qml` for motion and shared illumination state,
`surfaces/volume/VolumeChain.qml` for the stationary chain/input, and
`visual/MuteDot.qml` for the minimal mute control. Precompute ellipse sampling
coefficients once per shape update, sharing them across dots and controls;
verify numerically against the previous formula and retain visual evidence.
Use a finite input-transparent probe with fake audio for before/after CPU and
scene-graph timing at default and dense geometry, plus settled and unloaded
observations. No system audio or compositor configuration changes are needed.

Defaults, ranges and failure behavior are in [configuration](contracts/configuration.md); typed action names, responses and opt-in Niri examples are in [actions](contracts/actions.md). These v1 contracts are implemented and remain subject to the recorded acceptance checks.

## Verification and delivery

The local environment has Niri 26.04, Qt 6.12 QML tools in `/usr/lib/qt6/bin` and Quickshell 0.3.2 installed by the user following explicit installation authorization. Version detection alone does not establish live compatibility. The user authorized an isolated edge experiment; no persistent compositor configuration changes are required.

Run existing CI plus deterministic QML tests for state, configuration, dwell, output changes and pending audio writes. Run formatter/linter with the Quickshell import directory, then packaged-runtime smoke tests. Record the spec's latency, backdrop, normal/reduced-motion, hover, failure and multi-output scenarios. Collect at least 10 seconds of idle and transition frame observations on named hardware; dormant state must schedule no recurring animation or poll timer. Separate measured outcomes from assumptions.

The reviewed feature is implemented. Continue verification and convergence
against tasks.md; unresolved criteria remain explicit and block claiming full
convergence or delivery readiness.

## Complexity Tracking

No constitutional exception is approved. Resolve the gates in their governing artifacts, not silently in code.
