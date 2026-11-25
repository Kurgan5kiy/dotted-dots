# Implementation Plan: Summoned Dot-Field Volume OSD

**Branch**: `feature/02-summoned-volume-osd` | **Date**: 2026-11-22 | **Revised**: 2026-11-23 | **Spec**: [spec.md](spec.md)

**Status**: The accepted single-output runtime remains implemented. This plan
revision designs the newly clarified focused-output routing, per-output trigger
sides and exclusive middle-third volume zone. Those changes require refreshed
tasks, analysis, implementation and physical two-output evidence before they
are claimed complete.

## Summary

Build a bounded Quickshell overlay with a tracked default audio sink, reusable feathered field and path, stable volume controls and an edge-dwell trigger. Observe external volume changes and offer versioned actions for user-configured Niri bindings without taking keyboard focus.

Try automatic audio-change summoning first. Measure latency separately for external changes and direct shell actions. Provide `triggers.externalAudioChanges` so users can disable passive summoning if delayed and use bindings that invoke audio mutation and OSD presentation together. Keep audio-state observation in both modes to preserve confirmation and external-state accuracy; never replace it with guessed values.

For dormant non-pointer summons, select the output reported by a bounded
Niri event-stream adapter. On the validated focus-follows-mouse setup this is
the focused-window output, or the pointer output on an empty workspace. Keep a
visible OSD fixed through dismissal. Give every output a configurable left or
right trigger side, but create input only over the middle third; top and bottom
thirds remain unowned by this feature. Maintain one OSD globally.

## Technical Context

- **Language**: QML and JavaScript on Qt 6; POSIX shell for the existing CLI.
- **Dependencies**: Niri, Wayland, PipeWire and Quickshell 0.3.2 as the initial validation baseline, matching the repository package and its Qt 6.12 support. Other versions remain unverified. No C++ or additional runtime dependency is approved.
- **Storage**: Versioned user-local configuration schema v2 with in-memory v1 migration; no shell persistence of audio or focus state and no automatic rewrite of user files.
- **Testing**: QML Test for state, Niri-event reduction, routing, edge zones and configuration migration; CLI tests; `qmlformat`; `qmllint`; live Niri/PipeWire integration; and recorded visual tests. Automated logical-scale coverage is 1.0, 1.25, 1.5 and 2.0; live evidence must include two physical outputs and at least two scale factors.
- **Performance**: First visible response within 500 ms in 20 measured changes; record frame timing and idle resource behavior on named hardware. Avoid full-screen redraws and polling.
- **Scope**: One default audio output and one visible OSD across connected displays, including mixed scales. This slice reserves top and bottom edge thirds but delivers no surface in them. No adjacent shell surface or embedded-wallpaper mode is added.
- **Input design**: One transparent, non-exclusive, one-to-four-logical-pixel sensor per output on its resolved left or right side. The sensor window occupies only the middle third of the logical output edge; no Dot Shell window exists in the reserved thirds. `WlrLayershell.layer` is Overlay and keyboard focus None. A separate bounded OSD surface owns input over its visible field. No pointer constraint, full-screen capture or cursor polling is allowed. Shared-edge reachability and fractional scales require live verification.
- **Platform routing**: A Niri-specific adapter consumes `niri msg -j event-stream`, tolerates unknown events and exposes the current focused output without a recurring poll. Niri 26.04 has no pointer-output IPC. Pointer fallback on an empty workspace therefore requires focus-follows-mouse behavior and must pass the user's 20/20 live trials; failure returns to the specification.
- **Usable bounds**: Quickshell 0.3.2 exposes logical output geometry but not a dependable compositor work area. The initial baseline divides the logical vertical edge into thirds and discloses that third-party exclusive zones are not subtracted.

## Constitution Check

Initial and post-design review against draft 2.0.0:

