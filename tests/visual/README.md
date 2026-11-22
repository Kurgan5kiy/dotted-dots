# Reproducible visual fixtures

`Fixture.qml` supplies four original code-generated backgrounds: white, near-black, colorful tiles and a busy black/white checkerboard. It contains no external artwork; it is covered by the repository's GPL-3.0-only license.

The reusable `src/surfaces/volume/VolumeField.qml` can be rendered with a controlled audio/controller model over these fixtures without launching a desktop shell, changing audio or capturing personal wallpaper. Live screenshots from the development desktop remain temporary private files outside the repository.

Run `scripts/check-qml.sh` to produce `dist/visual/{bright,dark,colorful,busy}.png` through Qt Quick Test's image capture. The snapshots use the software backend for deterministic CI rendering; they do not establish GPU performance or live compositor compatibility.

Required evidence still includes normal/reduced motion, hover/active/unavailable states, text and indicator contrast, edge alignment, multi-output and fractional scale observations. Unit snapshots supplement rather than replace live compositor evidence. The current visual layout is being reviewed with the user and is not yet accepted.

Dots are strongest on the dark center and follow the backdrop's alpha to zero at its transparent boundary. The volume column is removed from the decorative grid; reached grey nodes are hidden beneath its animated line. Synthetic tests assert a visible center dot and an uncovered transparent boundary.

The current-Niri pointer preview also writes `dist/visual/pointer-retreat.png`:
on the bright fixture, move the simulated light toward local `(1, 40)`, leave,
and capture 300 ms into retreat. The fixed chain is partially extinguished by
the moving, shrinking backdrop. `test_realHoverEventsStartAndReverseRetreat`
exercises actual QML pointer events across the fixed boundary and re-entry;
the pure pointer-model tests cover follow bounds and departure direction.
Outside-surface movement remains a finite drift, not a global pointer feed.

The same test writes seven `pointer-retreat-0.png` through
`pointer-retreat-6.png` frames at roughly 100 ms intervals. After the QML check,
generate a review animation with:

```sh
ffmpeg -y -framerate 10 -i dist/visual/pointer-retreat-%d.png \
  -vf 'split[a][b];[a]palettegen[p];[b][p]paletteuse' \
  -loop 0 dist/visual/pointer-retreat.gif
```

These sparse software-rendered frames document partial illumination and
shrinking; judge smoothness in the live preview, not this 10 fps artifact.

`dist/visual/states/` contains twenty additional state captures: hover,
dragging, muted, unavailable and reduced motion on each of the four fixtures.
They are exercised by `VolumeField::test_visualStates` with simulated audio.

`pointer-{left,top,bottom}-boundary.png` capture the field at maximum configured
follow range and liquid strength on a bright fixture. The regression checks
assert full transparency at the non-screen boundaries rather than accepting a
hard rectangular cut through a moving gradient.
