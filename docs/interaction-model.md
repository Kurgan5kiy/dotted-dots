# Interaction Model

## Shared lifecycle

All transient surfaces follow the same conceptual sequence:

1. **Dormant** — no temporary field is visible, or wallpaper dots are passive.
2. **Emerge/Awaken** — a field fades in or compatible wallpaper nodes activate.
3. **Trace** — a signal travels through selected nodes.
4. **Construct** — paths create labels, controls, and supporting geometry.
5. **Interactive** — layout and hit targets remain stable.
6. **Retract** — the surface collapses toward its anchor.
7. **Dormant** — temporary nodes reach zero opacity or wallpaper nodes sleep.

These phases may overlap where a feature specifies it. The accepted volume
OSD reveals its initialized value and line during emergence; it does not fill
from zero afterward. Later volume changes animate the reached line. Its
pointer-driven retreat follows departure while shrinking and fading, whereas
keyboard-only dismissal retreats toward its edge anchor.

## Summoned field

The field may originate from the cursor, bar, focused window, keyboard-invoked
screen position, or screen edge. Its bounds describe the node distribution,
not a visible container.

Required properties include field geometry, node spacing and radius, feather
curve, anchor, contrast behavior, animation timings, and reduced-motion mode.

## Embedded field

Compatible wallpaper metadata should be able to describe:

- image identity and dimensions
- lattice origin and spacing
- row and column count
- node radius
- optional transform or perspective information
- optional masked/occluded regions
- optional irregular node coordinates

The renderer overlays active state, paths, and controls only. It must not make
the wallpaper look like it has two slightly misaligned grids.

## Input rules

- Stable click targets must not move after construction.
- Every action must be keyboard reachable.
- Escape dismisses a transient surface when it owns keyboard focus. Passive
  overlays that do not take focus may instead dismiss automatically without a
  dedicated binding, as specified by their feature.
- Focus returns to the invoking context after dismissal.
- Timeouts pause while the user is interacting.
- Reduced motion replaces traversal with restrained fades or short transitions.
