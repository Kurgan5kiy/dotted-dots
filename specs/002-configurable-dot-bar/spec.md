# Feature Specification: Configurable Dot Bar

**Feature Branch**: Pending separate branch from main; existing volume work remains preserved.
**Created**: 2026-11-24
**Status**: User-approved scope; technical planning next. Visual refinements may follow live review.
**Input**: Four-edge bar with configurable widgets and the accepted volume field's dotted style. User selected workspaces, clock, volume, battery and system tray; support always-visible and auto-hide modes, with always-visible as the personal default.

## Recorded Decisions

- The user approved this specification and expects to refine details during implementation.
- Output selection is configurable; the user's default is all connected monitors, including both monitors when connected. Each output gets its own bar with workspace indicators for that output.
- Both always-visible and auto-hide modes are required; the user's default is always-visible.
- The workspace widget rests as white dots. On workspace activation, its number appears briefly, then returns to a bright dot.
- The bar has a continuous dark core at its screen edge. Its deeper areas continuously change shape and feather to transparency slightly over application windows; no module-shaped extension remains static. Clock text stays white on the dark core and uses a slim monospaced face such as Fira Code Light.
- An ordinary background lattice dot remains at the first node of the workspace group; actionable workspace dots begin at the next node and replace decorative dots there. The leading dot must have exactly the same rendering as ordinary dots elsewhere, including the dot after the actionable workspaces. Niri's inactive, unnamed, empty trailing workspace appears as an ordinary background dot after the actionable workspaces. Clock and other widget content centers on the second dot row from the screen edge. Only the clock clears nearby decorative dots, including one dot position on either side along the bar; other widgets do not punch gaps into the lattice. Deeper dark areas have soft contours and keep moving around the bar. A local field follows pointer motion and settles or retreats like the accepted volume field. The bar reserves less than its full visual depth so more window area remains available while its fade overlaps the window.
- User visual review rejected the flat pale bar hover. The bar must use the accepted sound field's deep dark light pool, broad feather and dot illumination: background dots brighten and fade with that pool, and pointer motion moves the dark pool rather than painting a white glow. Keep a continuous dark edge core between moving areas.
- Further review: the continuous edge must be broader and transparency must start early enough to avoid a visible contour break. Several broad dark-and-dot areas must continuously breathe and drift at different positions along the bar; each relocates within its region only while nearly transparent. There must be no stationary module-shaped extensions or idle interval without movement. The effect must not read as one traveling wave or another cursor. Every field must reach zero opacity before the bar window clips it, leaving no visible hard edge. The accepted visual depth remains 78 pixels by default; smaller compositor reservation lets the feather overlap the application window.

### Validation of output selection

With all-output selection, connecting an output creates its bar and disconnecting it removes that bar and its reservation. With an explicit output selection, only matching connected outputs receive bars; disconnected selections remain stored until those outputs return.

## User Scenarios & Testing

### User Story 1 — Place the bar (Priority: P1)

The user places a quiet, readable dotted bar at the top, bottom, left or right of the desktop.

**Why this priority**: Placement and a coherent visual identity define the surface.
**Independent Test**: Select each edge and verify upright content, usable targets and correct reserved space.
**Acceptance Scenarios**:

1. Given a configured edge, when the bar opens, then widget groups follow that edge and text remains upright.
2. Given always-visible mode, when an application is tiled, then its usable area excludes the bar's configured thickness.
3. Given bright, dark, colorful or busy wallpaper, when the bar is visible, then the soft dark field supports readable controls and dots feather into the wallpaper without a hard rectangular outline.

### User Story 2 — Configure useful widgets (Priority: P1)

The user enables, disables and reorders workspaces, clock, volume, battery and system tray in start, center and end groups.

**Why this priority**: The bar must provide useful information and actions.
**Independent Test**: Reorder and disable widgets; exercise each supported action.
**Acceptance Scenarios**:

1. Given a valid ordered configuration, when loaded, then enabled widgets appear in their chosen group and order.
2. Given workspaces on an output, when one is selected, then that workspace is activated and the active indicator updates.
3. Given the volume widget, when activated, then the existing volume control is summoned using its established routing policy.
4. Given a battery, when charging or charge state changes, then confirmed state is displayed; absent hardware hides the battery widget.
5. Given a tray item, when activated or its menu requested, then the item's supported action or menu is accessible in all orientations.

