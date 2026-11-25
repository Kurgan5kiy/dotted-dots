# Bar validation guide

1. Run `scripts/check-qml.sh`, `tests/test-cli.sh` and `tests/test-package.sh`; record versions and results.
2. Start `qs -p src/shell.qml`. Verify default top, always-visible bar on each connected output and unchanged volume behavior.
3. Use a temporary user-local config to exercise each edge and mode. Verify upright text, fixed targets, reserved space in always mode, a narrow reveal strip in auto mode, keyboard reveal and open tray menu.
4. Reorder/disable widgets; test absent battery and services, workspace activation on its own output, volume invocation and tray actions.
5. Capture normal/reduced motion over four original wallpaper fixtures, overflow and scale 1/1.25/1.5/2 geometry. Record idle/reveal resource observations.
6. With two physical outputs, test all/subset selection, hotplug, distinct workspaces, shared-edge volume discovery and two scales. Leave physical acceptance open until that setup exists.

Use temporary configuration and privacy-safe fixtures; do not change installed shell or Niri settings.
