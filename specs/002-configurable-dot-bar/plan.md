# Implementation Plan: Configurable Dot Bar

**Branch**: Pending clean feature branch | **Date**: 2026-11-24 | **Spec**: [spec.md](spec.md)

## Summary

Add one configurable bar per selected output, on any of four edges, with five reorderable built-in widgets. Always-visible mode reserves space; auto-hide uses a narrow reveal strip. Reuse the volume surface's dot and illumination language while preserving readable, stationary widget targets.

## Technical Context

- **Platform**: QML/JavaScript, Qt 6, Quickshell 0.3.2, Niri 26.04, Wayland; no native code or new runtime package.
- **State**: Schema v3 adds `bar`; migrate v1/v2 in memory without rewriting. Niri event stream for workspaces; Quickshell services for audio, battery, clock and tray.
- **Testing**: Pure QML configuration/layout/state tests, software-rendered fixtures, package and CLI checks, then live four-edge and multi-output acceptance. Logical scales 1, 1.25, 1.5 and 2.
- **Performance**: One bar per selected output, bounded dot count, event-driven updates and minute-precision clock. No full-screen input surface, capture or recurring animation.

## Constitution Check

- **I**: Wallpaper remains visible through feathered dots. Always-visible mode is a user-requested persistent surface; document its relationship to the quiet-at-rest product vision.
- **II**: Upright text, fixed targets, keyboard actions, clear focus/menu behavior, reduced motion and four orientations.
- **III**: Keep services, Niri state, configuration, widgets and visuals separate. Reuse volume service/action; no C++.
- **IV**: Bounded per-output work; profile settled, revealed and hidden states; no polling or frame loop.
- **V**: Bar plus five widgets only; no launcher or notification center.
- **VI**: Automated tests, visual evidence, live checks, honest deferred multi-monitor status and release impact.

**Gate**: Design passes; implementation follows checklist, tasks and consistency review. Existing volume changes are uncommitted, so branch handling must preserve them. Post-design re-evaluation: pass, no exception.

## Project Structure

`src/surfaces/bar/` owns bar windows, layout and reveal state. `src/widgets/bar/` owns workspace, clock, volume, battery and tray widgets. `src/services/` owns battery/tray adapters; `src/platform/` owns Niri workspace mapping; `src/config/` validates settings. Reuse `src/visual/` primitives. `src/shell.qml` composes bars and existing OSD. Add QML tests under `tests/qml/` and visual fixtures under `tests/visual/`.

Implementation adjustment: the five small built-ins share one lattice-aware `BarWidget.qml` host so their targets and spacing remain consistent across orientations. Type-specific service decisions remain in `src/services/`, and Niri actions remain in `src/platform/`. The host can split into separate widget files when their configuration grows.

## Interaction and layout

