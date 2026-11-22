# Spec Kit Bootstrap Prompts

## Constitution

```text
$speckit-constitution

Create a constitution for Dot Shell, a modular, wallpaper-first Linux desktop
shell for Niri built with Quickshell and QML.

Make these binding principles:

- original design rather than copying existing shells;
- both dot modes in docs/product-vision.md remain first-class concepts;
- accessibility, keyboard navigation, adaptive contrast, and reduced motion;
- smooth animation without unnecessary full-screen redraws;
- separation of services, Niri adapters, visuals, configuration, and IPC;
- tests for non-visual logic and reproducible visual verification;
- incremental vertical slices instead of infrastructure-first expansion;
- versioned configuration and IPC contracts;
- explicit justification for native C++ and runtime dependencies;
- specification, clarification, planning, tasks, analysis, implementation, and
  convergence as review gates;
- honest reporting of unverified compositor, hardware, and visual behavior.
```

## First feature

```text
$speckit-specify

Build the first executable vertical slice: a summoned dot-field volume OSD.

When volume changes, a borderless local field of evenly spaced dots appears
near a configurable screen anchor. Dots are visible in the useful center and
continuously fade to complete transparency toward every edge. There is no card
fill, outline, or hard rectangular boundary.

A signal travels through selected nodes and constructs a readable volume value
and interactive slider. The OSD shows mute state, supports keyboard and pointer
interaction, remains spatially stable while interactive, and retracts after a
timeout.

It works over bright, dark, colorful, and detailed wallpapers; supports reduced
motion; and exposes configuration for spacing, radius, field size, feathering,
timings, and placement.

Establish reusable field and path primitives, but do not implement the bar,
launcher, embedded-wallpaper mode, settings application, or other surfaces.
```
