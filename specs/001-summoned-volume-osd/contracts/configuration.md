# Configuration v1

Proposed file: `$XDG_CONFIG_HOME/dot-shell/config.json`, falling back to `$HOME/.config/dot-shell/config.json`. Read through Quickshell file I/O at startup; restart to apply changes for this slice. Missing file uses defaults. Never write defaults over user content. Malformed JSON or unsupported `schemaVersion` uses defaults with a diagnostic; invalid fields fall back individually. Unknown fields warn and are ignored. No settings application is included.

All geometry uses logical pixels. Values must be finite, timings integer milliseconds.

| Field | Default | Accepted values |
| --- | --- | --- |
| `schemaVersion` | 1 | 1 |
| `field.width`, `field.height` | 180, 540 | 160–800, 300–600 |
| `field.spacing` | 18 | 8–48 |
| `field.dotRadius` | 1.5 | 0.5–4; diameter less than spacing |
| `field.lineWidth` | 2 | 0.5–4 |
| `field.feather` | 96 | 16–120; less than the minimum elliptical radius (visible field width or half its height) |
| `field.backdropOpacity` | 1 | 0–1; permits an opaque dark center |
| `field.backdropColor` | `#181818` | Opaque RGB hex; opacity controlled separately |
| `placement.anchor` | `right-center` | `right-center`, `left-center`, `top-center`, `bottom-center`, `center` |
| `placement.output` | empty string | Output name; empty uses first available screen in stable enumeration order |
| `placement.margin` | 0 | 0–128; right-edge invocation always meets the physical edge |
| `edge.enabled` | true | Boolean |
| `edge.dwellMs` | 100 | 50–1000 |
| `edge.width` | 1 | 1–4 |
| `motion.reduced` | false | Boolean; explicit preference for this slice |
| `motion.liquidStrength` | 1 | 0–2; zero disables the gentle field deformation |
| `motion.liquidMs` | 6000 | 1000–10000; bounded settling motion per appearance/activity |
| `motion.followRange` | 36 | 0–48; maximum local pointer-follow offset per axis |
| `motion.followMs` | 120 | 0–500; pointer-follow smoothing |
| `motion.departureDrift` | 32 | 0–64; finite exit-direction drift without a global cursor feed |
| `motion.departureScale` | 0.3 | 0.1–1; final field scale before fading completely |
| `timing.emergeMs` | 400 | 0–1000 |
| `timing.retractMs` | 650 | 0–1000 |
| `timing.levelMs` | 180 | 0–1000 |
| `timing.numberMs` | 180 | 0–1000 |
| `timing.idleMs` | 2000 | 250–10000 |
| `volume.stepPercent` | 5 | Integer 1–25 |
| `volume.maxPercent` | 100 | Integer 1–100; amplification is outside this slice |
| `triggers.externalAudioChanges` | true | Boolean; false disables automatic summoning from observed audio changes |
| `typography.family` | `Allura` | Bundled OFL-1.1 font; other family names use system lookup |
| `typography.pixelSize` | 30 | 14–40 |
| `typography.weight` | 300 | Integer 100–500 |
| `typography.italic` | false | Boolean |
| `typography.travel` | 12 | 0–32; numeral travel in logical pixels |

Apply relationship validation after individual fields; reject incompatible geometry as a group and use field defaults. Cap field population at 2048 nodes. Geometry must leave at least three grid nodes in the vertical chain and room for its value and mute control. Fit geometry to smaller outputs while preserving feather and usable controls; below minimum usable geometry report unsupported placement instead of clipping controls. Edge invocation selects its output and right-center anchor at zero right margin regardless of automatic-trigger placement. While hovered or dragging, keep that placement stable; output loss cancels the drag and repositions safely.

Reduced motion replaces travel with a maximum 100 ms fade in/out. The mute dot is solid white at 8 logical pixels when unmuted and solid grey at 6 when muted; size supplies the non-colour distinction. Its colour and size transition over 120 ms, or directly with reduced motion. A fixed 32-logical-pixel invisible hit target preserves the minimal appearance. A cached Canvas backdrop uses a continuous smooth falloff to zero; no custom shader, blur or wallpaper sampling is required for this slice.

For the right-edge visual, move the dark field and its attached gradient together from outside the right edge to the settled position, reversing on dismissal. Three cached soft layers drift and change proportions independently by small amounts to make the boundary feel fluid. The motion settles in a bounded interval and can reawaken on volume activity; reduced motion disables travel and deformation. Dot and control positions remain fixed, while dot alpha follows the moving composite backdrop. The current line extent is initialized before appearance, without a fill from zero. These defaults replace the unapproved first previews before any public v1 release; `motion.proximitySpread` is superseded by liquid motion settings.

Decorative dots follow the backdrop's elliptical alpha: strongest in the opaque center, fading toward its transparent edges, and absent outside it. Grey chain node opacity follows the animated endpoint's actual position, never the target or an integer ceiling, so nodes disappear and return as the endpoint covers and uncovers them. Normal-motion value changes slide/crossfade the old and new numerals, retargeting to the latest confirmed value. Reduced motion updates directly. Allura is bundled with its SIL Open Font License and provenance; no system font is installed. The unreleased `traceMs` and `constructMs` settings are removed because appearance no longer includes an independent fill/construct stage.

Edge input necessarily owns its narrow input strip; disabling `edge.enabled` removes it. The visible OSD owns pointer input over its local field so hover can pause dismissal. Clicks outside its bounded field and sensor remain with underlying content. Shared-output-edge crossing and fractional-scale reachability require live acceptance testing; the contract makes no global pointer observation claim.

The Niri 26.04 preview follows surface-local pointer movement within
`motion.followRange`. On leaving, it starts retreat immediately and continues
only `motion.departureDrift` in the last outward direction; this is an
approximation, not actual outside tracking. It shrinks toward
`motion.departureScale` and fades over `timing.retractMs`. Keyboard-only
summoning retains `timing.idleMs`. Re-entry reverses retreat. Controls and the
input region remain stationary; their local brightness follows the field.
Reduced motion uses a short fade without follow travel, drift or shrink.

Unreached chain dots use light grey `#b8b8b8` to distinguish the available
volume path from the faint decorative grid. The current-level endpoint remains
white, and the chain still follows local field illumination.

If measured external-change reaction feels delayed, use `triggers.externalAudioChanges: false` and the shell's volume/mute bindings. State subscriptions remain active for accuracy; only their automatic summon side effect is disabled. Shell actions summon immediately when accepted and display confirmed state while waiting for audio confirmation. This setting does not disable the independently configurable edge trigger.
