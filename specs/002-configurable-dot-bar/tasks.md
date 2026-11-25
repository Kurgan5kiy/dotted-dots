# Tasks: Configurable Dot Bar

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/configuration.md`.
**Tests**: Required by the specification and constitution.

## Phase 1: Setup

- [ ] T001 Review `specs/002-configurable-dot-bar/checklists/bar-ux.md` and resolve requirement gaps in `spec.md`, `plan.md` and `contracts/configuration.md` before coding.
- [ ] T002 Preserve the dirty volume work and establish a safe feature branch under `feature/NN-configurable-dot-bar` before modifying `src/shell.qml`.

## Phase 2: Foundation

- [x] T003 Add schema-v3 migration and bar-profile tests in `tests/qml/tst_bar_config.qml`, citing data-model.md `BarProfile.edge`, `BarProfile.visibility`, `BarProfile.outputs`, `BarProfile.thickness`, `BarProfile.revealMs`, `BarProfile.hideMs` and `BarProfile.widgets`.
- [x] T004 Implement schema-v3 validation and v1/v2 in-memory migration in `src/config/Validation.js`, following data-model.md `BarProfile.edge`, `BarProfile.visibility`, `BarProfile.outputs`, `BarProfile.thickness`, `BarProfile.revealMs`, `BarProfile.hideMs` and `BarProfile.widgets`.
- [x] T005 Implement per-output workspace state/action adapter in `src/platform/NiriWorkspaceAdapter.qml`, reusing existing event-stream ownership and testing changes in `tests/qml/tst_bar_workspaces.qml`.
- [x] T006 Add independently unavailable battery and tray service adapters in `src/services/BatteryService.qml` and `src/services/TrayService.qml` with adapter tests in `tests/qml/tst_bar_services.qml`.

## Phase 3: User Story 1 — Place bar (P1)

**Independent test**: All four edges show upright text, stable controls and correct reservation.

- [x] T007 [US1] Add four-edge, scale and feather tests in `tests/qml/tst_bar_layout.qml` and `tests/qml/tst_bar_visual.qml`.
- [x] T008 [US1] Implement per-output bar instances and always-visible reservation in `src/surfaces/bar/BarWindow.qml` and `src/shell.qml`, citing data-model.md `BarInstance.outputId`, `BarInstance.edge`, `BarInstance.orientation` and `BarInstance.availableExtent`.
- [x] T009 [US1] Implement horizontal/vertical group layout and overflow calculation in `src/surfaces/bar/BarLayout.qml` and `src/surfaces/bar/Layout.js`, citing data-model.md `BarInstance.overflowEntries`.
- [x] T010 [US1] Reuse feather/dot visuals in `src/surfaces/bar/BarField.qml` and `src/visual/`, preserving the volume OSD appearance.

## Phase 4: User Story 2 — Configure widgets (P1)

**Independent test**: Reorder, disable and exercise each widget without changing other widgets.

- [x] T011 [US2] Add widget-order, service-state and action tests in `tests/qml/tst_bar_widgets.qml`, `tests/qml/tst_bar_services.qml` and `tests/qml/tst_bar_workspaces.qml`, citing data-model.md `WidgetEntry.type`, `WidgetEntry.group`, `WidgetEntry.enabled`, `WidgetEntry.priority`.
- [x] T012 [US2] Implement built-in workspace and clock branches in `src/widgets/bar/BarWidget.qml`, citing data-model.md `WidgetState.availability` and `WidgetState.confirmedValue`.
- [x] T013 [US2] Implement volume and battery branches in `src/widgets/bar/BarWidget.qml`, using existing volume action and confirmed service state.
- [x] T014 [US2] Implement tray item activation and menus in `src/widgets/bar/BarWidget.qml` and wire all five branches in `src/surfaces/bar/BarLayout.qml`.

## Phase 5: User Story 3 — Visibility (P2)

**Independent test**: Reveal/hide cycles work on four edges with keyboard and open-menu holds.

- [x] T015 [US3] Add reveal, hold, keyboard and reduced-motion coverage in `tests/qml/tst_bar_reveal.qml`, `tests/qml/tst_bar_motion.qml` and `tests/test-installed-runtime.sh`.
- [x] T016 [US3] Implement hidden/revealing/visible/hiding transitions in `src/surfaces/bar/RevealState.js` and `src/surfaces/bar/BarWindow.qml`, citing data-model.md `RevealState.phase`.
- [x] T017 [US3] Add narrow reveal strip and explicit keyboard reveal action in `src/surfaces/bar/BarWindow.qml` and `src/ipc/BarActions.qml`; document public IPC in `specs/002-configurable-dot-bar/contracts/actions.md`.
- [x] T018 [US3] Coordinate middle-third volume dwell at a shared vertical edge in `src/surfaces/bar/BarWindow.qml` and `src/platform/EdgeSensor.qml` without taking top/bottom volume input.

## Phase 6: Verification and delivery

- [x] T019 Update `docs/configuration.md`, `scripts/check-qml.sh`, `tests/test-package.sh` and `tests/test-installed-runtime.sh` for schema v3 and new bar modules.
- [ ] T020 Capture four backgrounds, four edges and both motion modes in `tests/visual/` and `specs/002-configurable-dot-bar/evidence/visual.md`; profile settled and hidden resource use in `specs/002-configurable-dot-bar/evidence/performance.md`.
- [ ] T021 Run `specs/002-configurable-dot-bar/quickstart.md`, record exact hardware/results in `specs/002-configurable-dot-bar/evidence/verification.md`, and leave two-output acceptance open until physical testing.
- [ ] T022 Run Spec Kit convergence against `specs/002-configurable-dot-bar/tasks.md` until Converged or record remaining tasks explicitly.

## Dependencies and implementation strategy

T001–T006 gate story work. US1 is the first visual MVP; US2 adds the five widgets; US3 adds auto-hide. Tests precede implementation within each story. T018 requires the existing volume sensor and bar input model. T019–T022 follow all stories. Files shared across tasks must be edited sequentially. Physical two-output acceptance remains open until hardware is connected.

## Phase 7: User-reviewed style correction

- [x] T023 Add workspace activation state and transient number tests; implement fixed white-dot targets and a brief index reveal in `src/platform/NiriFocusAdapter.qml` and `src/widgets/bar/BarWidget.qml` per FR-011.
- [x] T024 Add four-edge field geometry tests and captures; implement continuous dark edge and a fade extending past the reserved area in `src/surfaces/bar/BarField.qml` and `src/surfaces/bar/BarWindow.qml` per FR-012. Fixed module lobes from this task were later removed by T040.
- [x] T025 Use a light monospaced clock face on the dark edge core and verify its fallback in `src/widgets/bar/BarWidget.qml` per FR-012.
- [x] T026 Align workspace targets to the bar's 18-pixel background lattice and suppress decorative dots at occupied nodes; add alignment tests for all four edges per FR-013.
- [x] T027 Use soft contours and reduce the reserved depth while extending the feather over windows; add geometry tests per FR-013. Fixed shoulders were later removed by T040.
- [x] T028 Reuse bounded pointer follow, retreat and reduced-motion behavior for a local feathered bar light; add pointer-motion tests and normal/reduced captures per FR-013.

## Phase 8: Convergence

- [ ] T029 Isolate bar changes on a short-lived feature branch from main after preserving the dirty volume work, per Constitution VI and T002 (partial).
- [ ] T030 Verify live workspace activation and transient number, tray activation/menus, keyboard focus, and 20 auto-hide cycles with menu holds on each edge in Niri, per FR-006, FR-007 and SC-003 (partial).
- [ ] T031 Verify named-output selection, both connected outputs, hotplug, shared-edge ownership and the remaining logical scales 1.25, 1.5 and 2, per FR-009, FR-010 and SC-005 (partial).
- [ ] T032 Profile settled and hidden bar CPU/frame behavior on the stated hardware and record the result in `specs/002-configurable-dot-bar/evidence/performance.md`, per Constitution IV and T020 (partial).
- [ ] T033 Complete reviewer-owned requirements checklist review and resolve any resulting spec gaps, per T001 (missing).

## Phase 9: Sound-field visual correction

- [ ] T034 Replace the bar's flat pale hover with a continuous dark edge and deeper animated areas using the sound field's cached feathered-dark visual primitive; keep lattice nodes aligned and illumination-coupled per FR-014.
- [ ] T035 Move and settle the local dark module pool with the pointer using bounded sound-field motion; capture normal, hover, departure and reduced-motion evidence per FR-014.
- [ ] T036 Isolate and eliminate the bar's measured sustained idle CPU cost, then record fresh-process settled and hidden CPU/memory observations per FR-014 and Constitution IV.
- [ ] T037 Broaden the continuous edge, shorten the visual depth by one lattice step, and extend the feather so no field boundary is visible; update four-edge synthetic captures and live review.
- [ ] T038 Add several broad, distributed dark-and-dot patches that continuously breathe and drift at irregular positions; verify reduced-motion suppression, stationary lattice nodes, and fixed controls.
- [ ] T039 Ensure static, pointer and ambient field alpha reaches zero before the bar window clips it on all four edges; add edge-pixel visual checks and inspect live Niri capture.
- [ ] T040 Remove permanently fixed module lobes and make the four distributed fields continuously breathe and drift with staggered phases, relocating only while nearly transparent; verify there is no idle interval without motion.
- [x] T041 Preserve the user-accepted bar snapshot, then add a subtle per-module feathered extension derived from visible widget bounds; keep the accents breathing and the ambient field moving through them, with four-edge and layout-change verification per FR-015.
- [ ] T042 Restore the accepted 78-pixel bar window and reduce only the always-visible compositor reservation by 12 logical pixels; verify the application window moves toward the edge, controls remain usable, and the field fades smoothly per FR-016.
- [x] T043 Slow and smooth only the bar pointer field's follow response, with an intermediate-position and settling test, while preserving ambient, sound and reduced-motion timing per FR-017.
- [x] T044 Keep an ordinary background dot before the shifted workspace controls, render Niri's empty trailing workspace as an ordinary dot, align widget content to the second edge-facing dot row, enlarge clock text, and suppress background dots only around the clock in every field; verify lattice geometry and live appearance per FR-018.
- [x] T045 Recompute module accent placement after group layout, then widen and deepen the clock-only feathered accent; verify geometry, fade and live readability per FR-019.
- [x] T046 Increase ambient protrusion pace and vary their locations and widths within distributed zones; verify motion bounds, reduced-motion behavior, feathered edges and live appearance per FR-020.

## Phase 10: Convergence

- [ ] T047 Complete live Niri workspace, tray-menu, keyboard and 20-cycle auto-hide checks on all four edges; record exact results per FR-006, FR-007 and SC-003 (partial).
- [ ] T048 Verify named-output selection, two-output hotplug, shared-edge ownership and logical scales 1.25, 1.5 and 2 in Niri; record exact hardware and results per FR-009, FR-010 and SC-005 (partial).
- [ ] T049 Measure fresh-process settled and hidden bar-only CPU, memory and frame pacing on the stated hardware, and compare them with the same shell without the bar per FR-014 and Constitution IV (partial).
- [ ] T050 Complete normal and reduced-motion visual review on bright, dark, colorful and busy wallpapers for every edge, preserving private captures outside Git per SC-004 (partial).
- [ ] T051 Complete reviewer-owned `checklists/bar-ux.md` and resolve any requirement-quality gaps per T001 (missing).
- [ ] T052 Separate the bar's review history from the volume branch after preserving both sets of work, rebasing from current main when the volume dependency lands per T029 and Constitution VI (partial).
