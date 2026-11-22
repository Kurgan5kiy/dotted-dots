# Feature Specification: Summoned Dot-Field Volume OSD

**Feature Branch**: `feature/02-summoned-volume-osd`

**Created**: 2026-11-22

**Status**: Reviewed and merged in PR #6; implementation authorized on `feature/06-volume-osd-runtime`.

**Input**: The first feature prompt in `docs/spec-kit-bootstrap.md`, amended by the user's right-edge and backdrop direction.

**Governance**: Constitution version 2.0.0 and the feature artifacts were reviewed through merged PR #6. The user confirmed the single-display edge experiment and authorized implementation; remaining display and visual acceptance work stays open.

## Clarifications

### Session 2026-11-22

- Q: How should the OSD open when the pointer reaches the right edge of the screen? → A: After a very short delay at the edge.
- Q: Should the OSD time out while the pointer is over it? → A: No; keep it open while the pointer remains over it.
- Q: After dismissal at the right edge, when can the edge trigger summon the OSD again? → A: Once the pointer has left the edge and returned.
- Q: How should keyboard volume control work while the OSD is displayed? → A: Use dedicated volume keys or configured shortcuts without interrupting the current application.
- Q: Should the OSD include a mute control? → A: Yes, a minimal separate dot, white when unmuted and grey when muted.
- Q: How should the OSD be dismissed with the keyboard? → A: No dedicated dismissal binding is needed; it closes automatically after an idle delay.
- Q: How opaque should the dark backdrop be? → A: The center should be darker and may be fully opaque, fading softly to transparent edges, as in the supplied visual reference.
- Q: Should there be a keyboard shortcut to show the OSD without changing volume? → A: Provide an optional configurable show action; leave it unbound by default.
- Q: What should happen if reacting to external audio changes is delayed? → A: Try automatic reaction first; provide a binding-driven mode in which shell volume actions change audio and summon the OSD together, without automatic summoning from external audio changes.
- Q: What visual changes are required after the first live preview? → A: Use a vertical volume chain aligned to the field dots. The line connects reached nodes only; the current-level dot is white and unreached nodes remain grey. Keep the right edge and softly bloom from it like light spreading across a wall, without a detached rectangular surface sliding into view.
- Q: What refinement is required after the vertical preview? → A: Dots sit on the dark backdrop, strongest in the opaque center and fading toward its transparent edges, with none outside it. Reached grey nodes must not remain visible behind the line. The right-to-left bloom must be visibly slower, level changes smoothly animated, and the value typography light and Fira Code-like, with optional italic styling.
- Q: How soft should the elliptical boundary be? → A: Use a broader transparency gradient so the outer region is more transparent; retain the dark center.

## User Scenarios & Testing

### User Story 1 - See volume changes (Priority: P1)

A desktop user changes the output volume and sees its current value and mute state emerge from a temporary field of dots without losing sight of the wallpaper.

**Why this priority**: Immediate, legible feedback is the core purpose of the OSD.

**Independent Test**: Change volume and mute state using existing system controls while the shell is running, then observe the value, field, and dismissal.

**Acceptance Scenarios**:

1. **Given** a working audio output and a dormant OSD, **When** its volume or mute state changes, **Then** a local dot field appears near the configured anchor and displays the current value and mute state.
2. **Given** normal motion, **When** the field appears, **Then** a signal travels through selected dots and constructs the value and slider before they become interactive.
3. **Given** an idle OSD, **When** its configured timeout expires, **Then** it retracts toward its anchor and disappears completely.
4. **Given** another volume change during emergence, interaction, or retraction, **When** the new state arrives, **Then** the same OSD presents the latest state and restarts its idle timeout without creating a duplicate.
5. **Given** an open window covering the wallpaper, **When** the OSD is summoned, **Then** it appears above the window and the backdrop fades into the window at its edges.
6. **Given** the OSD is dormant, **When** the pointer remains at the right edge of a display for the edge dwell delay, **Then** the OSD appears on that display and, in normal motion, emerges from right to left. Leaving the edge before the delay expires cancels the trigger.
7. **Given** the OSD is dismissed while the pointer remains at the right edge, **When** the pointer stays there, **Then** the edge trigger does not reopen it until the pointer leaves and returns.
8. **Given** the user has configured a shortcut to the show action, **When** it is invoked, **Then** the OSD shows the current volume and mute state without changing either or taking keyboard focus.