- Default top, all outputs, always-visible. Exact output names select a subset; disconnected names stay configured but inactive.
- Start/center/end groups preserve order. Horizontal layout uses a row; vertical uses a column with upright text. Insufficient space moves low-priority entries into keyboard-accessible overflow, retaining workspaces first.
- The edge-facing dark core is continuous and supports module text and controls. Broad local dark fields change shape along the bar and feather over nearby windows; the input surface remains local to the bounded reserved depth. Rotate this geometry for each edge without rotating text. Use Fira Code Light when installed, with a monospace fallback.
- Workspace controls keep fixed targets: idle workspaces are small white dots, the active one is brighter, and a Niri activation event displays its index for about 900 ms before restoring the dot.
- Quantize widget lengths and group positions to the 18-logical-pixel lattice. Place each workspace hit target over one lattice node and suppress the background dot at that node. Orient the cross-axis lattice from the screen edge so all four bar placements use the same half-spacing phase as the volume field.
- Reserve one leading lattice cell in the workspace widget but draw no separate dot there; the background lattice supplies an ordinary dot. Place actionable nodes one step beyond it and suppress background dots only at those nodes. Center non-workspace content on the second row from the bar edge, including mirrored bottom/right placements. Exclude lattice dots only around the clock text, with one neighboring node of breathing room on each side along the bar, across static, hover, ambient and module fields. Keep the rest of the lattice continuous; increase the clock from 13 to 16 pixels.
- Filter only the final Niri workspace when it is simultaneously inactive, unnamed and has no active window; the bar's background lattice then supplies an ordinary dot at that position. Keep active, named or occupied trailing workspaces actionable.
- The clock exclusion depends explicitly on each group's x/y placement. Recompute its mapped rectangle when the layout centers or reflows so an initial offscreen/uncentered clock cannot leave stale exclusions over the workspaces. Verify both adjacent background dots in a live crop after reload.
- Apply the same explicit group-position dependency to module accent regions. Tag each region with its widget kind. For the clock only, extend the accent by one lattice step along the bar, half a step inward, and a small strength increment; keep the cached feather and transparent boundary. Verify the clock's actual live position and a readable bright-background crop.
- Keep the accepted control and input depth at `max(32, thickness - 12, field.spacing)` logical pixels (36 at the default) and render the field through `thickness + 30` (78 at the default). In always-visible mode reserve only `max(24, thickness - 24, field.spacing)` (24 by default) with the compositor, so the application can tile 12 pixels nearer the edge. Check that the configured Niri gap keeps controls clear of the application. Render feathered dark fields over the static edge core; animate pointer response with bounded follow and departure values based on the accepted volume motion settings. Reduced motion uses a short stationary fade.
- Visual review supersedes the pale hover implementation: retain a slim dark edge, use cached radial dark shapes derived from `FeatheredBackdrop.qml` for the module pools, and make dot opacity follow the same field alpha as `DotField.qml`. Pointer motion translates the dark pool locally with bounded easing and retreat, while controls stay fixed. Avoid per-frame full-width Canvas repaint. Measure fresh-process idle CPU with and without the bar on the same outputs; investigate any sustained bar-only main-thread load.
- Subsequent review widens the continuous edge and starts a longer feather sooner. No deeper lobe remains permanently fixed under a module. Four broad, overlapping dark-and-dot fields span the bar; each continuously breathes and drifts in its own region and chooses a new position only while nearly transparent. Staggered phases keep the bar visibly alive at all times. Dots remain on the stationary lattice. Suppress this motion for reduced motion. Size every pointer and ambient ellipse so its alpha reaches zero at the window's inner boundary, avoiding a clipped straight edge. Update local fields at a measured rate without full-width repaint per frame.
- For the faster ambient review, shorten the four patch cycles from roughly 5.6–8.3 seconds to staggered 3.3–5.8 seconds. Spread relocation centers across more of each quarter, vary patch lengths over roughly 300–560 logical pixels, and increase smooth local drift without changing the 160 ms timer cadence or full-screen work. Keep relocation at the near-invisible phase and reduced-motion disablement.
- The accepted 2026-11-25 bar is archived before refinement. For the next small change, map each visible widget's actual bounds to bar coordinates. Add one low-strength cached dark-and-dot ellipse per widget, with length proportional to that widget and an inward reach of about 54 logical pixels at the default settings, eight beyond the 46-pixel base fade. Use a shared slow phase to breathe these accents while keeping the four ambient fields active through them. Keep the dot lattice fixed, the controls stationary, and each accent transparent before its local boundary.
- The user clarified that the application window should be higher, not the bar window. Revert the attempted 90-pixel bar depth to the accepted 78 pixels. Keep control geometry and input mask at 36 pixels, reduce only the always-visible compositor reservation to 24 pixels, and validate the resulting application position and overlap in the user's Niri session. The earlier 90-pixel adjustment is superseded.
- Slow only the bar's pointer field position response: use a 420–650 ms follow derived from the configured motion duration and gentler `OutSine` easing, while retaining explicit zero duration, reduced motion and the current opacity timing. Ambient and sound popup animation remain separately timed.
- Always-visible reserves the smaller compositor depth described above. Auto-hide reserves no permanent space and leaves a 2-logical-pixel reveal strip. Reveal after 100 ms; hide 500 ms after pointer/focus/menu release. Reduced motion uses a fade up to 100 ms.
- If a vertical bar and volume sensor share an edge, the bar owns pointer input there. A narrow non-widget section in its middle third forwards dwell to the existing volume summon path; top/bottom thirds never summon volume. With horizontal bars, the independent right/left volume sensor remains reachable. Test shared-edge behavior live and return to the spec if compositor input ordering prevents it.
- Volume widget invokes the existing volume action. Workspace controls target their bar's output. Passive updates never take keyboard focus; explicit keyboard actions use documented bindings.

## Verification and delivery

Document config and public actions. Test four orientations, two visibility modes, hotplug, overflow, unavailable services, tray menus, keyboard use, reduced motion and four logical scales. Capture bright/dark/colorful/busy fixtures and profile idle CPU/frame behavior. Run CI/package smoke checks. Physical two-output evidence remains open until hardware is connected.
