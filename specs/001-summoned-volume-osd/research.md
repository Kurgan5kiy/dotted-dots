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
