# Architecture Direction

This document records boundaries, not a frozen implementation. Feature plans
own detailed technical decisions.

```text
Shell root
├── Core
│   ├── configuration
│   ├── theme and wallpaper sampling
│   ├── motion preferences
│   └── IPC registry
├── Platform
│   ├── Niri adapter
│   └── system service adapters
├── Visual primitives
│   ├── dot field
│   ├── embedded lattice
│   ├── path tracer
│   └── adaptive contrast
├── Surfaces
│   ├── OSDs
│   ├── bar
│   ├── launcher
│   └── other shell surfaces
└── CLI
    ├── lifecycle
    ├── IPC forwarding
    └── updates
```

## Constraints

- Use QML/Quickshell first.
- Keep service state out of purely visual components.
- Use explicit states for animation lifecycles.
- Load expensive surfaces only when required.
- Version public configuration and IPC contracts.
- Treat lock-screen code as a separate security-sensitive surface.
