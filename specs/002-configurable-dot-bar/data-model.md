# Data Model: Configurable Dot Bar

| Entity | Fields and rules |
| --- | --- |
| BarProfile | `edge`: top/left/bottom/right; `visibility`: always/auto; `outputs`: all or up to 32 exact unique output names; `thickness`: 32–96 logical pixels; `revealMs`: 50–500; `hideMs`: 100–3000; `widgets`: ordered entries. Defaults top/always/all/48/100/500. |
| WidgetEntry | `type`: workspaces/clock/volume/battery/tray; `group`: start/center/end; `enabled`: boolean; `priority`: integer for overflow. Each type occurs at most once; array order applies within group. |
| BarInstance | Connected `outputId`, resolved `edge`, `orientation`, `availableExtent`, `overflowEntries` and visibility phase. One per selected connected output. |
| RevealState | `phase`: hidden, revealing, visible or hiding. Pointer/focus/menu holds visible; expiry hides only when all holds clear. Reduced motion uses a short fade. |
| WidgetState | `availability` and `confirmedValue`; workspace set belongs to the instance output. |

Validate before creating instances; invalid entries fall back individually with diagnostics. Volume OSD state remains independent.
