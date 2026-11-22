# Research: Summoned Volume OSD

## Audio

**Decision**: Plan to use the Quickshell PipeWire default sink and track it with `PwObjectTracker`; observe state and write through audio properties. Treat a null or switching sink as unavailable until confirmed.

**Rationale**: The documented default sink can temporarily be null, and tracked audio exposes volume and mute: [default sink](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/Pipewire/), [audio properties](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/PwNodeAudio/).

**Alternatives**: Repeated CLI polling adds processes and latency. Confirmation and failure reporting require live testing.

## Overlay and edge input

**Decision**: Use a configurable, initially one-logical-pixel edge-anchored layer-shell sensor and a bounded overlay with restricted input regions and no keyboard focus. The sensor owns input only in its strip; the visible OSD owns input over its field for hover and controls. Do not claim passive global observation or click-through inside those regions. Live testing remains required.

**Rationale**: [Layer-shell](https://quickshell.org/docs/v0.3.1/types/Quickshell.Wayland/WlrLayershell/) supports edge surfaces; [window masks](https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow/) limit click regions. Neither establishes passive hover detection with complete input pass-through or unobstructed crossing at adjacent-output edges. Hover across the OSD presents the same tradeoff. Test on Niri before approving the design.

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

## Pointer-following light: outside-surface investigation

**Requested behavior**: A bounded moving dark patch illuminates stationary
controls. During departure it continues following the actual pointer while
shrinking and fading. The user requested investigation of exact tracking and
has not accepted extrapolation from the last exit direction.

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

**Decision pending**: Select between a compositor version supporting cursor-only
capture, a portal/PipeWire prototype on the current compositor, or a revised
outside-tracking requirement. No compositor installation, screen-sharing
session, global input capture or runtime tracking change was performed by this
investigation. Update the plan before introducing a dependency or native helper.

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