### User Story 3 — Choose visibility (Priority: P2)

The user chooses always-visible or auto-hide behavior independently of edge placement.

**Why this priority**: Both modes are explicitly requested; always-visible is the user's initial choice.
**Independent Test**: Change mode, approach and leave the edge, and use a tray menu while the bar is revealed.
**Acceptance Scenarios**:

1. Given auto-hide mode, when the pointer reaches the reveal region, then the bar appears and remains usable while hovered or while a menu is open.
2. Given no ongoing interaction, when the hide delay expires, then the bar retracts and only its narrow reveal region remains active.
3. Given reduced motion, when showing or hiding, then short fades replace travel while controls retain their fixed positions.

### Edge Cases

- Output removal and reconnection must not leave orphan surfaces or reserved space.
- Invalid widget names/settings produce diagnostics and safe fallback without disabling valid widgets.
- Long tray lists, small displays and vertical layouts require an accessible overflow mechanism rather than overlapping targets.
- Unavailable audio, battery or tray services must not crash other widgets or show invented state.
- Bar input and the volume middle-edge sensor must have explicit ownership when sharing an edge.

## Requirements

### Functional Requirements

- **FR-001**: Support top, left, bottom and right placement, with upright text and orientation-appropriate layout.
- **FR-002**: Support always-visible and auto-hide modes; default to always-visible. Visible mode reserves space; auto-hide overlays content without persistent reservation.
- **FR-003**: Provide workspaces, clock, volume, battery and system-tray widgets, individually enabled and ordered within start/center/end groups.
- **FR-004**: Match the accepted volume style through dot-aligned geometry, white dots, soft dark feathered shading and minimal stable controls. Hover illumination may move subtly; targets must remain fixed. Continuous ambient movement must remain bounded and avoid full-width repaint each frame.
- **FR-005**: Display confirmed service state and degrade independently when services or hardware are unavailable.
- **FR-006**: Allow workspace activation, volume-control invocation and tray activation/menu access; retain keyboard-accessible equivalents and avoid focus theft during passive display.
- **FR-007**: Auto-hide must remain revealed during pointer interaction, keyboard interaction or an open menu, and provide a keyboard reveal action.
- **FR-008**: Validate configuration without overwriting user files; document defaults, ranges, migration and restart/reload behavior before implementation.
- **FR-009**: Support reduced motion, multiple outputs and logical scales 1, 1.25, 1.5 and 2. Resolve bar/volume edge ownership before implementation.
- **FR-010**: Support all connected outputs or an explicit set of named outputs; default to all connected outputs. Each output has one bar and its own workspace indicators. Define overflow behavior, shared-edge ownership and visibility timing during planning; retain the existing volume appearance and controls.
- **FR-011**: Show workspaces as white dots in the resting bar. On activation, briefly replace the activated dot with its workspace index, then restore the active dot without moving its hit target.
- **FR-012**: Draw a continuous opaque dark strip against the screen edge, with deeper animated dark areas and a feathered inner boundary that extends slightly across the nearest application window. The deeper areas must not remain fixed in place. Render the white clock in a light monospaced face over the dark core. Adapt this geometry to all four edges.
- **FR-013**: Align workspace targets to the same lattice nodes as the bar background and omit the decorative dot at each occupied node. Keep animated field contours smooth without sharp shoulders. Move a bounded local field with the pointer using the volume field's follow and retreat language; keep controls fixed and stop pointer-driven motion after settling. Reserve less than the full visual depth so the feather overlaps windows while leaving them more usable space.
- **FR-014**: Use the sound widget's feathered dark field and illumination-coupled dots for the bar's deeper areas. The hover effect must move and reshape this dark pool locally, with no pale spotlight or flat full-width gradient. A continuous dark edge remains beneath modules. Several broad ambient patches continuously breathe and drift in distributed regions, relocating only near invisibility; they are disabled by reduced motion and must avoid continuous full-width repaint. No deeper module lobe may remain static. Static, hover and ambient fields must fade to zero before the bar window boundary, without a clipped contour. Settled CPU must be measured.
- **FR-015**: Add a very small, smoothly feathered extension beneath each visible module, sized from that module's actual bounds and updated when the layout changes. The extension must breathe subtly and allow the ambient field to keep moving through it. It must never create a fixed sharp contour or move the module's controls.
- **FR-016**: Keep the accepted bar's 78-pixel default visual depth, control positions and pointer-active area. Reserve less compositor space for always-visible mode so the tiled application starts higher and the existing feathered animation can overlap it farther. Keep controls accessible and ensure the field still fades before the bar window boundary.
- **FR-017**: Slow and smooth the bar's pointer-following field so it trails mouse travel gently and settles without a jump. Preserve the existing ambient motion, sound popup timing and reduced-motion behavior.
- **FR-018**: Leave ordinary background dots immediately before and after the workspace indicators, with exactly the same size, opacity and ambient illumination as ordinary dots elsewhere. On horizontal bars, place the first actionable workspace dot one lattice step to the right of the leading background dot; on vertical bars, one step below it. Replace underlying decorative dots only at actionable workspace nodes. Render Niri's inactive, unnamed, empty trailing workspace as an ordinary decorative dot after the actionable indicators; retain active, occupied and named workspaces as indicators. Center clock and other widget content on the second lattice row from the relevant screen edge. Only the clock omits decorative dots in its text area and at one adjacent lattice position on each side along the bar; recompute that exclusion after the clock and groups move so it never creates gaps at the workspace module. Enlarge the clock text while preserving its light monospaced style.
- **FR-019**: Give the clock a slightly wider and deeper feathered dark background so its white digits remain readable. Keep the extension local to the clock, aligned after layout changes, softly transparent at its boundary, and compatible with the bar's ambient motion. Other widget backgrounds retain their accepted size.
- **FR-020**: Make the bar's ambient feathered protrusions change and relocate somewhat faster, with visibly varied positions and widths across the bar. Keep multiple distributed regions active, move each patch smoothly, and relocate only near invisibility. Preserve transparent boundaries, stationary controls and reduced-motion suppression.

