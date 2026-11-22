# Tasks: Summoned Dot-Field Volume OSD

**Input**: spec.md, plan.md, research.md, data-model.md and contracts/ in this directory.
**Status**: Proposed tasks; review and analysis precede implementation. All boxes start unchecked.
**Tests**: Required by the constitution and plan for nonvisual logic, CLI contracts and visual evidence.

## Phase 1: Setup and review

- [x] T001 Resolve artifact review and the constitution amendment through a pull request, updating `.specify/memory/constitution.md` and removing its temporary sync report before commit; record approval and any required spec corrections in `specs/001-summoned-volume-osd/spec.md`.
- [x] T002 Record Quickshell 0.3.2, Qt and Niri prerequisites and tool paths in `docs/development.md`; establish a test environment without modifying system packages, global Quickshell or user compositor configuration without authorization.
- [ ] T003 Create an isolated sensor experiment in `tests/integration/edge-sensor.qml` and record dwell, cancellation, edge clicks, focus, adjacent-output crossing and fractional-scale results in `specs/001-summoned-volume-osd/evidence/edge-input.md`; stop and revise artifacts if required behavior fails.

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
- [ ] T013 [US1] Record the 20-change, 20-edge and 20-cancellation acceptance results in `specs/001-summoned-volume-osd/evidence/feedback.md` with latency method and environment (SC-001–002, SC-007).

## Phase 4: User Story 2 — Adjust volume (P1)

**Goal**: Pointer controls and bindable shell actions adjust audio without focus theft, supporting direct summoning when external summoning is disabled.
**Independent test**: Use slider, mute dot and IPC actions; compare confirmed audio state, pending failure and timeout behavior in both trigger modes.

- [x] T014 [US2] Add pending-write, rapid-command accumulation, mute and stale-sink tests in `tests/qml/tst_actions.qml` and forwarding tests in `tests/test-cli.sh` per `contracts/actions.md`.
- [x] T015 [US2] Extend `src/services/AudioService.qml` with validated writes, confirmation deadline and sink-switch cancellation following data-model.md `AudioOutput.pending`, `AudioOutput.percent` and `AudioOutput.sinkId`; implement above-cap handling per `contracts/actions.md` (FR-005, FR-013, FR-019).
- [x] T016 [US2] Add stationary slider and minimal mute-dot hit targets to `src/surfaces/volume/VolumeOsd.qml`, with timeout and placement protection following data-model.md `Interaction.dragging` and `Interaction.hovered`, and no implicit unmute (FR-002, FR-005, FR-007–008).
- [x] T017 [US2] Implement typed `src/ipc/VolumeActions.qml` target `volume_v1` and the documented JSON result contract, direct action summoning and optional show-only action; keep existing CLI forwarding compatible (FR-018–019).
- [ ] T018 [US2] Document opt-in Niri volume and optional show bindings in `docs/configuration.md`; verify both trigger modes and record results in `specs/001-summoned-volume-osd/evidence/actions.md` without editing user Niri files (SC-001, SC-003).

## Phase 5: User Story 3 — Adapt the experience (P2)

**Goal**: Usable configurable field across wallpapers, motion preferences, displays and scale factors.
**Independent test**: Exercise documented preferences and representative outputs/backgrounds in normal and reduced motion.

- [x] T019 [US3] Add output-loss, fit and scale routing tests in `tests/qml/tst_outputs.qml` using data-model.md `OutputSelection.screenId` (FR-012).
- [x] T020 [US3] Complete output routing and geometry fitting in `src/platform/OutputRouter.qml` and reduced-motion branches in `src/surfaces/volume/VolumeOsd.qml` following data-model.md `Preferences.values`, `OutputSelection.screenId` and `Osd.phase` (FR-009, FR-011–012).
- [x] T021 [US3] Supply reproducible licensed/generated bright, dark, colorful and busy fixtures in `tests/visual/` with provenance and a capture guide in `tests/visual/README.md`; exclude private reference artwork (FR-010).
- [ ] T022 [US3] Record normal/reduced motion, opaque center and feathered edges, open-window stacking, mute distinction, output removal and mixed-scale evidence in `specs/001-summoned-volume-osd/evidence/visual.md`; measure text/control contrast in normal, hover, active and unavailable states per SC-004 (SC-004–006).

## Phase 6: Integration and delivery

- [ ] T023 Integrate QML formatting, import-aware lint and offscreen tests into `.github/workflows/ci.yml` and `scripts/check-qml.sh`, retaining existing checks and failing on unavailable required imports.
- [x] T024 Verify release archive, checksums, installed runtime lookup and CLI status in `tests/test-package.sh`; reconcile `bin/dot-shell`, `install.sh` and `scripts/package-release.sh` if necessary (FR-015).
- [ ] T025 Run `specs/001-summoned-volume-osd/quickstart.md`, record idle and transition frame observations plus exact tested/untested environments in `specs/001-summoned-volume-osd/evidence/verification.md`; measure 20 automatic and 20 direct-action response trials separately using SC-002's command-invocation timing origin.
- [ ] T026 Run Spec Kit convergence against `specs/001-summoned-volume-osd/tasks.md`, append unresolved work rather than silently relaxing requirements, and repeat implementation/verification until Converged before feature merge.

## Dependencies and execution order

T001 and the confirmed single-display portion of T003 gate local implementation; the user authorized proceeding with the remaining hardware-dependent portion of T003 open as acceptance work. T004–T006 establish the foundation. US1 precedes US2 because its surface and service are reused; US3 extends those shared paths. Final delivery depends on all stories. Tests should expose absent behavior before the associated implementation and pass afterward. Review each increment and preserve existing user changes.

## Parallel opportunities

No `[P]` task is advertised as dependency-free; the small slice shares service and surface files. Within US1, backdrop and path work can proceed independently after interfaces are agreed. Within US2, action tests and binding documentation can be prepared independently. Within US3, licensed fixtures can be prepared separately from output tests. Integration must remain sequential where shared files overlap.

## Implementation strategy

First demonstrate US1 as the feedback MVP, then US2 audio controls, then US3 adaptation. US1 alone is an intermediate demonstration, not completion of this specification. All three stories, recorded verification and convergence are required before release.
