# Tasks: Summoned Dot-Field Volume OSD

**Input**: spec.md, plan.md, research.md, data-model.md and contracts/ in this directory.
**Status**: The accepted single-output runtime remains implemented. Checked tasks preserve recorded history; open T003/T022/T025/T026/T032 and new T035+ tasks govern the focused-output, per-display edge and configuration-v2 refinement.
**Tests**: Required by the constitution and plan for nonvisual logic, CLI contracts and visual evidence.

## Phase 1: Setup and review

- [x] T001 Resolve artifact review and the constitution amendment through a pull request, updating `.specify/memory/constitution.md` and removing its temporary sync report before commit; record approval and any required spec corrections in `specs/001-summoned-volume-osd/spec.md`.
- [x] T002 Record Quickshell 0.3.2, Qt and Niri prerequisites and tool paths in `docs/development.md`; establish a test environment without modifying system packages, global Quickshell or user compositor configuration without authorization.
- [ ] T003 Extend the isolated probe in `tests/integration/edge-sensor.qml` and `specs/001-summoned-volume-osd/evidence/edge-input.md` to gate Niri event-stream focus changes, empty-workspace focus-follows-mouse routing, left/right middle-third sensors, exact third boundaries, top/bottom pass-through, shared-edge dwell/cancellation and fractional scales; stop and revise the governing artifacts if any required behavior fails.

## Phase 2: Shared foundation

- [x] T004 Implement validated preferences in `src/config/Preferences.qml` and `src/config/Validation.js` following data-model.md `Preferences.values` and its canonical configuration contract; include schema version, geometry relationships, output fallback and trigger flags.
- [x] T005 Add configuration and deterministic lifecycle test harnesses in `tests/qml/tst_preferences.qml` and `tests/qml/tst_lifecycle.qml`, with invalid values, reduced motion and timer transitions covered before dependent feature integration.
- [x] T006 Establish `src/shell.qml` and `src/platform/OutputRouter.qml`, implementing data-model.md `OutputSelection.screenId` and packaged directory layout; create only the minimal runtime for the OSD.

## Phase 3: User Story 1 — See volume changes (P1)

**Goal**: Demonstrate accurate dot-field feedback over windows, including edge invocation and automatic dismissal.
**Independent test**: Trigger external audio changes and dwell/cancel trials; observe confirmed values, stable placement and lifecycle without duplicates.

- [x] T007 [US1] Add audio-state and trigger tests in `tests/qml/tst_audio.qml` for unavailable state, sink switch, external updates and trigger disablement.
- [x] T008 [US1] Implement `src/services/AudioService.qml` with tracked default sink and subscriptions following data-model.md `AudioOutput.sinkId`, `AudioOutput.available`, `AudioOutput.percent` and `AudioOutput.muted`; preserve above-cap observations and separate observation from summon policy (FR-001, FR-013).
- [x] T009 [US1] Implement reusable `src/visual/DotField.qml` and `src/visual/FeatheredBackdrop.qml` with bounded population and cached feathering (FR-003, FR-014).
- [x] T010 [US1] Implement reusable `src/visual/PathTrace.qml` and lifecycle in `src/surfaces/volume/Lifecycle.js` following data-model.md `Osd.phase` and `Interaction.hovered`, including interrupted retraction (FR-004, FR-007–008).
- [x] T011 [US1] Implement `src/platform/EdgeSensor.qml` from accepted T003 findings following data-model.md `Interaction.edgeState` with per-output dwell, cancellation, disablement and rearm; add `tests/qml/tst_edge.qml` (FR-017).
- [x] T012 [US1] Compose `src/surfaces/volume/VolumeOsd.qml` above windows with no keyboard focus, bounded input, current value, mute indication, hover pause and one visible instance (FR-002, FR-006, FR-016).
- [x] T013 [US1] Record the 20-change, 20-edge and 20-cancellation acceptance results in `specs/001-summoned-volume-osd/evidence/feedback.md` with latency method and environment (SC-001–002, SC-007).

## Phase 4: User Story 2 — Adjust volume (P1)

**Goal**: Pointer controls and bindable shell actions adjust audio without focus theft, supporting direct summoning when external summoning is disabled.
**Independent test**: Use slider, mute dot and IPC actions; compare confirmed audio state, pending failure and timeout behavior in both trigger modes.

