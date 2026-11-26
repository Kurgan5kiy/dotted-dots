# Bar configuration contract (proposed)

Extend the existing user-local JSON file with `bar` in schema v3. Valid v1/v2 configurations migrate in memory and retain volume preferences without rewriting the file.

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

`outputs` is `"all"` or 1–32 unique exact output names. Unknown widget types, duplicates and invalid fields produce diagnostics while valid entries remain active. Restart applies settings initially. Existing volume IPC remains separate; document any new bar action before exposing it.
