# Shell Source

`shell.qml` starts the first volume OSD runtime. Audio, configuration, platform
input, IPC, lifecycle and visuals live in separate directories. The ordinary
QtQuick `surfaces/volume/VolumeField.qml` can be rendered and tested independently
of its Wayland `VolumeOsd.qml` window wrapper.

`visual/FieldLight.qml` owns field motion and illumination. It prepares shared
ellipse coefficients once per shape change; `DotField.qml` samples them without
rebuilding geometry per dot. `surfaces/volume/VolumeChain.qml` owns the fixed
chain and emits adjustment/drag signals; it does not import an audio service.
`visual/MuteDot.qml` similarly emits a toggle request. `VolumeField.qml` connects
these reusable visuals to the OSD's controller and audio model.

The bounded fake-audio performance probe and before/after visual comparison
are documented in `tests/performance/README.md`.

Run with `qs -p src/shell.qml`. Development commands and configuration are
documented in `docs/configuration.md`. The visual design remains under review;
this is not yet a converged release.