### User Story 2 - Adjust volume in the OSD (Priority: P1)

A user adjusts the current output volume with a pointer or keyboard and lets the OSD dismiss itself without disrupting their previous context.

**Why this priority**: The requested OSD is interactive and must be accessible through both input methods.

**Independent Test**: Open the OSD, adjust the slider with each input method, and compare the displayed value with the resulting output state.

**Acceptance Scenarios**:

1. **Given** the constructed OSD, **When** the user adjusts its slider with a pointer or changes volume using a dedicated key or configured shortcut, **Then** the output volume changes and the display reflects the confirmed current value.
2. **Given** an interactive OSD, **When** the user interacts with its controls, **Then** their hit targets remain stationary and the dismissal timeout pauses until interaction ends.
3. **Given** the OSD is visible and the user stops interacting and moves the pointer away, **When** the idle delay expires, **Then** it dismisses without disrupting the current application.
4. **Given** the OSD is visible, **When** the user presses a dedicated volume key or configured volume shortcut, **Then** the output changes and the OSD reflects its confirmed state without requiring keyboard focus.
5. **Given** the pointer is over the OSD, **When** the idle timeout would otherwise expire, **Then** the OSD remains open; after the pointer leaves, its idle timeout starts again.
6. **Given** the constructed OSD, **When** the user clicks its mute dot, **Then** mute toggles and the dot reflects the confirmed state: white when unmuted and grey when muted, with an additional non-colour distinction.

### User Story 3 - Adapt the experience (Priority: P2)

A user chooses placement, field appearance and timing, or reduced motion, and can read and operate the OSD over different wallpapers and displays.

**Why this priority**: The shell must remain usable and visually coherent across individual desktop environments.

**Independent Test**: Change the documented preferences, enable reduced motion, and exercise the OSD on representative wallpapers and displays.

**Acceptance Scenarios**:

1. **Given** bright, dark, colorful, or visually busy wallpaper, **When** the OSD appears, **Then** its value, mute state and slider remain distinguishable without a hard-edged panel.
2. **Given** reduced motion is enabled, **When** the OSD appears or dismisses, **Then** restrained fades or short transitions replace signal traversal and retraction motion while preserving the same information and controls.
3. **Given** valid changes to spacing, radius, field size, feathering, timing, or placement, **When** the OSD next appears, **Then** it uses those preferences and remains usable within the selected display.
4. **Given** multiple displays or a non-default scale factor, **When** the OSD appears, **Then** it is positioned on the selected display and its controls remain visible and usable.

### Edge Cases

- Rapid changes update the latest value without resetting an active pointer drag or moving controls.
- At minimum or maximum supported volume, further adjustment in that direction leaves the value at the supported limit.
- Muted output is visibly distinct from an unmuted output at minimum volume; displayed volume follows the actual output state.
- If the output disappears or its state cannot be read or changed, the OSD does not claim a successful change; it indicates unavailability and recovers when state becomes available.
- If the selected display disappears, the OSD moves to an available display; if none is available it waits until one is available.
- Invalid or unusable preferences fall back to documented safe values without preventing the OSD from appearing.
- Opening or dismissing the OSD does not interrupt typing or take keyboard focus from the current application.
- Repeated contact with the right edge while the OSD is visible does not create duplicates.

## Requirements

### Functional Requirements

