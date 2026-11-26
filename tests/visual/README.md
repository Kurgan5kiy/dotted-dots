# Reproducible visual fixtures

`BarVisual::test_feather` writes sixteen `dist/visual/bar-{top,bottom,left,right}-{0,1,2,3}.png` captures. Each edge uses the four synthetic wallpaper treatments below. The captures verify the continuous dark edge and a dotted fade extending beyond the reserved thickness. `bar-breathe-{0,1,2}.png` captures three moments of the distributed ambient field on white; `bar-ambient-patch.png` shows one field reaching full transparency before the visual boundary. `bar-module-accent.png` shows two softly breathing accents whose lengths follow different widget widths. These fixtures do not prove live compositor reservation, tray menus or auto-hide timing.

`bar-hover.png` and `bar-reduced.png` capture the local pointer light over a synthetic bar fixture. The workspace targets use grid nodes and suppress the decorative dot at each occupied coordinate. These captures are static endpoints; the `BarMotion` QML test covers bounded follow, retreat and reduced-motion state changes.

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

## Multi-output capture matrix

When two physical outputs are available, capture the right/right default and
one mirrored left/right profile. For each side, record inward emergence,
interactive and retracting states without horizontally mirroring numerals or
controls. Repeat normal and reduced motion over bright, dark, colorful and busy
fixtures.

Record the exact logical output height and test the last top-third pixel, first
middle-third pixel, last middle-third pixel and first bottom-third pixel. Only
the middle samples may start volume dwell. Include a shared output edge, focus
changes during emergence/interaction/retraction, selected-output removal and a
second sensor while the first OSD is visible. Capture routing at logical scales
1, 1.25, 1.5 and 2; live evidence must use both physical outputs and at least
two scales. Synthetic or single-output runs supplement but do not replace that
matrix, and personal wallpaper/window-title content must not be recorded.
