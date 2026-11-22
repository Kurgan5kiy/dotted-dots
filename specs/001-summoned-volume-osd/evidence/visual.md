# Visual acceptance and contrast diagnostics

The user accepted the current-Niri appearance, interaction and refactored
preview, then explicitly requested keeping the current appearance after the
bright-background contrast issue was explained. No shadow, backing or theme
change was made. The user then explicitly requested revising the spec to
follow the accepted implementation's visual pattern. SC-004 now evaluates
fidelity to that pattern and documents contrast limits, rather than enforcing
the earlier fixed ratios. No runtime visual change accompanies this revision.

## Reproducible synthetic captures

`scripts/check-qml.sh` renders original bright, dark, colorful and busy fixtures
to `dist/visual/`. Selected captures and the finite retreat sequence are
published under `evidence/visual/`; no personal wallpaper or desktop screenshots
are included. Their source and reproduction are in `tests/visual/README.md`.
The separate before/after parity check passed all six image comparisons.

## Recorded contrast limits

A diagnostic of the composited bright fixture decoded `dist/visual/bright.png`
to RGB using FFmpeg, converted sRGB channels to linear luminance and calculated
`(lighter + 0.05) / (darker + 0.05)` with luminance weights
0.2126 / 0.7152 / 0.0722. Adjacent background samples near the percentage were
RGB 212 at local (135,50) and RGB 192 at (135,60), giving white-foreground
contrast of approximately 1.48:1 and 1.82:1. A background sample beside the mute
dot at (140,477) was RGB 185: white contrast approximately 1.96:1, or 1.45:1 for
the muted grey. These diagnostic samples establish a problem; they are not a
complete glyph/state contrast certification.

The former 4.5:1 text and 3:1 indicator targets were explicitly superseded by
the user's direction to make the spec follow the approved design. These
measurements remain unchanged and document its visibility limits. They are
not evidence of high-contrast accessibility certification. Do not add a shadow,
card or larger opaque area solely to satisfy the superseded targets.

## Outstanding coverage

The complete normal/hover/active/unavailable visual capture matrix, open-window
evidence, full normal/reduced-motion captures, adjacent displays, mixed scales
and physical output removal remain outstanding. Existing unit tests and
single-display acceptance do not establish those results. T022 retains that
visual evidence work; T030's design/spec contradiction is resolved.