- [x] T014 [US2] Add pending-write, rapid-command accumulation, mute and stale-sink tests in `tests/qml/tst_actions.qml` and forwarding tests in `tests/test-cli.sh` per `contracts/actions.md`.
- [x] T015 [US2] Extend `src/services/AudioService.qml` with validated writes, confirmation deadline and sink-switch cancellation following data-model.md `AudioOutput.pending`, `AudioOutput.percent` and `AudioOutput.sinkId`; implement above-cap handling per `contracts/actions.md` (FR-005, FR-013, FR-019).
- [x] T016 [US2] Add stationary slider and minimal mute-dot hit targets to `src/surfaces/volume/VolumeOsd.qml`, with timeout and placement protection following data-model.md `Interaction.dragging` and `Interaction.hovered`, and no implicit unmute (FR-002, FR-005, FR-007–008).
- [x] T017 [US2] Implement typed `src/ipc/VolumeActions.qml` target `volume_v1` and the documented JSON result contract, direct action summoning and optional show-only action; keep existing CLI forwarding compatible (FR-018–019).
- [x] T018 [US2] Document opt-in Niri volume and optional show bindings in `docs/configuration.md`; verify both trigger modes and record results in `specs/001-summoned-volume-osd/evidence/actions.md` without editing user Niri files (SC-001, SC-003).

## Phase 5: User Story 3 — Adapt the experience (P2)

**Goal**: Usable configurable field across wallpapers, motion preferences, displays and scale factors.
**Independent test**: Exercise documented preferences and representative outputs/backgrounds in normal and reduced motion.

- [x] T019 [US3] Add output-loss, fit and scale routing tests in `tests/qml/tst_outputs.qml` using data-model.md `OutputSelection.screenId` (FR-012).
- [x] T020 [US3] Complete output routing and geometry fitting in `src/platform/OutputRouter.qml` and reduced-motion branches in `src/surfaces/volume/VolumeOsd.qml` following data-model.md `Preferences.values`, `OutputSelection.screenId` and `Osd.phase` (FR-009, FR-011–012).
- [x] T021 [US3] Supply reproducible licensed/generated bright, dark, colorful and busy fixtures in `tests/visual/` with provenance and a capture guide in `tests/visual/README.md`; exclude private reference artwork (FR-010).
- [ ] T022 [US3] Record normal/reduced motion, left/right inward emergence, opaque center and feathered edges, open-window stacking, mute distinction, fixed placement through focus changes, output removal and mixed-scale evidence in `specs/001-summoned-volume-osd/evidence/visual.md`; compare normal, hover, active and unavailable states with the approved design and document contrast limits under SC-004–006.

## Phase 6: Integration and delivery

- [x] T023 Integrate QML formatting, import-aware lint and offscreen tests into `.github/workflows/ci.yml` and `scripts/check-qml.sh`, retaining existing checks and failing on unavailable required imports.
- [x] T024 Verify release archive, checksums, installed runtime lookup and CLI status in `tests/test-package.sh`; reconcile `bin/dot-shell`, `install.sh` and `scripts/package-release.sh` if necessary (FR-015).
- [ ] T025 Run `specs/001-summoned-volume-osd/quickstart.md` after the refinement, recording repository checks, idle/transition observations, configuration-v1 migration, right/right and mirrored profiles, exact tested/untested environments and privacy-safe evidence in `specs/001-summoned-volume-osd/evidence/verification.md`; retain SC-002's separate 20-trial automatic/direct timing origin.
- [ ] T026 Run Spec Kit convergence against `specs/001-summoned-volume-osd/tasks.md`, append unresolved work rather than silently relaxing requirements, and repeat implementation/verification until Converged before feature merge.

## Phase 7: Review refactoring and performance

- [x] T027 Implement and test the authorized Niri 26.04 local pointer-following preview in `src/visual/FieldLight.qml`, `src/visual/PointerLight.js` and `tests/qml/tst_pointer_light.qml` following data-model.md `Interaction.pointerLight`: bounded follow, short departure drift, shrinking shared field alpha, stationary controls, immediate pointer retreat and re-entry recovery; record synthetic evidence in `specs/001-summoned-volume-osd/evidence/pointer-preview.md`.
- [x] T028 Preserve the approved preview while separating field motion/illumination, volume-chain input and mute visuals in `src/visual/FieldLight.qml`, `src/surfaces/volume/VolumeChain.qml`, `src/visual/MuteDot.qml` and `tests/qml/tst_volume_field.qml`; precompute shared gradient coefficients and retain interaction/visual regressions (FR-003–005, FR-014, Constitution III–IV).
- [x] T029 Add a bounded simulated-audio profiling probe in `scripts/profile-osd.py` and `tests/performance/`, record before/after normal, dense-grid, settled and unloaded evidence in `specs/001-summoned-volume-osd/evidence/quality-and-performance.md`, and repair the QML dependency check in `scripts/check-qml.sh` (Constitution IV–VI).