- **FR-001**: The shell MUST observe the current default audio output's state for accurate display. Automatic summoning on external volume and mute changes MUST be configurable and enabled initially. If that trigger is too delayed, users MUST be able to disable it and use shell volume actions that summon the OSD as they request the audio change.
- **FR-002**: The OSD MUST show a readable volume value, a vertical interactive volume chain aligned to the field's dots, and a minimal separate clickable mute dot. The volume line MUST connect nodes only through the reached level, with the current-level dot white and unreached nodes grey. The separate mute dot MUST be white when unmuted and grey when muted and provide an additional non-colour distinction between states. All indicators MUST reflect confirmed output state.
- **FR-003**: The OSD MUST present evenly spaced white dots over a local dark or dark-grey backdrop. The center may be fully opaque; both the dots and backdrop MUST fade gradually to transparency at the field boundaries, revealing underlying content without an outline or hard rectangular edge.

At the selected screen edge, the conceptual field may extend beyond the visible display and be clipped there. Its visible backdrop must meet that edge and fade smoothly inward in an elongated, soft light-pool shape. The appearance must use a restrained bloom/fade rather than lateral translation of a detached card. The vertical chain's pointer control snaps to its node positions; volume keys and IPC retain their configured numeric step and the value label reports the actual confirmed percentage.

Decorative field dots MUST sit on the dark backdrop, strongest over its opaque center and fading toward transparent edges; no decorative dots may remain where the backdrop is fully transparent. Reached chain dots MUST be hidden beneath the connected line, leaving a single white current-level endpoint and grey unreached nodes. Normal-motion appearance MUST visibly expand leftward from the right edge and level changes MUST interpolate smoothly between reached node positions, with stable pointer hit targets. Typography MUST use a configurable light monospaced family with a Fira Code preference and an optional italic setting.
- **FR-004**: In normal motion, the field MUST emerge, trace a signal through selected dots, construct the controls, remain interactive, and retract toward its anchor before becoming fully invisible.
- **FR-005**: The OSD MUST accept pointer slider adjustments after construction and reflect volume changes made with dedicated volume keys or configured shortcuts without requiring focus. Controls and hit targets MUST remain stationary while interactive.
- **FR-006**: Automatic appearance and dismissal MUST NOT take keyboard focus from or disrupt the current application. No dedicated dismissal binding is required.
- **FR-007**: The OSD MUST dismiss after a configurable idle timeout, pause that timeout during interaction or while the pointer is over the OSD, and restart it when the pointer leaves or a new volume or mute change occurs.
- **FR-008**: Changes arriving while the OSD is visible or retracting MUST update one OSD to the latest state without duplicating it or interrupting an active drag.
- **FR-009**: Reduced motion MUST replace traversal and retraction movement with restrained fades or short transitions while retaining all information and interactions.
- **FR-010**: The value, mute indication and slider MUST remain legible and distinguishable over bright, dark, colorful and visually busy wallpapers without a hard-edged panel.
- **FR-011**: Users MUST be able to configure dot spacing and radius, field size, feathering, animation timings, idle timeout and screen placement; invalid values MUST use documented safe defaults.
- **FR-012**: The OSD MUST stay within the selected display's usable area and remain usable across supported scale factors and display changes.
- **FR-013**: The OSD MUST indicate unavailable audio state or failed adjustments without presenting an unconfirmed value as successful, and recover when the output becomes available.
- **FR-014**: Field and path behavior MUST be reusable for future surfaces without requiring those surfaces to be delivered in this feature.
- **FR-015**: The feature MUST provide the minimum executable shell experience needed to demonstrate the OSD on the initial target platform.
- **FR-016**: The OSD MUST appear above open windows as well as over the wallpaper.
- **FR-017**: When the edge trigger is enabled, holding the pointer at a display's right edge for a short configurable dwell MUST summon the OSD on that display; leaving the edge before the dwell expires MUST cancel the trigger. The dwell defaults to 200 ms. After dismissal while the pointer is at that edge, the edge trigger MUST remain inactive until the pointer leaves and returns. In normal motion the OSD MUST emerge from right to left. Automatic summoning from external volume and mute changes follows FR-001 and FR-019.
- **FR-018**: The shell MUST provide a show-only action that displays the OSD without changing volume or mute state and can be bound to a keyboard shortcut. No shortcut is assigned by default.
- **FR-019**: In binding-driven mode, external audio changes MUST update the known state without automatically opening the OSD. Shell volume/mute actions and the show-only action MUST still open it; the edge trigger MUST open it when independently enabled. Pending audio changes MUST NOT be displayed as confirmed before the service reports them.

