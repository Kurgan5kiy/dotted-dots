# Visual acceptance and remaining contrast verification

The user accepted the current-Niri appearance, interaction and refactored
preview, then explicitly requested keeping the current appearance after the
bright-background contrast issue was explained. No shadow, backing or theme
change was made. This preserves the design; it does not waive SC-004 or make
its quantitative contrast target pass.

## Reproducible synthetic captures

`scripts/check-qml.sh` renders original bright, dark, colorful and busy fixtures
to `dist/visual/`. Selected captures and the finite retreat sequence are
published under `evidence/visual/`; no personal wallpaper or desktop screenshots
are included. Their source and reproduction are in `tests/visual/README.md`.
The separate before/after parity check passed all six image comparisons.

## Contrast mismatch

A diagnostic of the composited bright fixture decoded `dist/visual/bright.png`
to RGB using FFmpeg, converted sRGB channels to linear luminance and calculated
`(lighter + 0.05) / (darker + 0.05)` with luminance weights
0.2126 / 0.7152 / 0.0722. Adjacent background samples near the percentage were
RGB 212 at local (135,50) and RGB 192 at (135,60), giving white-foreground
contrast of approximately 1.48:1 and 1.82:1. A background sample beside the mute
dot at (140,477) was RGB 185: white contrast approximately 1.96:1, or 1.45:1 for
the muted grey. These diagnostic samples establish a problem; they are not a
complete glyph/state contrast certification.

SC-004 requires 4.5:1 for text and 3:1 for essential indicators. The approved
appearance therefore remains outside that acceptance target on this bright
fixture. Keeping the current appearance is recorded as the user's decision;
the contrast requirement is left unresolved rather than silently reduced.

## Outstanding coverage

Full normal/hover/active/unavailable contrast measurements, open-window capture
evidence, the complete normal/reduced-motion capture matrix, adjacent displays,
mixed scale factors and physical output removal remain outstanding. Existing
unit tests and the user's single-display acceptance do not establish those
results. T022 and convergence task T030 remain open.