## Phase 8: Convergence

- [x] T030 Resolve the visual design/spec contradiction in `specs/001-summoned-volume-osd/spec.md`, `plan.md` and `evidence/visual.md` through the user's accepted direction; update FR-004, FR-010 and SC-004, retain measured contrast limits and leave full visual-state coverage to T022.
- [x] T031 Record reproducible 20-trial external/direct audio response, disabled-trigger, edge-dwell and cancellation results in `specs/001-summoned-volume-osd/evidence/feedback.md` and `native-timing.json`, measuring from initiating command startup through first visible response and retaining unverified acceptance work under T025.
- [ ] T032 Complete the physical two-output matrix in `specs/001-summoned-volume-osd/evidence/edge-input.md` and `evidence/visual.md`: focused-window and empty-workspace pointer routing, right/right and mirrored profiles, middle/top/bottom thirds, shared edges, output loss and two distinct scale factors; distinguish synthetic evidence and leave SC-006 open without authorized eligible hardware (FR-012, FR-017, FR-020, SC-006–007).
- [x] T033 Exercise pending confirmation timeout, stale-sink cancellation, unavailable state and recovery in `tests/integration/test-private-audio.py` and `src/services/AudioService.qml`, recording the unit/live boundary in `specs/001-summoned-volume-osd/evidence/actions.md` (FR-013, FR-019).
- [x] T034 Reconcile implementation and acceptance status in `specs/001-summoned-volume-osd/evidence/verification.md` and `evidence/convergence.md`, publish only original synthetic evidence, update the feature PR, verify remote checks and explicitly identify release-branch impact (Constitution VI, T023).

## Phase 9: Refinement review and feasibility gate

**Purpose**: Convert the reviewed multi-output requirements into an executable refinement without silently resolving product decisions in code.

- [ ] T035 Review every unchecked requirement-quality item in `specs/001-summoned-volume-osd/checklists/multi-output.md`, correct gaps in `specs/001-summoned-volume-osd/spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/` or `quickstart.md`, and record reviewer disposition in that checklist without treating implementation evidence as requirement quality.

## Phase 10: Multi-output foundation

**Purpose**: Establish tested configuration migration, Niri event state and output/edge selection before changing user-visible stories.

- [x] T036 [P] Add failing configuration migration and trigger-profile tests to `tests/qml/tst_preferences.qml`, covering schema v1 in-memory migration, schema v2 validation, global defaults, per-output overrides, copy, mirror, invalid references and deterministic fallback.
- [x] T037 [P] Add failing pure-reducer tests for Niri focus events, reconnect snapshots, empty-workspace pointer focus and malformed/unsupported events in `tests/qml/tst_niri_focus.qml`.
- [x] T038 [P] Add failing edge-zone and profile-resolution tests to `tests/qml/tst_edge.qml` and `tests/qml/tst_outputs.qml`, covering exact third boundaries, left/right sides, top/bottom pass-through, shared edges, removed outputs and deterministic fallback.
- [x] T039 [P] Implement configuration schema v2 and v1 in-memory migration in `src/config/Validation.js` and `src/config/Preferences.qml` following data-model.md `Preferences.values`, `EdgeTriggerProfile.outputId`, `EdgeTriggerProfile.side`, `EdgeTriggerProfile.copyOf` and `EdgeTriggerProfile.mirror`; reject cycles and preserve the global-right default.
- [x] T040 [P] Implement the bounded Niri event-stream adapter and pure reducer in `src/platform/NiriFocusAdapter.qml` and `src/platform/NiriEvents.js` following data-model.md `NiriFocusState.outputId`, `NiriFocusState.ready`, `NiriFocusState.windowFocused` and `NiriFocusState.diagnostic`; initialize from a snapshot, reconnect without polling and expose a deterministic unavailable state.
- [x] T041 [P] Implement exact left/right middle-third geometry and profile resolution in `src/platform/EdgeZones.js` following data-model.md `EdgeZone.bounds`, including scaled coordinates, inclusive/exclusive boundary rules, copy/mirror resolution, shared-edge identity and output-removal fallback.
- [x] T042 Integrate `src/platform/OutputRouter.qml`, `src/platform/Routing.js` and `src/shell.qml` following data-model.md `OutputSelection.screenId`, `OutputSelection.side` and `OutputSelection.locked`: select the focused-window output, use pointer-focused output for an empty workspace, lock a visible OSD to its selected output/side and release the lock only when dormant.

