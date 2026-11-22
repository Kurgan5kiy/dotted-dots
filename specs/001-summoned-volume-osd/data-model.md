# Data and State Model

Canonical field names below apply to implementation and task citations; QML property names may be mapped explicitly to these model names. Configuration key ranges remain authoritative in [configuration.md](contracts/configuration.md).

| Field | Definition and constraints |
| --- | --- |
| `AudioOutput.sinkId` | Current default sink identity, null when no sink is known. A change invalidates pending writes. |
| `AudioOutput.available` | Boolean; true only when the sink's tracked audio properties are usable. |
| `AudioOutput.percent` | Confirmed finite nonnegative real percentage, null when unavailable. Preserve observed values above the adjustment cap; never clamp the displayed value. |
| `AudioOutput.muted` | Confirmed Boolean, null when unavailable; distinct from zero volume. |
| `AudioOutput.pending` | Null or latest requested volume/mute state, sink identity and 1000 ms deadline. Accept volume confirmation within 0.5 percentage points; mute must match exactly. Expiry reports failure; output change cancels the request. |
| `Preferences.values` | Validated configuration object; every key, default, range and relationship is defined in contracts/configuration.md. Invalid fields use documented defaults with a diagnostic. |
| `Osd.phase` | One of dormant, emerging, tracing, constructing, interactive, retracting. Reduced motion substitutes fades. New events during retraction restore the same visible instance; do not duplicate it. |
| `Interaction.hovered` | Boolean; pointer over local OSD field pauses idle dismissal. Leaving starts a fresh idle interval unless dragging. |
| `Interaction.dragging` | Boolean; active drag pauses timeout and fixes control placement until release or output loss. |
| `Interaction.edgeState` | One of armed, dwelling, latched. Enter begins dwell, leave cancels dwell/rearms, expiry summons and latches. After dismissal while still at the edge, remain latched until leave. Disabled sensors cannot trigger. |
| `OutputSelection.screenId` | Selected connected output identity or null. Edge invocation selects its output; automatic/show invocation uses configured output or first available fallback unless interaction has fixed placement. Recompute on output loss and scale changes. |

Audio-state observation remains active in both summon modes. `Preferences.values.triggers.externalAudioChanges` controls only whether external state updates summon a dormant OSD. Shell actions summon directly; the edge trigger independently follows `Preferences.values.edge.enabled`.
