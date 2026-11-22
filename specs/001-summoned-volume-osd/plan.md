# Implementation Plan: Summoned Dot-Field Volume OSD

**Branch**: `feature/02-summoned-volume-osd` | **Date**: 2026-11-22 | **Spec**: [spec.md](spec.md)

**Status**: Design draft completed for review. Product implementation remains gated by the pending constitution amendment review and the edge-input validation described below.

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

- **I — Identity**: A feathered dark backdrop with a potentially opaque center complies with draft 2.0.0, but its amendment requires pull-request review; 1.0.0 remains the published baseline.
- **II — Access**: Pointer controls and externally bound volume/mute actions preserve focus. An optional show-only action can be bound by the user and defaults to unbound. Test hover, active, failure, reduced motion, scale and multiple outputs.
- **III — Architecture**: Separate service, platform adapter, visuals, lifecycle and versioned IPC/configuration. No native code or extra dependency is approved.
- **IV — Performance**: Use bounded visual regions and timers; collect reproducible latency, frame and idle observations.
- **V — Slices**: Spec and plan are drafts, followed by checklist, tasks, analysis and implementation review.
- **VI — Delivery**: Nonvisual tests, visual evidence, CI, convergence and honest disclosure are required.

**Gate status**: Design review may proceed. Product implementation requires amendment review and an early, separately reviewed feasibility task demonstrating dwell, crossing between outputs and bounded input handling. Failure returns to the spec instead of silently reducing behavior. The narrow strip's input ownership is a documented design tradeoff requiring review.

## Project Structure

### Documentation (this feature)

`specs/001-summoned-volume-osd/` contains the specification, this plan, research, data model, contracts, quickstart and checklists. Tasks are created in a later stage.

### Source Code (repository root)

Boundaries: `src/shell.qml` for runtime; `src/services/AudioService.qml` for tracked PipeWire state; `src/platform/EdgeSensor.qml` and `OutputRouter.qml` for input and placement; `src/config/` for validated preferences; `src/ipc/VolumeActions.qml` for the typed v1 contract; `src/visual/` for reusable dots, backdrop and path; `src/surfaces/volume/` for OSD and lifecycle. Keep deterministic state/configuration functions in testable JavaScript. Extend `bin/dot-shell` and `tests/` as needed. Existing packaging already copies all of `src/` into `share/quickshell/dot-shell/`; validate the installed CLI against that layout, not just a source checkout.

## Rendering and interaction

Render a bounded dark backdrop with a cached Canvas image, rebuilt only on geometry, scale or appearance changes. Use separable smooth falloff on all boundaries and an opaque center by default. Animate opacity and translation of the cached item, not Canvas repaint on every frame. Use bounded QML dot items and a path primitive independent of audio. Stop animation work when dormant and unload the visible surface; retain only sensors and service subscriptions.

Use explicit lifecycle states and one active OSD. A repeated change updates confirmed state, resets idle and never reconstructs moving hit targets during a drag. Edge invocation always selects the entered display; a visible OSD stays on its current display during interaction. The mute dot uses grey plus a hollow center when muted, white and filled otherwise, with a minimum 32-logical-pixel invisible target.

Defaults, ranges and failure behavior are in [configuration](contracts/configuration.md); typed action names, responses and opt-in Niri examples are in [actions](contracts/actions.md). These are proposed v1 contracts, not existing functionality.

## Verification and delivery

The local environment has Niri 26.04, Qt 6.12 QML tools in `/usr/lib/qt6/bin` and Quickshell 0.3.2 installed by the user following explicit installation authorization. Version detection alone does not establish live compatibility. The user authorized an isolated edge experiment; no persistent compositor configuration changes are required.

Run existing CI plus deterministic QML tests for state, configuration, dwell, output changes and pending audio writes. Run formatter/linter with the Quickshell import directory, then packaged-runtime smoke tests. Record the spec's latency, backdrop, normal/reduced-motion, hover, failure and multi-output scenarios. Collect at least 10 seconds of idle and transition frame observations on named hardware; dormant state must schedule no recurring animation or poll timer. Separate measured outcomes from assumptions.

After plan review, generate the requirements checklist, tasks and consistency analysis. Only then execute approved tasks, collect evidence and run convergence. No feature code is included in this stage.

## Complexity Tracking

No constitutional exception is approved. Resolve the gates in their governing artifacts, not silently in code.
