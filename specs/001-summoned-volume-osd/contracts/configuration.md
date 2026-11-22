# Configuration v1

Proposed file: `$XDG_CONFIG_HOME/dot-shell/config.json`, falling back to `$HOME/.config/dot-shell/config.json`. Read through Quickshell file I/O at startup; restart to apply changes for this slice. Missing file uses defaults. Never write defaults over user content. Malformed JSON or unsupported `schemaVersion` uses defaults with a diagnostic; invalid fields fall back individually. Unknown fields warn and are ignored. No settings application is included.

All geometry uses logical pixels. Values must be finite, timings integer milliseconds.

| Field | Default | Accepted values |
| --- | --- | --- |
| `schemaVersion` | 1 | 1 |
| `field.width`, `field.height` | 180, 540 | 160–800, 300–600 |
| `field.spacing` | 18 | 8–48 |
| `field.dotRadius` | 1.5 | 0.5–4; diameter less than spacing |
| `field.feather` | 96 | 16–120; less than the minimum elliptical radius (visible field width or half its height) |
| `field.backdropOpacity` | 1 | 0–1; permits an opaque dark center |
| `field.backdropColor` | `#181818` | Opaque RGB hex; opacity controlled separately |
| `placement.anchor` | `right-center` | `right-center`, `left-center`, `top-center`, `bottom-center`, `center` |
| `placement.output` | empty string | Output name; empty uses first available screen in stable enumeration order |
| `placement.margin` | 0 | 0–128; right-edge invocation always meets the physical edge |
| `edge.enabled` | true | Boolean |
| `edge.dwellMs` | 200 | 50–1000 |
| `edge.width` | 1 | 1–4 |
| `motion.reduced` | false | Boolean; explicit preference for this slice |
| `timing.emergeMs`, `timing.traceMs`, `timing.constructMs` | 650, 350, 100 | Each 0–1000 |
| `timing.retractMs` | 250 | 0–1000 |
| `timing.levelMs` | 180 | 0–1000 |
| `timing.idleMs` | 2000 | 250–10000 |
| `volume.stepPercent` | 5 | Integer 1–25 |
| `volume.maxPercent` | 100 | Integer 1–100; amplification is outside this slice |
| `triggers.externalAudioChanges` | true | Boolean; false disables automatic summoning from observed audio changes |
| `typography.family` | `FiraCode Nerd Font` | String; system font fallback applies when unavailable |
| `typography.pixelSize` | 22 | 14–32 |
| `typography.weight` | 300 | Integer 100–500 |
| `typography.italic` | false | Boolean |

Apply relationship validation after individual fields; reject incompatible geometry as a group and use field defaults. Cap field population at 2048 nodes. Geometry must leave at least three grid nodes in the vertical chain and room for its value and mute control. Fit geometry to smaller outputs while preserving feather and usable controls; below minimum usable geometry report unsupported placement instead of clipping controls. Edge invocation selects its output and right-center anchor at zero right margin regardless of automatic-trigger placement. While hovered or dragging, keep that placement stable; output loss cancels the drag and repositions safely.

Reduced motion replaces travel with a maximum 100 ms fade in/out. The mute dot is filled white when unmuted and grey with a small hollow center when muted; a larger invisible hit target preserves the minimal appearance. A cached Canvas backdrop uses a continuous smooth falloff to zero; no custom shader, blur or wallpaper sampling is required for this slice.

For the right-edge visual, render an elongated elliptical dark field whose conceptual center meets the physical edge and whose other half is clipped offscreen. Fade and a restrained horizontal scale bloom create emergence without translating the surface. The vertical chain uses one field column, with every node and connected segment aligned to that grid. Its connected portion ends at the greatest reached node; the current dot is white, other nodes grey. The percentage label remains exact even between node levels. These defaults replace the unapproved horizontal first preview before any public v1 release.

Decorative dots follow the backdrop's elliptical alpha: strongest in the opaque center, fading toward its transparent edges, and absent outside it. Reached grey chain nodes are hidden under the connected line; one white endpoint follows its smoothly animated extent and unreached nodes stay grey. The visible field expands leftward from a narrow initial scale at the right edge, over the configured emergence duration. The font is a light Fira Code-style family; italic is optional and no font package is installed automatically.

Edge input necessarily owns its narrow input strip; disabling `edge.enabled` removes it. The visible OSD owns pointer input over its local field so hover can pause dismissal. Clicks outside its bounded field and sensor remain with underlying content. Shared-output-edge crossing and fractional-scale reachability require live acceptance testing; the contract makes no global pointer observation claim.

If measured external-change reaction feels delayed, use `triggers.externalAudioChanges: false` and the shell's volume/mute bindings. State subscriptions remain active for accuracy; only their automatic summon side effect is disabled. Shell actions summon immediately when accepted and display confirmed state while waiting for audio confirmation. This setting does not disable the independently configurable edge trigger.