- **I — Identity**: A feathered dark backdrop with a potentially opaque center complies with constitution 2.0.0, merged in PR #6.
- **II — Access**: Pointer controls and externally bound volume/mute actions preserve focus. Trigger zones are stationary, only the middle third owns input, and top/bottom pointer input passes through. Test focus changes, empty workspaces, hover, active, failure, reduced motion, scales and multiple outputs.
- **III — Architecture**: Keep Niri event parsing behind a platform adapter; keep side/zone/config reducers pure; retain separate service, visual, lifecycle, configuration and versioned IPC boundaries. Configuration moves to documented schema v2 with v1 migration. No native code or extra dependency is approved.
- **IV — Performance**: Use one bounded middle-third sensor per output and one long-lived event stream rather than process polling. Keep rendering bounded and collect reproducible latency, frame and idle observations.
- **V — Slices**: The refinement is bounded to volume OSD placement and discovery. It reserves but does not implement top/bottom surfaces. Planning must be followed by checklist, tasks, analysis, implementation and convergence.
- **VI — Delivery**: Nonvisual tests, visual evidence, CI, convergence and honest disclosure are required.

**Gate status**: PASS for design, not yet for implementation. The approach adds
no global capture, polling loop, native code or compositor mutation. Before
implementation, refreshed checklist/tasks and consistency analysis are
required. Physical shared-edge reachability, focus-follows-mouse routing,
mixed-scale zoning and top/bottom pass-through remain acceptance gates; failure
returns to the specification rather than silently reducing behavior.

**Post-design re-evaluation**: PASS. Research and design retain the original
wallpaper-first field, stable controls, reduced motion, bounded work, explicit
platform boundaries, versioned public configuration and reproducible evidence
gates. No constitutional exception is introduced.

## Project Structure

### Documentation (this feature)

`specs/001-summoned-volume-osd/` contains the specification, this plan, research, data model, contracts, quickstart, checklists, implementation tasks and verification evidence.

### Source Code (repository root)

Boundaries: `src/shell.qml` for runtime; `src/services/AudioService.qml` for tracked PipeWire state; `src/platform/NiriFocusAdapter.qml` and a pure event reducer for focused-output state; `src/platform/EdgeSensor.qml`, `EdgeZones.js`, `OutputRouter.qml` and `Routing.js` for bounded input and placement; `src/config/` for schema-v2 validation and migration; `src/ipc/VolumeActions.qml` for the unchanged typed volume-v1 action contract; `src/visual/` for reusable dots, backdrop and path; and `src/surfaces/volume/` for OSD and lifecycle. Keep Niri-specific process handling out of visuals and services. Existing packaging already copies all of `src/` into `share/quickshell/dot-shell/`; validate the installed CLI against that layout, not just a source checkout.

## Rendering and interaction

Render a bounded dark field with three cached soft Canvas layers, rebuilt only on geometry or appearance settings. Move the field and gradient inward from the resolved side, reversing on dismissal. Express side as an explicit direction/anchor value; do not mirror the whole surface, text or controls with a negative scale. A finite settling animation drifts and deforms the layers independently without per-frame Canvas repaint or a new shader/build dependency. Share the composite-alpha model with decorative dots. Controls stay fixed. Initialize the path before emergence completes. Stop work when dormant and unload the surface; retain only bounded sensors and service subscriptions.

Use explicit lifecycle states and one active OSD. A repeated change updates confirmed state, resets idle and never changes output from emergence through retraction. Edge invocation selects its sensor's output and side. A dormant non-pointer invocation resolves the adapter's current output; if unavailable, use `placement.fallbackOutput`, then stable first available output. The mute dot remains solid grey at 6 logical pixels when muted and solid white at 8 otherwise, with a fixed minimum 32-logical-pixel target.

## Multi-output routing and edge zones

Run one Niri event-stream process through `NiriFocusAdapter.qml`. A pure reducer
tracks workspace id-to-output mappings, the focused workspace/output, whether
a window is focused, readiness and diagnostics. Initial snapshot events must
establish state before it is authoritative; unknown event variants are ignored.
On stream loss, reconnect only after an error or on the next summon with a
bounded delay—never with an unbounded poll. A dormant summon may use fallback
placement while the adapter is unavailable, with a diagnostic.

Niri 26.04 has no cursor-position or pointer-output request. On a
focus-follows-mouse configuration, its focused output follows the pointer onto
empty workspaces, satisfying the pointer fallback without capture. Treat this
as a platform prerequisite for that behavior, verify it on the user's setup,
and return to the spec if any recorded trial selects the wrong output. Do not
read or rewrite the user's compositor configuration at runtime.

