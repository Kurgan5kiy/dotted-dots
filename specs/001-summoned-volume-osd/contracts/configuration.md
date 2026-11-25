# Configuration v2

Proposed file: `$XDG_CONFIG_HOME/dot-shell/config.json`, falling back to `$HOME/.config/dot-shell/config.json`. Read through Quickshell file I/O at startup; restart to apply changes for this slice. Missing files use defaults. Never write defaults or migrations over user content. Schema v2 is canonical. Valid schema-v1 input is migrated in memory as described below; malformed JSON or unsupported versions use v2 defaults with a diagnostic. Invalid fields fall back individually. Unknown fields warn and are ignored. No settings application is included.

All geometry uses logical pixels. Values must be finite, timings integer milliseconds.

| Field | Default | Accepted values |
| --- | --- | --- |
| `schemaVersion` | 2 | 1 or 2; v1 is migrated in memory, v2 is canonical |
| `field.width`, `field.height` | 180, 540 | 160–800, 300–600 |
| `field.spacing` | 18 | 8–48 |
| `field.dotRadius` | 1.5 | 0.5–4; diameter less than spacing |
| `field.lineWidth` | 2 | 0.5–4 |
| `field.feather` | 96 | 16–120; less than the minimum elliptical radius (visible field width or half its height) |
| `field.backdropOpacity` | 1 | 0–1; permits an opaque dark center |
| `field.backdropColor` | `#181818` | Opaque RGB hex; opacity controlled separately |
| `placement.fallbackOutput` | empty string | Output name used only when focused-output routing is unavailable; empty uses first available screen in stable enumeration order |
| `placement.margin` | 0 | 0–128; edge invocation always meets its configured physical edge |
| `edge.enabled` | true | Boolean |
| `edge.dwellMs` | 100 | 50–1000 |
| `edge.width` | 1 | 1–4 |
| `edge.side` | `right` | `left` or `right`; default for outputs without a valid profile |
| `edge.outputs` | empty object | At most 32 profiles keyed by exact output name; profile contract below |
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

Apply relationship validation after individual fields; reject incompatible geometry as a group and use field defaults. Cap field population at 2048 nodes. Geometry must leave at least three grid nodes in the vertical chain and room for its value and mute control. Fit geometry to smaller outputs while preserving feather and usable controls; below minimum usable geometry report unsupported placement instead of clipping controls. Edge invocation selects its output and resolved left-center or right-center anchor at zero edge margin. Non-pointer invocation uses that output's same resolved side. Once visible, keep output and side stable through retraction; output loss cancels a drag and repositions safely.

## Per-output trigger profiles

`edge.outputs` keys are exact output names of 1–128 characters. Each value must
use exactly one of these forms:

```json
{
  "eDP-1": { "side": "right" },
  "DP-1": { "copyOf": "eDP-1", "mirror": false }
}
```

- An explicit profile contains only `side`, with value `left` or `right`.
- A copy profile contains `copyOf` and Boolean `mirror`. `mirror: false` uses
  the source side; `mirror: true` flips left and right.
- A profile cannot copy itself. Copy chains and cycles are rejected: the named
  source must have an explicit valid side.
- Missing, malformed, unresolved or over-limit profiles fall back individually
  to `edge.side` with a diagnostic; they do not invalidate other outputs.
- Profiles for disconnected outputs remain valid but inactive until the exact
  output name returns.
- Resolving a copy changes configuration only. It never creates a second OSD.

With the default `edge.side: "right"`, any two outputs use the requested
right/right profile without recording private output names. Users may add
explicit profiles after obtaining their public compositor output names.

Each output's logical vertical edge is split into thirds. Top and bottom are
`floor(height / 3)` logical pixels; the middle receives the zero-to-two-pixel
remainder. Only a narrow sensor over the middle third belongs to volume. This
feature creates no window or input region in the reserved top and bottom
thirds. Quickshell 0.3.2 does not expose a dependable compositor work area, so
the initial contract uses logical output height and does not claim subtraction
of third-party exclusive zones.

## Schema-v1 migration

Schema v1 is accepted and converted in memory without changing the user's file:

- `placement.output` becomes `placement.fallbackOutput`.
- `placement.anchor: "left-center"` becomes `edge.side: "left"`.
- `placement.anchor: "right-center"` or an absent anchor becomes
  `edge.side: "right"`.
- The former `top-center`, `bottom-center` and `center` anchors have no v2
  volume-slot equivalent; they fall back to `right` with a migration warning.
- Existing valid geometry, motion, timing, volume, trigger and typography
  values retain their prior meaning.

Emit one migration diagnostic plus any field-specific warnings. A schema-v1
file continues to work but documentation examples use v2.

Reduced motion replaces travel with a maximum 100 ms fade in/out. The mute dot is solid white at 8 logical pixels when unmuted and solid grey at 6 when muted; size supplies the non-colour distinction. Its colour and size transition over 120 ms, or directly with reduced motion. A fixed 32-logical-pixel invisible hit target preserves the minimal appearance. A cached Canvas backdrop uses a continuous smooth falloff to zero; no custom shader, blur or wallpaper sampling is required for this slice.

For either configured side, move the dark field and its attached gradient inward to the settled center slot. Keyboard-only dismissal reverses that travel; pointer departure uses the bounded drift and shrink described below. Side-aware geometry changes motion direction and anchor without mirroring text or controls. Three cached soft layers drift and change proportions independently by small amounts to make the boundary feel fluid. The motion settles in a bounded interval and can reawaken on volume activity; reduced motion disables travel and deformation. Dot and control positions remain fixed, while dot and control alpha follow local illumination. The current line extent is initialized before appearance, without a fill from zero.

These defaults are the accepted visual theme. Preserve the broad feathering,
calligraphic values and minimal solid mute dot. Contrast measurements document
its limits over bright content; no shadow, card or extra opaque backing is
automatically added to meet the superseded fixed contrast thresholds.

Decorative dots follow the backdrop's elliptical alpha: strongest in the opaque center, fading toward its transparent edges, and absent outside it. Grey chain node opacity follows the animated endpoint's actual position, never the target or an integer ceiling, so nodes disappear and return as the endpoint covers and uncovers them. Normal-motion value changes slide/crossfade the old and new numerals, retargeting to the latest confirmed value. Reduced motion updates directly. Allura is bundled with its SIL Open Font License and provenance; no system font is installed. The unreleased `traceMs` and `constructMs` settings are removed because appearance no longer includes an independent fill/construct stage.

Edge input necessarily owns its narrow middle-third input strip; disabling `edge.enabled` removes it. The visible OSD owns pointer input over its local field so hover can pause dismissal. Clicks in reserved top/bottom thirds and outside the OSD remain with underlying content. Shared-output-edge crossing and fractional-scale reachability require live acceptance testing; the contract makes no global pointer observation claim.

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

Dormant non-pointer summons use focused-output state supplied by the Niri
adapter, then `placement.fallbackOutput`, then stable first available output.
On Niri 26.04, empty-workspace pointer fallback requires focus-follows-mouse and
must pass the documented live acceptance trials. Once the OSD is visible, focus
changes and other sensors cannot move or duplicate it until full dismissal.
