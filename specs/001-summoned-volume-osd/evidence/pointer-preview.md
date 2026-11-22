# Current-Niri pointer preview

Status: the current-Niri preview, including its finite departure-drift
approximation, was accepted by the user after the later refactoring pass.
Exact outside tracking is not implemented. This does not establish convergence.

Environment: Niri 26.04 (`8ed0da4`), package `26.04-1.1`, Quickshell 0.3.2,
Qt 6.12.0. No compositor configuration, system package or audio state was
changed for this preview.

Implemented: surface-local bounded follow with smoothing, finite outward
departure drift, shared shrinking/fading backdrop and decorative-dot alpha,
local control illumination, fixed controls/input bounds, immediate retreat on
pointer departure, and smooth re-entry. Keyboard-only idle dismissal remains.
Reduced motion disables movement and shrink. The line uses nine alpha samples;
the value and mute indicator each fade according to their local illumination.
There is no global pointer feed or tracking outside the surface.

Verification:

- `scripts/check-qml.sh`: formatting, import-aware lint and 59 Qt Test results
  passed, including follow bounds, departure direction, preference validation,
  fixed control positions, partial illumination, reduced motion, actual QML
  hover/leave/re-entry events and continuity when reversing retreat.
- Generated original bright, dark, colorful and busy fixture captures, plus
  seven retreat frames and `dist/visual/pointer-retreat.gif`; reproduction is
  documented in `tests/visual/README.md`. No personal wallpaper is included.
- `tests/test-package.sh`: archive content and checksum verification passed.
- `git diff --check`: passed.
- Live development shell reloaded successfully; show-only IPC returned
  `accepted`. Recent logs showed expected emergence, interaction, retreat and
  dormant transitions without QML load errors.

User review procedure: dwell at the right edge, move slightly within the OSD,
then leave toward the left or vertically. Check whether the moving patch feels
natural and locally dims the stationary chain/value/mute indicator. Re-enter
during retreat to assess reversal. No volume adjustment is needed.

Not established: user visual acceptance, live GPU frame timing/performance,
mixed-scale and multiple-output pointer behavior, contrast acceptance in every
state, or exact tracking outside the fixed OSD surface. Full feature delivery
and convergence remain pending.

## Pointer-boundary clipping correction

The increased follow range exposed nonzero backdrop alpha being clipped by the
fixed surface rectangle. New bright-fixture regression captures first failed
at the left, top and bottom boundaries. Each ellipse now retains its moving
center while its radii contract only enough to leave a transparent two-pixel
inset at those boundaries. Background, dots and control illumination use the
same fitted shapes; the native input region remains fixed.

After correction, `scripts/check-qml.sh` passed formatting, lint and 63 Qt Test
results. These include all three formerly failing rendered boundary checks,
and a geometry sweep through the liquid animation at maximum liquid strength
and follow displacement. `git diff --check` passed. Synthetic captures are
`dist/visual/pointer-{left,top,bottom}-boundary.png`. Live visual acceptance of
the correction remains with the user.
