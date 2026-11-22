# Reproducible visual fixtures

`Fixture.qml` supplies four original code-generated backgrounds: white, near-black, colorful tiles and a busy black/white checkerboard. It contains no external artwork; it is covered by the repository's GPL-3.0-only license.

The reusable `src/surfaces/volume/VolumeField.qml` can be rendered with a controlled audio/controller model over these fixtures without launching a desktop shell, changing audio or capturing personal wallpaper. Live screenshots from the development desktop remain temporary private files outside the repository.

Run `scripts/check-qml.sh` to produce `dist/visual/{bright,dark,colorful,busy}.png` through Qt Quick Test's image capture. The snapshots use the software backend for deterministic CI rendering; they do not establish GPU performance or live compositor compatibility.

Required evidence still includes normal/reduced motion, hover/active/unavailable states, text and indicator contrast, edge alignment, multi-output and fractional scale observations. Unit snapshots supplement rather than replace live compositor evidence. The current visual layout is being reviewed with the user and is not yet accepted.

Dots are strongest on the dark center and follow the backdrop's alpha to zero at its transparent boundary. The volume column is removed from the decorative grid; reached grey nodes are hidden beneath its animated line. Synthetic tests assert a visible center dot and an uncovered transparent boundary.
