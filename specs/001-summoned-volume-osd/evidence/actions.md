# Private audio integration and summon policy

Method: `python3 tests/integration/test-private-audio.py`, documented in
`tests/integration/README.md`. Environment: Niri 26.04, Quickshell 0.3.2, Qt
6.12.0 and PipeWire 1.6.11. A dedicated temporary PipeWire remote contains two
null sinks; no host audio endpoint is used or changed.

## Observed service checks

- The real AudioService tracked the private default sink and confirmed an
  absolute write to 40%.
- An injected unconfirmed pending request expired through the actual service
  deadline and produced its error state. This tests the timer/logic, not a
  physical device refusing a write.
- Switching the private graph's default sink cancelled the stale pending
  request and cleared its error state.
- Removing that sink made the service unavailable; another write was rejected
  as unavailable. Switching back recovered the earlier sink and retained its
  confirmed 40% state.

## Structured summon-policy results

An instrumented private copy of the actual shell root retained its production
service, configuration, routing, lifecycle, OSD loader and volume_v1 IPC. Only
test observation/reset handlers and an empty native input mask were added.
Every trial began dormant; the test checked confirmed state, phase transitions
and a single loaded OSD.

| Mode | Trials | Result |
| --- | ---: | --- |
| External changes, automatic summoning enabled | 20 | 20 latest confirmed values; exactly one summon each |
| Direct volume_v1 actions, automatic summoning disabled | 20 | 20 accepted actions and confirmed values; exactly one summon each |
| External changes, automatic summoning disabled | 20 | 20 confirmed updates; no summon and OSD remained dormant |

SC-001 is satisfied in this isolated graph/environment. The already documented
Niri binding examples remain opt-in and were not installed into user files.
Actual hardware audio routes and compositor key dispatch are not established
by these tests. T018's opt-in binding documentation and both trigger modes are
verified; the actual public CLI was also used by the later native latency
trials. User binding files were never edited.

## Remaining timing and failure coverage

This audio-service harness observes state and loader/phase transitions, not
pixels. The separate native suite now records twenty pixel-presentation trials
per audio mode and twenty edge dwell/cancellation trials in `feedback.md`.
Physical-device failure/recovery and actual key-event dispatch remain outside
these isolated tests.