If an external tool sets volume above the shell's configured adjustment limit, the value label MUST report the actual confirmed percentage. The slider stops at its maximum and the shell MUST NOT lower the volume merely by observing or showing it. Shell adjustments follow the limits in the action contract.

### Key Entities

- **Output state**: The current default audio output's volume, supported limits, mute state and availability.
- **OSD preferences**: The field geometry, dot appearance, feathering, timing, placement and motion preference used to present the OSD.

## Success Criteria

### Measurable Outcomes

- **SC-001**: With automatic audio-change summoning enabled, in a reproducible test of 20 volume or mute changes, the OSD displays the confirmed latest state for all 20, with no duplicate OSDs. In binding-driven mode, 20 accepted shell audio actions summon it directly, while 20 external changes do not open a dormant OSD.
- **SC-002**: Measure two separate sets of 20 trials: external audio changes with automatic summoning enabled, and shell audio actions with it disabled. Each trial MUST produce a first visible response within 500 ms, measured from the initiating audio-command process invocation, including command startup and IPC time. Record the environment and timing method. This measures presentation latency, not audio-write confirmation; the OSD may initially show the previous confirmed value while a write is pending.
- **SC-003**: In tests using both pointer and keyboard, users can increase and decrease volume and toggle and identify mute state; the OSD dismisses automatically after the idle timeout, and mute states remain distinguishable without relying on colour alone.
- **SC-004**: Across at least four representative backgrounds (bright, dark, colorful and busy), including an open window, the volume text MUST reach a contrast ratio of at least 4.5:1 against its composited local background and essential control indicators at least 3:1. Measure normal, hovered, active and unavailable states at the default theme; the muted dot must also retain its non-colour distinction. Record the measurement method and visual evidence that the backdrop fades into underlying content without a hard boundary. Custom appearance combinations that miss these targets must be documented as outside the verified accessible preset.
- **SC-005**: With reduced motion enabled, all appearance and dismissal trials avoid signal traversal and moving retraction while retaining the same controls and state.
- **SC-006**: In a multi-display test including at least two scale factors, the OSD remains within the selected display and usable in every tested configuration.
- **SC-007**: In 20 right-edge dwell trials, the OSD appears on the display whose edge was reached, above any open window; normal-motion recordings show emergence from right to left in each trial. In 20 trials leaving the edge before the configured dwell expires, the edge trigger does not summon it.

## Assumptions

- The OSD follows the system's current default output; selecting or managing devices is outside this slice.
- The configured display is used when available; otherwise an available display is selected. Exact default anchor, timeout, adjustment increment and configuration ranges are resolved during clarification and planning.
- Right-edge summoning uses the display whose edge the pointer reaches; placement for volume-change summoning remains configurable.
- The audio service and at least one display are normally available; unavailable states are temporary and recoverable.
- The bar, launcher, settings application, embedded-wallpaper mode, other OSDs and automatic wallpaper-dot detection are outside this feature.
- Quantitative timing targets are acceptance targets to validate on recorded hardware, not claims about current performance.
- Shell actions exposed for configurable keybindings, including the possible use of a command interface, are a planning consideration. Niri configuration is not modified automatically.

## Constitution Check

The slice retains the feathered field identity under constitution 2.0.0, merged in PR #6; embedded-wallpaper mode remains a future first-class feature. It preserves stable controls, keyboard actions, reduced motion and explicit failure behavior. Planning separates services, platform adapters, visuals, lifecycle, configuration and IPC, and requires nonvisual tests and reproducible visual evidence. Input-region tradeoffs and live compositor support are recorded in the plan and must be verified before acceptance.
