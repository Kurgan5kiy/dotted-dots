# Synthetic visual evidence

The four PNG files are current software-rendered captures of the OSD over
original code-generated backgrounds from `tests/visual/Fixture.qml`.
`retreat.gif` combines seven synthetic frames at 100 ms intervals. This sparse
animation documents the field/illumination behavior; assess smoothness in the
live preview rather than the 10 fps GIF.

All fixture artwork and captures are original project work under GPL-3.0-only.
Rendered numerals use the bundled Allura font under its separate OFL-1.1 license.
No external reference artwork, private wallpaper or desktop capture is used.

Reproduce with `scripts/check-qml.sh` and the FFmpeg command in
`tests/visual/README.md`. These images are evidence of the reviewed appearance,
not a claim that every contrast or display acceptance criterion passes; see
`../visual.md` for the unresolved bright-background contrast target.
