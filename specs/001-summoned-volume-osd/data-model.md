# Data and State Model

Canonical field names below apply to implementation and task citations; QML property names may be mapped explicitly to these model names. Configuration key ranges remain authoritative in [configuration.md](contracts/configuration.md).

| Field | Definition and constraints |
| --- | --- |
| `AudioOutput.sinkId` | Current default sink identity, null when no sink is known. A change invalidates pending writes. |
| `AudioOutput.available` | Boolean; true only when the sink's tracked audio properties are usable. |
| `AudioOutput.percent` | Confirmed finite nonnegative real percentage, null when unavailable. Preserve observed values above the adjustment cap; never clamp the displayed value. |
| `AudioOutput.muted` | Confirmed Boolean, null when unavailable; distinct from zero volume. |
| `AudioOutput.pending` | Null or latest requested volume/mute state, sink identity and 1000 ms deadline. Accept volume confirmation within 0.5 percentage points; mute must match exactly. Expiry reports failure; output change cancels the request. |
| `Preferences.values` | Validated schema-v2 configuration object; every key, default, range and relationship is defined in contracts/configuration.md. Valid schema-v1 input is migrated in memory without rewriting the file. Invalid fields use documented defaults with a diagnostic. |
| `Osd.phase` | One of dormant, emerging, interactive, retracting. The confirmed state is initialized during emergence; there is no post-appearance fill stage. Reduced motion substitutes short fades. New events during retraction restore the same visible instance; do not duplicate it. |
| `Interaction.hovered` | Boolean; pointer over the fixed local OSD field pauses idle dismissal. Leaving starts retreat unless dragging; returning during retreat restores interaction. |
| `Interaction.dragging` | Boolean; active drag pauses timeout and fixes control placement until release or output loss. |
| `Interaction.pointerLight` | Bounded local follow offsets, last in-surface pointer position and outward delta. Niri 26.04 preview continues only a finite exit-direction drift, with no claimed outside coordinates; shared transformed field alpha controls local illumination. Reduced motion disables travel and shrink. |
| `Interaction.edgeState` | Per-output value, one of armed, dwelling, latched. Entering that output's middle-third sensor begins dwell; leaving cancels dwell/rearms; expiry summons and latches. After dismissal while still in the middle zone, remain latched until leave. Disabled sensors and reserved top/bottom zones cannot trigger. |
| `EdgeTriggerProfile.outputId` | Exact nonempty output name, at most 128 characters. Profiles for disconnected outputs remain stored but inactive. At most 32 profiles are accepted. |
| `EdgeTriggerProfile.side` | Explicit `left` or `right`, mutually exclusive with `copyOf`; omitted only for a copy profile. |
| `EdgeTriggerProfile.copyOf` | Exact nonempty source output name, at most 128 characters; distinct from `outputId`, one hop only, and mutually exclusive with `side`. The source must resolve to an explicit side. |
| `EdgeTriggerProfile.mirror` | Boolean allowed only with `copyOf`; false copies the source side, true maps left to right and right to left. Copying configuration never creates another OSD. |
| `EdgeZone.bounds` | Logical vertical bounds derived from output height: top and bottom are `floor(height / 3)` pixels each and middle receives the remainder. Only the middle bounds own a volume sensor; top and bottom are reserved and input-transparent to this feature. |
| `NiriFocusState.outputId` | Focused output name from the Niri event stream, or null before a valid initial snapshot or after invalidation. On the validated focus-follows-mouse setup it also represents the pointer output on an empty workspace. |
| `NiriFocusState.ready` | Boolean; true only after a valid initial workspace/output snapshot. Stream loss makes the state unavailable until bounded recovery. |
| `NiriFocusState.windowFocused` | Boolean derived from Niri window-focus state; used for diagnostics and acceptance evidence, not to change a visible OSD's placement. |
| `NiriFocusState.diagnostic` | Null or a bounded non-secret reason that focus routing is unavailable or degraded. Unknown event variants are ignored rather than copied into diagnostics. |
| `OutputSelection.screenId` | Selected connected output identity or null. A dormant edge invocation selects its sensor output. A dormant non-pointer invocation selects `NiriFocusState.outputId`, then `Preferences.values.placement.fallbackOutput`, then the first available output. Once visible, selection remains fixed through emergence, interaction and retraction. Recompute only after dormancy or selected-output loss. |
| `OutputSelection.side` | Resolved `left` or `right` from the selected output's valid edge profile or global default. It determines the center anchor and inward animation direction without mirroring text or controls. |
| `OutputSelection.locked` | Boolean; true from the first visible phase through retraction. While true, focus, pointer fallback and other edge sensors cannot relocate or duplicate the OSD. Output loss is the only forced fallback and cancels an active drag. |

Audio-state observation remains active in both summon modes. `Preferences.values.triggers.externalAudioChanges` controls only whether external state updates summon a dormant OSD. Shell actions summon directly; the edge trigger independently follows `Preferences.values.edge.enabled`.

The Niri adapter is authoritative only on the initial Niri 26.04 baseline and
must not be imported by visual primitives. Niri 26.04 has no pointer-output
IPC; empty-workspace pointer fallback therefore requires focus-follows-mouse
and the live acceptance gate documented in quickstart.md.