Create one `PanelWindow` sensor for each connected output. Resolve an explicit
side or named copy/mirror profile, anchor the sensor on that side, and set its
top and bottom margins to `floor(logicalHeight / 3)`. The middle receives the
zero-to-two-pixel integer remainder. The reserved thirds have no Dot Shell
window or input region in this feature. A sensor emits both output and side;
the router selects `left-center` or `right-center`, and visual motion uses the
matching inward sign. A second sensor cannot relocate or duplicate a visible
OSD. Output loss cancels a drag and performs the documented safe fallback.

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
inset at all local boundaries except the resolved physical edge. Preserve the
pointer-following center; contract an overflowing radius instead of clipping
nonzero alpha at the native rectangle. Keep the resolved left or right edge
attached. Use fitted shapes for cached transforms and dot/control alpha.
Regression captures must cover maximum follow range and liquid deformation at
every non-screen boundary on both sides.

The user approved a behavior-preserving quality/performance pass before retest.
Extract `visual/FieldLight.qml` for motion and shared illumination state,
`surfaces/volume/VolumeChain.qml` for the stationary chain/input, and
`visual/MuteDot.qml` for the minimal mute control. Precompute ellipse sampling
coefficients once per shape update, sharing them across dots and controls;
verify numerically against the previous formula and retain visual evidence.
Use a finite input-transparent probe with fake audio for before/after CPU and
scene-graph timing at default and dense geometry, plus settled and unloaded
observations. No system audio or compositor configuration changes are needed.

Defaults, migration, per-output profiles and failure behavior are in [configuration](contracts/configuration.md). Configuration schema v2 accepts v1 input through an in-memory migration and never rewrites the user's file. Typed action names and responses remain unchanged in [actions](contracts/actions.md); presentation routing does not version-bump `volume_v1`.

## Verification and delivery

The local environment has Niri 26.04, Qt 6.12 QML tools in `/usr/lib/qt6/bin` and Quickshell 0.3.2 installed by the user following explicit installation authorization. Version detection alone does not establish live compatibility. The user authorized an isolated edge experiment; no persistent compositor configuration changes are required.

Run existing CI plus deterministic QML tests for state, v1-to-v2 migration, profile resolution, Niri-event reduction, middle-third arithmetic, left/right motion, dwell, placement locks, output loss and pending audio writes. Test logical scales 1.0, 1.25, 1.5 and 2.0. Run formatter/linter with the Quickshell import directory, then packaged-runtime smoke tests. Record the spec's latency, backdrop, normal/reduced-motion, hover, failure and multi-output scenarios. Collect at least 10 seconds of idle and transition observations; dormant state must schedule no recurring animation or poll timer.

The prior single-output behavior is implemented, but this multi-output
refinement is design-only at this stage. Update the checklist and tasks, rerun
analysis, then implement and converge. Until the physical two-output matrix
passes, disclose focused-output, pointer-fallback, shared-edge and scale
behavior as unverified.

For T031's timing/cancellation verification, run the installed Niri binary as
a nested compositor with temporary configuration, runtime directory and D-Bus
session, never `--session`. Connect a minimal test-only virtual-pointer client
only to that private Wayland socket. Use private PipeWire null sinks and an
instrumented copy of the real shell; keep production motion timings intact.
Measure elapsed time from audio-command process creation to a changed capture
of the compositor's synthetic white test surface, including startup/IPC and
capture delay. Run 20 trials per audio mode and 20 edge dwell/cancellation
trials. Record raw samples, observable pixel threshold, motion evidence and
the limits of nested-backend/composited-pixel measurements. This adds no
production dependency and does not change host audio or pointer position.

For live multi-output acceptance, use the user's existing focus-follows-mouse
setup without editing it. Run the spec's focused-window and empty-workspace
20-trial matrices across both displays; exercise right/right and mirrored
profiles; verify exact third boundaries, top/bottom pass-through, focus changes
during every lifecycle phase, output removal and one visible OSD. If the two
physical outputs do not expose two different configured scales, obtain explicit
authorization for a temporary, non-persistent two-output test-session change to
1.0 and 1.25. If that is unavailable, leave SC-006 open; a single-output nested
run may supplement but cannot replace the required physical multi-output test.
The feature PR must link the governing artifacts, include the approved evidence
and repository-check results, and explicitly identify release-branch impact.

## Complexity Tracking

No constitutional exception is approved. The additional Niri adapter and
configuration schema are required by the clarified routing contract and stay
behind existing platform/configuration boundaries. Resolve failed live gates
in their governing artifacts, not silently in code.
