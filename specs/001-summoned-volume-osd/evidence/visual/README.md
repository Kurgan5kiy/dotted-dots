# Synthetic visual evidence

The four PNG files are current software-rendered captures of the OSD over
original code-generated backgrounds from `tests/visual/Fixture.qml`.
`retreat.gif` combines seven synthetic frames at 100 ms intervals. This sparse
animation documents the field/illumination behavior; assess smoothness in the
live preview rather than the 10 fps GIF.

All fixture artwork and captures are original project work under GPL-3.0-only.
Rendered numerals use the bundled Allura font under its separate OFL-1.1 license.
No external reference artwork, private wallpaper or host desktop capture is used.

`native-edge.gif` and `native-edge-settled.png` are composited captures from
the private nested Niri timing test over an original opaque white application
fixture. The GIF samples first/middle/settled frames from one dwell trial at a
display rate of 5 fps; it does not reproduce exact frame timing. All twenty
trial coordinate records and timestamps are in `../native-timing.json`; the
test regenerates all sixty original PPM frames. No host desktop pixels enter
these captures.

Reproduce with `scripts/check-qml.sh` and the FFmpeg command in
`tests/visual/README.md`. These images are evidence of the reviewed appearance,
not a claim that every display/state acceptance criterion passes; see
`../visual.md` for the approved design and documented bright-background limits.
