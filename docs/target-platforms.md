# Target Platforms

## Initial target

- Linux
- Wayland
- Niri
- Quickshell 0.3-compatible APIs, subject to feature-plan validation
- Qt 6 and QML

## Likely integrations

Integrations are introduced only when a bounded feature requires them:

- Niri event stream and action IPC
- PipeWire audio
- MPRIS media
- UPower battery state
- StatusNotifierItem system tray
- NetworkManager and BlueZ

## Compatibility policy

Niri-specific behavior should live behind adapters. Visual primitives and the
animation engine should remain compositor-neutral where practical.

Quickshell is evolving and may introduce API breaks. Each release plan must
state its supported Quickshell range and any version gates.
