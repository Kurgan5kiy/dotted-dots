# Product Vision

## Purpose

Dot Shell is a complete, modular Linux desktop shell whose interfaces emerge
from dots and paths rather than permanent panels. It targets Niri first and is
built with Quickshell and QML.

## Experience promise

The wallpaper is the primary visual surface. At rest, the shell is quiet. When
an action is invoked, a latent coordinate system becomes visible, constructs a
functional interface, and disappears when the interaction is complete.

## Dot modes

### Summoned field

This mode works with any wallpaper. A local matrix appears from nowhere around
an anchor such as the cursor, a screen edge, or a focused object. It has no
border or hard rectangular edge. Dot opacity is strongest in the useful area
and continuously feathers to zero toward every boundary. A dark backdrop may
support contrast, with a center that can be opaque and edges that feather to
zero, revealing the wallpaper or windows behind it.

The first volume OSD establishes the accepted summoned-field visual pattern:
a softly moving dark light pool with its gradient attached, a white dot grid
whose opacity follows that illumination, and minimal stationary controls.
Nearby pointer movement nudges the pool; departure shrinks and fades it,
partially extinguishing controls as illumination moves away. Handwritten
values and small solid status dots complement the dot-and-line composition.
Future summoned surfaces should follow this visual language while specifying
their own behavior; this does not add a surface to the active feature.

### Embedded field

This mode works with compatible dotted wallpapers. The shell aligns active
effects with dots already visible in the image. Dormant nodes illuminate,
pulse, and connect without drawing a second visible grid.

Compatible wallpapers should use explicit lattice metadata for reliable
alignment. Automatic visual detection is experimental future work, not an
initial requirement.

## Interaction lifecycle

```text
dormant → emerge or awaken → trace → construct → interact → retract → dormant
```

## Product scope

The complete shell may eventually contain:

- adaptive bar and Niri workspace controls
- audio, brightness, microphone, and media OSDs
- application and action launcher
- notifications and quick settings
- desktop widgets
- settings and theme tooling
- lock and session surfaces
- extension points and a public IPC contract
- compatible-wallpaper tooling

## Principles

- Wallpaper-first, not panel-first
- Quiet at rest, expressive during interaction
- Motion communicates origin, relationship, and destination
- Stable controls after construction
- Keyboard and pointer parity
- High contrast without hiding the wallpaper unnecessarily
- Reduced-motion equivalents for every major transition
- Graceful performance degradation
- Dense information only when the task needs it

## Inspirations and non-goals

Dot Shell may take atmospheric inspiration from cinematic interfaces and
eDEX-UI's sense of a responsive machine. It does not copy eDEX-UI's terminal
dashboard, layout, or functionality. It does not copy Caelestia's visual
language.

It is not a permanently visible HUD, does not require one specific wallpaper,
and does not trade basic usability for decorative animation.