### Key Entities

- **Bar profile**: Edge, visibility mode, output scope, thickness, widget groups and reveal/hide timing.
- **Widget entry**: Type, enabled state, group, ordering and type-specific preferences.
- **Widget state**: Confirmed value, availability, active interaction and menu state.

## Success Criteria

### Measurable Outcomes

- **SC-001**: All five widget types remain readable and operable in each of four orientations, with no rotated text or overlapping hit targets.
- **SC-002**: Enable/disable/reorder trials reproduce the configured grouping and order after applying configuration.
- **SC-003**: Twenty auto-hide reveal/dismiss cycles per tested orientation preserve open-menu interaction and leave no hidden input region beyond the documented reveal strip.
- **SC-004**: Normal/reduced-motion captures on four representative backgrounds demonstrate feathered boundaries and stable controls.
- **SC-005**: Automated geometry coverage includes four scales; physical multi-output acceptance is recorded when hardware is available and remains explicitly unverified until then.
- **SC-006**: Captures on four edges show the unbroken dark edge and animated dark areas with a transparent fade beyond the reserved area; workspace switching shows a temporary number and returns to a dot within one second.
- **SC-007**: Grid overlays show workspace centers exactly on background lattice coordinates with no doubled dots. Pointer entry, travel, and departure move only the bounded light pool, while module contours stay smooth and controls stay fixed. The reserved area is smaller than the visual field on all four edges.

## Assumptions

- Proposed initial placement is top. Output selection defaults to all connected outputs and can be restricted to named outputs.
- First implementation uses built-in configurable widgets; arbitrary executable plugins and a settings application are outside this slice.
- The clock defaults to local time with minute precision; battery presence is optional.
- Both visibility modes are supported; the user's selected default is always-visible.
- The bar is a newly requested persistent surface; its always-visible mode extends the project's prior emphasis on transient surfaces and needs explicit reconciliation in product documentation during planning.
- Existing volume work stays preserved. Hardware testing may be deferred at the user's request, but is not treated as passed.
