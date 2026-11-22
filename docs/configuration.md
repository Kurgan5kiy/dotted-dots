# Volume OSD configuration and actions

The first runtime is under development. Start a source checkout with `qs -p src/shell.qml`; stop only that instance with `qs -p src/shell.qml kill`.

User preferences live in `$XDG_CONFIG_HOME/dot-shell/config.json` (normally `~/.config/dot-shell/config.json`). Restart to apply changes. Missing files use defaults; malformed files and invalid values produce a diagnostic and safe defaults. The shell never writes over your configuration.

```json
{
  "schemaVersion": 1,
  "edge": { "enabled": true, "dwellMs": 200 },
  "timing": { "idleMs": 2000 },
  "motion": { "reduced": false },
  "triggers": { "externalAudioChanges": true }
}
```

The complete v1 keys, defaults, geometry rules and accepted ranges are in [the configuration contract](../specs/001-summoned-volume-osd/contracts/configuration.md). The edge sensor owns a configurable narrow input strip; disabling it removes that input region. A visible OSD owns input over its local field. It does not take keyboard focus.

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
