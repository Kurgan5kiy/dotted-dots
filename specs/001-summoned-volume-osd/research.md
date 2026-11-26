# Research: Summoned Volume OSD

## Audio

**Decision**: Plan to use the Quickshell PipeWire default sink and track it with `PwObjectTracker`; observe state and write through audio properties. Treat a null or switching sink as unavailable until confirmed.

**Rationale**: The documented default sink can temporarily be null, and tracked audio exposes volume and mute: [default sink](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/Pipewire/), [audio properties](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/PwNodeAudio/).

**Alternatives**: Repeated CLI polling adds processes and latency. Confirmation and failure reporting require live testing.

## Overlay and edge input

**Decision**: Use one configurable one-to-four-logical-pixel layer-shell sensor per output, limited to the middle third of its resolved left or right edge, plus a bounded overlay with restricted input and no keyboard focus. The sensor owns input only in its narrow middle strip; the visible OSD owns input over its field for hover and controls. Reserved top/bottom thirds have no Dot Shell surface. Live testing remains required.

**Rationale**: [Layer-shell](https://quickshell.org/docs/v0.3.1/types/Quickshell.Wayland/WlrLayershell/) supports edge surfaces and margins. Sizing the actual sensor window to the middle third preserves pass-through in the reserved thirds. Layer shell does not establish unobstructed crossing at adjacent-output edges, so live Niri testing remains required.

**Alternatives**: Full-screen input capture disrupts applications; pointer polling conflicts with performance rules. A compositor-specific event mechanism requires verification and an isolated adapter. Failure returns the requirement to clarification.

## Actions and bindings

**Decision**: Plan versioned volume actions through Quickshell IPC and existing CLI forwarding; document opt-in Niri bindings without changing configuration.

**Rationale**: [IPC handlers](https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler/) expose typed functions and [Niri bindings](https://github.com/niri-wm/niri/blob/main/docs/wiki/Configuration%3A-Key-Bindings.md) can spawn commands. Existing volume tools remain supported by observation.

**Alternatives**: Automatic compositor configuration edits are outside the safety boundary.

## Visuals and verification

**Decision**: Draw a bounded local field and feathered dark gradient with reduced-motion alternatives. Validate four backgrounds, open windows, outputs and scales; record latency and frame observations on named hardware.

**Alternatives**: Hard-edged panels violate the visual specification; an opaque center is permitted. Qt tools were found under `/usr/lib/qt6/bin` (6.12.0). The user installed Quickshell 0.3.2, verified by `qs --version`; live behavior still requires testing. The [0.3.2 changelog](https://quickshell.org/changelog/) explicitly adds Qt 6.12 support, so this packaged release replaces 0.3.1 as the initial validation baseline.

## Backdrop rendering

**Decision**: Cache a bounded Canvas image with smooth feathered alpha, repaint on configuration/geometry changes only, and animate the item transform and opacity. Use bounded reusable dot items separately.

**Rationale**: [Qt Canvas](https://doc.qt.io/qt-6/qml-qtquick-canvas.html) supports gradients and image rendering, but warns about large or frequently repainted canvases. Caching avoids per-frame image uploads. [ShaderEffect](https://doc.qt.io/qt-6/qml-qtquick-shadereffect.html) requires baked shader assets in Qt 6; avoid the extra build step unless profiling proves this simpler design insufficient.

**Alternatives**: Full-screen canvases and repaint loops conflict with performance requirements; native rendering is unjustified without measurements.

## Focused-output routing on Niri 26.04

**Decision**: Add a Niri-specific adapter around one long-lived
`niri msg -j event-stream` process. Reduce initial and incremental workspace
events into the currently focused output name and readiness/diagnostic state.
Use that output only for a dormant non-pointer summon; keep the selected output
fixed until the OSD returns to dormant.

**Rationale**: Niri 26.04 provides complete initial workspace state followed by
incremental `WorkspacesChanged` and focused `WorkspaceActivated` events. Each
workspace identifies its output. This gives authoritative focused-output state
without a recurring poll or process spawn for every volume event. Niri-specific
parsing remains behind the platform boundary and unknown event variants can be
ignored for forward compatibility.

**Alternatives considered**: Running `niri msg -j focused-output` for every
summon is simple but adds startup latency and races. Tracking only focused-window
events does not provide enough workspace/output context. Interactive window
picking, full-screen input surfaces, global cursor polling and native helpers
violate the interaction, performance or dependency constraints.

## Pointer-output fallback on empty workspaces

**Decision**: On the Niri 26.04 baseline, use the same focused-output event
state as the pointer-output fallback only when the compositor configuration
uses focus-follows-mouse. Validate 20/20 empty-workspace trials across both
physical outputs on the user's existing configuration. If any trial fails,
return to the specification; do not substitute global capture or polling.

**Rationale**: Niri 26.04 exposes no cursor-position or pointer-output IPC, and
Quickshell 0.3.2 exposes no global cursor position. With focus-follows-mouse,
crossing outputs updates Niri's focused workspace/output even when no window is
focused, providing the requested result through the event stream. This is a
documented platform prerequisite, not a generic Wayland guarantee.

**Alternatives considered**: A portal screencast can expose cursor metadata but
adds consent, capture lifecycle and avoidable dependencies. Pointer constraints,
virtual pointers and relative-pointer protocols do not passively reveal global
position. A configured fixed fallback does not satisfy the clarified behavior.

## Per-output edge zones and mirroring

**Decision**: Create one narrow layer-shell sensor per connected output, placed
only over the middle third of its resolved left or right logical edge. Compute
top and bottom margins as `floor(height / 3)`, leaving the zero-to-two-pixel
remainder in the middle. Emit output plus side and mirror only side-aware
geometry/motion—not the entire visual tree.

**Rationale**: A middle-third window leaves the reserved top and bottom thirds
without any Dot Shell input surface. Pure arithmetic and profile resolution are
deterministically testable across scales. Explicit inward direction preserves
readable text and stable controls on both sides.

**Alternatives considered**: A full-height transparent window with a middle
MouseArea can still own input in reserved zones. Negative scaling mirrors text
and controls. A single sensor cannot represent independent per-output sides.
Shared edges remain compositor-dependent and require live testing.

## Configuration schema v2

**Decision**: Introduce schema v2 and accept schema v1 through an in-memory,
non-writing migration. Replace fixed `placement.output` semantics with
`placement.fallbackOutput`; add global `edge.side` and bounded named
`edge.outputs` profiles. Each profile has either an explicit `side`, or
`copyOf` plus `mirror`. Keep the volume action target at v1.

**Rationale**: Focused-output routing changes the old output field from primary
selection to final fallback, which warrants an explicit configuration version.
Named copy relationships avoid unstable output enumeration. A global default
of `right` gives the requested right/right profile without requiring private
output names. Presentation routing does not change the public action payloads.

**Alternatives considered**: Silently adding fields to v1 hides the changed
placement meaning. A `first`/`second` mode depends on enumeration order. A bare
output-to-side map cannot express requested copy/mirror relationships. User
files must never be rewritten automatically.

## Logical edge bounds

**Decision**: Divide each Quickshell `ShellScreen` logical height into thirds on
the initial baseline. Document that Quickshell 0.3.2 exposes no dependable
compositor work-area property and that third-party exclusive zones are not
subtracted.

**Rationale**: The overlay is output-relative and the current implementation
already uses logical output geometry. This produces deterministic zones across
scale factors while avoiding an unreliable inferred work area.

**Alternatives considered**: Deriving reservations from unrelated layer-shell
clients is incomplete and would couple the feature to compositor internals.
Claiming reserved-area support without a trustworthy source would violate the
delivery evidence rules.

## Pointer-following light: outside-surface investigation

**Requested behavior**: A bounded moving dark patch illuminates stationary
controls. The accepted Niri 26.04 behavior uses a short finite continuation of
the last outward direction while shrinking and fading; exact outside-surface
tracking is not part of this refinement.

**Verified locally**: The running compositor advertises wlr screencopy v3,
virtual pointer v2, pointer constraints v1, pointer gestures v3 and relative
pointer v1. It does not advertise ext-image-copy-capture. The installed
`niri msg --help` exposes no cursor-position request.

**Protocol findings**:

- Ordinary Wayland pointer motion is surface-local. Relative pointer events
  [share pointer focus](https://raw.githubusercontent.com/wayland-mirror/wayland-protocols/main/unstable/relative-pointer/relative-pointer-unstable-v1.xml)
  and therefore do not solve tracking after leaving the OSD. A larger input
  surface would intercept application input in its added area.
- Niri 26.04's [IPC request contract](https://raw.githubusercontent.com/niri-wm/niri/v26.04/niri-ipc/src/lib.rs)
  has no cursor-coordinate request or motion subscription.
- A screen-sharing session can supply cursor coordinates as PipeWire metadata;
  the [portal contract](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.ScreenCast.html)
  requires session setup and normally user source selection. Niri's maintainer
  [confirms metadata support in 26.04](https://github.com/niri-wm/niri/discussions/4341).
  This is a candidate, not a tested implementation, and would add capture
  lifecycle and dependencies to a volume overlay.
- Newer upstream [Niri code](https://raw.githubusercontent.com/niri-wm/niri/main/niri-ipc/src/lib.rs)
  includes `ExtImageCopyCaptureCursor`, explicitly describing cursor image and
  position capture. The [cursor-session protocol](https://wayland.app/protocols/ext-image-copy-capture-v1#ext_image_copy_capture_cursor_session_v1)
  is a promising cursor-only route without desktop image buffers. It is absent
  from the running compositor; compatibility, a client adapter, packaging and
  performance still require validation.

**Decision**: Retain the accepted bounded surface-local follow and finite
departure drift. Do not add cursor capture, a portal session, compositor
installation, global input capture, native helper or runtime dependency. Reopen
this research only if a future specification requires exact outside tracking.

### Upstream support verification

The local binary reports `niri 26.04 (8ed0da4)`, packaged as `26.04-1.1`.
GitHub's [latest release](https://github.com/niri-wm/niri/releases/latest)
still resolves to v26.04. Cursor-only capture is implemented in upstream
development code, rather than a newer stable release:

- [The capture handler](https://raw.githubusercontent.com/niri-wm/niri/main/src/handlers/image_copy_capture.rs)
  implements `new_cursor_session` and immediately refreshes cursor position.
- [The compositor implementation](https://raw.githubusercontent.com/niri-wm/niri/main/src/niri.rs)
  implements `refresh_image_copy_cursor_sessions`, sending position separately
  from cursor images. An **output** source tracks across applications; a window
  source intentionally stops reporting when that window loses pointer focus.
- Coordinates are output-relative transformed physical pixels, requiring
  scale/transform conversion for the shell's logical coordinates. Hidden
  pointers report no position, and leaving the output ends that output's feed.

This establishes source-level feasibility on a development build, not runtime
verification or turnkey QML support. A protocol client and live tests would
still be needed. Installing the current stable package again would not add it.
