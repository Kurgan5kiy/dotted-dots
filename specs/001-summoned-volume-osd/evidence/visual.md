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

## Visual-state review evidence

Twenty additional captures now exercise hover, held slider drag, muted,
unavailable and reduced-motion states on each of the four generated
backgrounds. They use the real visual/control components with simulated audio;
drag and mute are driven through their actual pointer hit targets. Assertions
check hover/drag state, requested volume, mute, unavailable presentation and
reduced-motion invariants. The field deformation is frozen at its settled
shape for reproducible screenshots; native timing evidence covers emergence.

`visual/state-matrix.png` is the review sheet. Rows are bright, busy, colorful
and dark; columns are dragging, hovered, muted, reduced motion and unavailable.
Individual images are in `visual/states/`. The existing four normal captures
and native above-window recordings complete the available visual evidence for
review. These are original synthetic fixtures, not personal desktop images.

## Outstanding hardware coverage

Adjacent physical displays, mixed scales and physical output removal remain
untested. T022's visual capture portion is complete; its hardware portion and
T032 remain open. T030's design/spec contradiction is resolved. The PR is ready
for the user's requested review with these limits disclosed.