## Phase 11: User Story 1 refinement — See volume changes (P1)

**Goal**: Show exactly one volume OSD on the focused output and make it discoverable from the configured left or right middle edge of every output.
**Independent test**: Move focus between two outputs and an empty workspace, invoke by audio change and edge dwell, then change focus while visible; one OSD appears on the selected output/side and remains there until dismissal.

- [x] T043 [US1] Add routing integration tests to `tests/qml/tst_routing.qml` for focused-window selection, empty-workspace pointer selection, initial Niri unavailability, one-instance enforcement, visible placement lock, focus changes, output loss and dormant reselection.
- [x] T044 [P] [US1] Update `src/platform/EdgeSensor.qml` and `src/shell.qml` to instantiate bounded per-output sensors only for the resolved side and middle third, following data-model.md `Interaction.edgeState`; preserve dwell cancellation, rearm, top/bottom pass-through and shared-edge behavior.
- [x] T045 [P] [US1] Make inward emergence and placement side-aware in `src/surfaces/volume/VolumeOsd.qml`, `src/surfaces/volume/VolumeField.qml`, `src/visual/FieldLight.qml` and `src/visual/FluidShape.js`; keep text, controls and pointer interaction unmirrored while producing equivalent left/right geometry.

## Phase 12: User Story 2 refinement — Adjust volume (P1)

**Goal**: Route bindable volume and show actions through the same focused-output selection without moving a visible interaction.
**Independent test**: Invoke increase, decrease, mute and show while each output is focused, then switch focus while interacting; confirmed audio changes occur and the visible OSD stays fixed until dormant.

- [x] T046 [US2] Add action-routing tests to `tests/qml/tst_actions.qml` for increase, decrease, mute and show actions while dormant, focused-output reselection, visible placement lock, output loss and unchanged `volume_v1` results.
- [x] T047 [US2] Route direct and show-only action summoning through dormant output selection in `src/shell.qml`, `src/platform/OutputRouter.qml` and `src/ipc/VolumeActions.qml`; preserve the versioned `volume_v1` IPC contract, pending confirmation and current audio semantics.

## Phase 13: User Story 3 refinement — Adapt the experience (P2)

**Goal**: Support stable v2 per-output side profiles, explicit duplication/mirroring and mixed-scale behavior without changing the user's Niri configuration.
**Independent test**: Load v1 and v2 configurations, exercise global right/right, explicit left/right, copy and mirror profiles at scales 1, 1.25, 1.5 and 2 with normal/reduced motion; behavior remains usable and deterministic.

- [x] T048 [P] [US3] Extend `tests/qml/tst_outputs.qml` and `tests/qml/tst_volume_field.qml` with profile inheritance, copy/mirror, invalid-reference, output-loss, left/right, scale 1/1.25/1.5/2 and reduced-motion cases.
- [x] T049 [P] [US3] Document schema v2, automatic v1 in-memory migration, right/right defaults, per-output left/right overrides, explicit copy/mirror profiles and the Niri focus-follows-mouse prerequisite in `docs/configuration.md`; state that Dot Shell does not edit the user's Niri configuration.
- [x] T050 [US3] Expand the reproducible capture matrix in `tests/visual/README.md` for both sides, exact middle/top/bottom thirds, focus changes during visibility, output loss, shared edges, mixed scales and reduced motion, with bright, dark, colorful and busy wallpapers.

## Phase 14: Cross-cutting verification and delivery

