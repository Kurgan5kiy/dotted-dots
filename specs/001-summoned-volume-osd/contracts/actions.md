# Volume Actions v1

Proposed implementation contract; these commands do not exist yet. Existing CLI forwarding remains the public entry point. Register a typed Quickshell IPC target named `volume_v1`.

| Invocation | Behavior |
| --- | --- |
| `dot-shell ipc call volume_v1 show` | Display current state without changing audio or taking focus. No shortcut is assigned by default. |
| `dot-shell ipc call volume_v1 increase` | Increase by configured percentage-point step. |
| `dot-shell ipc call volume_v1 decrease` | Decrease by configured percentage-point step. |
| `dot-shell ipc call volume_v1 setPercent 40` | Set an integer percentage within configured limits. |
| `dot-shell ipc call volume_v1 toggleMute` | Toggle default-output mute. |
| `dot-shell ipc call volume_v1 state` | Return confirmed state as a JSON string. |

Action functions return a JSON string with `version: 1`, `status` and optional `error`. Status is `accepted` or `rejected`; acceptance means a request was dispatched, not that the service confirmed it. Reject non-finite/out-of-range values with `invalid_argument`, unavailable output with `unavailable`. `show` may display unavailable state without changing audio. Query returns `version`, `available`, `percent` and `muted`; percent and muted are null when unavailable. Transport/process failure is reported by `qs`; callers must examine the returned status for domain failure rather than relying on process exit alone.

Only confirmed observed audio state drives the display. A write is pending until observed or a 1000 ms confirmation deadline expires; expiry presents failure and keeps the last confirmed value. On output switch, invalidate pending writes rather than applying them to another device. Clamp increase/decrease to configured bounds, but reject an out-of-range absolute request. Changing volume does not implicitly unmute. Repeated writes use the latest requested value for accumulation while confirmation still comes from the service.

Above-cap observed state is preserved by `state` and the value label; the slider thumb stays at its maximum. Showing or observing never writes audio. If already at or above the cap, `increase` is an accepted no-op and may summon the OSD. `decrease` requests `max(0, min(cap, current - step))`; an absolute request above the cap is rejected. The shell never writes an amplified value. Confirmation tolerance and pending-state fields follow data-model.md `AudioOutput.pending`.

Accepted volume/mute actions summon the OSD directly, independently of the external-change trigger setting. This permits binding-driven operation if passive audio-change summoning is too delayed. Keep state observation for accuracy, and never show the requested value as confirmed until observed.

## User-owned Niri binding examples

```kdl
binds {
    XF86AudioRaiseVolume { spawn "dot-shell" "ipc" "call" "volume_v1" "increase"; }
    XF86AudioLowerVolume { spawn "dot-shell" "ipc" "call" "volume_v1" "decrease"; }
    XF86AudioMute { spawn "dot-shell" "ipc" "call" "volume_v1" "toggleMute"; }
    // Optional: choose your own key for the show action.
}
```

Examples are documentation, never installed into the user's Niri configuration. Existing bindings using other audio tools also work through state observation. Do not install a dismissal binding. Target version changes on incompatible contract changes.
