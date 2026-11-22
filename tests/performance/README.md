# OSD quality and performance checks

The finite `Probe.qml` workload runs only simulated audio and pointer positions.
Its temporary overlay has an empty input region and no keyboard focus. It does
not change real audio, Niri configuration or installed packages. The Python
runner copies the requested source into a temporary Quickshell configuration,
removes it on exit and limits the child to 60 seconds.

Before refactoring, preserve the source and measure it:

```sh
mkdir -p /tmp/dot-shell-baseline
cp -a src /tmp/dot-shell-baseline/src
python3 scripts/profile-osd.py --source /tmp/dot-shell-baseline/src \
  --output dist/performance/before.json
python3 scripts/profile-osd.py --source /tmp/dot-shell-baseline/src --dense \
  --output dist/performance/before-dense.json
```

After refactoring, run the corresponding current-source probes and compare:

```sh
python3 scripts/profile-osd.py --source src --output dist/performance/after.json
python3 scripts/profile-osd.py --source src --dense \
  --output dist/performance/after-dense.json
bash tests/test-visual-parity.sh /tmp/dot-shell-baseline/src
scripts/check-qml.sh
```

Run benchmarks sequentially, without another benchmark or test suite competing
for CPU. Each probe records ten seconds of simultaneous pointer/volume motion,
a settling period, ten seconds visible and settled, then ten seconds unloaded.
Default geometry has 300 grid nodes; the dense case has 1,850, below the 2,048
cap. The unloaded phase includes teardown cost. This probe omits real audio,
edge sensors and IPC, so it measures the visual subsystem rather than complete
end-to-end latency.

JSON reports CPU as a percentage of **one** core, end-of-phase resident memory,
prepared frame counts and integer-millisecond Qt GUI/sync/render statistics.
Raw scene-graph logs stay beside the JSON. These are diagnostic timings with
logging overhead, not GPU timestamps or proof that every frame was presented.
Do not infer a universal performance guarantee from one machine or a single
before/after trial. Long-lived driver/Qt caches may remain after unloading;
resident memory alone is not a leak test.

The optional visual parity test freezes fluid deformation and compares the old
and current code on four original fixtures, pointer-following and a translucent
backdrop. It permits at most one RGB channel value of difference per pixel.
It uses no personal wallpaper or external artwork. Animation regressions are
also covered by the ordinary QML interaction, endpoint, retreat and boundary
tests; live visual retesting remains required.

This follows Qt's guidance to
[measure binding and JavaScript costs](https://doc.qt.io/qt-6/qtquick-performance.html)
before optimizing. Keep cached backdrop images, bounded populations and finite
animations; avoid replacing them with a per-frame Canvas repaint or a global
pointer poll.