- [ ] T051 Profile Niri event processing and per-output sensors with `scripts/profile-osd.py` and `tests/performance/README.md`, record bounded CPU/memory and reconnection results in `specs/001-summoned-volume-osd/evidence/quality-and-performance.md`, and remove any polling, unbounded retry or unnecessary full-screen redraw found.
- [x] T052 Reconcile new QML/JavaScript files and schema-v2 fixtures with `scripts/check-qml.sh`, `.github/workflows/ci.yml`, `tests/test-package.sh` and `tests/test-installed-runtime.sh`, preserving import-aware lint, offscreen tests and installed-runtime coverage.
- [ ] T053 After T022, T025, T032 and T051–T052 pass and T026 reports Converged, update `specs/001-summoned-volume-osd/evidence/verification.md` and `specs/001-summoned-volume-osd/evidence/convergence.md`, and prepare the feature pull request with checks, privacy-safe visual evidence, tested/untested hardware statements and explicit release-branch impact.

## Dependencies and execution order

- Historical T001–T034 remain the accepted baseline; unchecked T003 is the feasibility gate and T022, T025, T026 and T032 remain required acceptance work.
- T035 reviews the refinement artifacts before implementation. T003 must confirm the platform assumptions before T039–T045 integrate them; a failed assumption returns work to the governing artifact.
- T036–T038 add failing tests in parallel. T039–T041 implement their separate configuration, event and geometry foundations in parallel. T042 integrates those foundations.
- User Story 1 refinement follows T042: T043 defines routing acceptance, then T044–T045 may proceed in parallel. User Story 2 refinement T046–T047 follows because it shares shell/action routing. User Story 3 refinement T048–T050 may begin after T042 but its final evidence depends on the completed visible behavior.
- T022, T025 and T032 validate the completed stories. T051–T052 complete cross-cutting quality work. T026 then runs convergence, and T053 prepares delivery only after it reports Converged.

## Parallel opportunities

- T036, T037 and T038 touch separate test concerns and can run concurrently after T035.
- T039, T040 and T041 touch separate configuration, adapter and geometry modules and can run concurrently after their corresponding failing tests and T003.
- T044 and T045 can run concurrently after T042–T043 because one owns sensor integration and the other owns visuals.
- T048, T049 and the capture-guide preparation in T050 can proceed concurrently once schema-v2 behavior is stable.
- Acceptance capture on distinct authorized monitor/scale combinations may run in parallel, but T032 must consolidate a single physical two-output matrix.

## Parallel example: User Story 1

```text
Task T044: Update per-output middle-third sensors in src/platform/EdgeSensor.qml and src/shell.qml.
Task T045: Implement side-aware inward visuals in src/surfaces/volume/ and src/visual/.
```

## Parallel example: User Story 3

```text
Task T048: Extend automated profile, scale and reduced-motion tests.
Task T049: Document schema-v2 migration and per-output configuration.
```

## Implementation strategy

The refinement MVP is Phase 9, Phase 10 and User Story 1: it delivers focused-output placement plus mouse discovery from the configured middle edge on both outputs. User Story 2 completes focused routing for direct actions, and User Story 3 completes configuration migration, copy/mirror behavior and scale adaptation. The feature is not releasable until the remaining acceptance tasks, physical-hardware disclosures, cross-cutting checks and T026 convergence are complete.

## Phase 15: Convergence

- [ ] T054 Harden and test malformed snapshots, disconnect/reconnect state and bounded retries in `src/platform/NiriEvents.js`, `src/platform/NiriFocusAdapter.qml` and `tests/qml/tst_niri_focus.qml`; existing reducer tests do not establish process recovery or validation of malformed workspace records per T037/T040 and plan: platform routing (partial).
- [ ] T055 Exercise actual router/controller/action integration in `tests/qml/tst_routing.qml` and `tests/qml/tst_actions.qml`; current tests call pure selection helpers and do not establish one-instance behavior, all action routes or drag cancellation on output loss per T043/T046, FR-008 and FR-020 (partial).
- [ ] T056 Complete configuration boundary and side/scale regression coverage in `tests/qml/tst_preferences.qml`, `tests/qml/tst_outputs.qml` and `tests/qml/tst_volume_field.qml`, including cyclic/self/over-limit profiles, invalid v1 migration and left-side non-screen boundaries per T036/T038/T048 and FR-011–012 (partial).
- [ ] T057 Complete the outstanding review, performance and delivery evidence under T035/T051/T053, and the deferred physical two-monitor acceptance under T003/T022/T025/T032, before closing T026 per SC-006–007 and Constitution VI (partial).
