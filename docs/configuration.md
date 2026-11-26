# Dot Shell configuration and actions

The first runtime is under development. Start a source checkout with `qs -p src/shell.qml`; stop only that instance with `qs -p src/shell.qml kill`.

User preferences live in `$XDG_CONFIG_HOME/dot-shell/config.json` (normally `~/.config/dot-shell/config.json`). Restart to apply changes. Missing files use defaults; malformed files and invalid values produce a diagnostic and safe defaults. The shell never writes over your configuration.

```json
{
  "schemaVersion": 3,
  "edge": { "enabled": true, "dwellMs": 100, "side": "right", "outputs": {} },
  "timing": { "idleMs": 2000 },
  "motion": { "reduced": false },
  "triggers": { "externalAudioChanges": true }
}
```

The volume keys, defaults, geometry rules and accepted ranges are in [the volume configuration contract](../specs/001-summoned-volume-osd/contracts/configuration.md). Valid v1 and v2 files are migrated in memory and continue to work; Dot Shell never rewrites them. The edge sensor owns a configurable narrow input strip in the middle third of each output's selected edge. Top and bottom thirds remain input-transparent to this feature. Disabling the edge trigger removes its input regions. A visible OSD owns input only over its local field and does not take keyboard focus.

The bar defaults to the top edge, always visible, on all connected outputs. To change it, add a `bar` group to schema version 3. `edge` accepts `top`, `left`, `bottom` or `right`; `visibility` accepts `always` or `auto`; `outputs` is `"all"` or a list of exact output names. In auto mode, a 2-pixel edge strip reveals the bar after `revealMs` (50–500 ms), and it hides after `hideMs` (100–3000 ms). In always-visible mode, the default `thickness` of 48 gives the bar a 78-pixel-deep feathered field and 36 pixels for controls and pointer input, while reserving only 24 logical pixels from the compositor. The compositor reservation is `max(24, thickness - 24, field.spacing)`; the control/input depth remains `max(32, thickness - 12, field.spacing)`. Changes apply after restart.

The edge-facing strip stays dark along the whole output. Four broad dotted areas continuously breathe and drift over nearby windows; their gradients reach full transparency before the bar's visual boundary. They relocate at staggered intervals of about 3.3–5.8 seconds, varying their positions and widths across separate parts of the bar while nearly invisible, so no deep extension stays fixed. A smaller, softly breathing accent below each visible widget follows that widget's actual width and extends about eight logical pixels beyond the base fade at default settings. The clock accent extends one grid step farther along the bar and half a step inward for readability, with the same soft boundary. The workspace group starts with an ordinary background dot, matching the ordinary dot after the actionable workspaces in size and brightness. Actionable workspace dots start one 18-pixel grid step later and replace background dots at their nodes. Niri's inactive, unnamed, empty trailing workspace appears as a regular background dot on the right rather than another workspace indicator. The active dot is brighter; activation shows its index for about 900 ms before returning to a dot. Clock and other widget content center on the second dot row from the screen edge. Only the clock clears nearby decorative dots, including a dot on each side, so its digits remain readable without gaps around other widgets. The clock uses 16-pixel light monospaced text, preferring FiraCode Nerd Font Mono Light when installed. A dark dotted field follows the pointer and retreats on departure. Its follow takes 420 ms by default, scaled from `motion.followMs` within 420–650 ms; setting that value to zero keeps following immediate. Controls stay fixed. Reduced motion disables ambient movement and uses a short stationary pointer fade.

```json
{
  "schemaVersion": 3,
  "bar": {
    "edge": "top", "visibility": "always", "outputs": "all",
    "thickness": 48, "revealMs": 100, "hideMs": 500,
    "widgets": [
      { "type": "workspaces", "group": "start", "enabled": true, "priority": 100 },
      { "type": "clock", "group": "center", "enabled": true, "priority": 80 },
      { "type": "volume", "group": "end", "enabled": true, "priority": 70 },
      { "type": "battery", "group": "end", "enabled": true, "priority": 60 },
      { "type": "tray", "group": "end", "enabled": true, "priority": 50 }
    ]
  }
}
```

Disable a widget with `enabled: false`; reorder entries within a group by changing their array order. The battery widget hides when no laptop battery is present. To reveal an auto-hidden bar from a keyboard binding, call `dot-shell ipc call bar_v1 reveal ""` for all outputs or supply an exact output name. The bar action contract is [documented here](../specs/002-configurable-dot-bar/contracts/actions.md).

The default is the requested right/right behavior: every connected output uses its right edge without naming private outputs. Obtain public output names with `niri msg outputs` only when you want overrides. For independent sides:

```json
{
  "schemaVersion": 3,
  "edge": {
    "side": "right",
    "outputs": {
      "eDP-1": { "side": "left" },
      "DP-1": { "side": "right" }
    }
  }
}
```

To copy one output's side to another, use `copyOf` with `mirror: false`; use `mirror: true` to flip left and right. This copies configuration and never duplicates the visible OSD:

```json
{
  "schemaVersion": 3,
  "edge": {
    "outputs": {
      "eDP-1": { "side": "right" },
      "DP-1": { "copyOf": "eDP-1", "mirror": true }
    }
  }
}
```

Automatic audio changes, volume actions and `show` use Niri's focused output while the OSD is dormant. On an empty workspace, selecting the pointer output requires Niri focus-follows-mouse. Once visible, the OSD remains on its selected output until fully dismissed. Edge dwell always selects the output whose edge was reached. If Niri routing is unavailable, `placement.fallbackOutput` is tried before the first available output. Dot Shell reads the event stream but never reads or edits your Niri configuration.

The current Niri 26.04 preview lets the dark patch follow your cursor slightly
inside that fixed field. Leaving starts a shrinking fade with a short drift in
the last outward direction; it cannot observe your actual cursor outside.
Returning during retreat restores it. Keyboard-only appearances use the idle
delay. Tune `motion.followRange` (36), `followMs` (120), `departureDrift` (32)
and `departureScale` (0.3), or use reduced motion for a short stationary fade.

The installed CLI supports these [versioned audio actions](../specs/001-summoned-volume-osd/contracts/actions.md):

```sh
dot-shell ipc call volume_v1 show
dot-shell ipc call volume_v1 increase
dot-shell ipc call volume_v1 decrease
dot-shell ipc call volume_v1 toggleMute
dot-shell ipc call volume_v1 setPercent 40
dot-shell ipc call volume_v1 state
```

For a source checkout use `qs -p src/shell.qml ipc call -- volume_v1 show` and the same syntax for other actions. The `--` separator is necessary because Quickshell otherwise interprets `show` as its own CLI subcommand. `dot-shell` adds this separator automatically.

Actions return JSON. `accepted` means the request was dispatched, not that audio state has been confirmed. The display follows observed audio state; confirmation failures are indicated rather than showing the requested value as successful. Queries preserve above-cap observed volume; the shell itself does not amplify above its configured cap. Volume changes do not implicitly unmute.

If external audio-change summoning feels slow, set `triggers.externalAudioChanges` to false and bind Niri keys to the shell's increase/decrease/toggleMute actions. Those actions summon directly, while observation still keeps displayed values accurate. You can optionally bind `show`, but no key is assigned by default. No dismissal binding is needed.

Copy desired binding examples from the action contract into your own Niri configuration. Dot Shell does not edit or replace those bindings automatically.
