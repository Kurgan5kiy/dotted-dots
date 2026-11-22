# Shell Source

`shell.qml` starts the first volume OSD runtime. Audio, configuration, platform
input, IPC, lifecycle and visuals live in separate directories. The ordinary
QtQuick `surfaces/volume/VolumeField.qml` can be rendered and tested independently
of its Wayland `VolumeOsd.qml` window wrapper.

Run with `qs -p src/shell.qml`. Development commands and configuration are
documented in `docs/configuration.md`. The visual design remains under review;
this is not yet a converged release.
