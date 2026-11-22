#!/usr/bin/env python3
"""Measure composited OSD pixels and real edge input inside a private Niri."""
import argparse
from contextlib import ExitStack
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time

from virtual_pointer import VirtualPointer


ROOT = Path(__file__).resolve().parents[2]
DARK_PIXEL = bytes(1 if value <= 251 else 0 for value in range(256))


def wait_for(read, predicate, description, timeout=8):
    deadline = time.monotonic() + timeout
    last = None
    while time.monotonic() < deadline:
        last = read()
        if predicate(last):
            return last
        time.sleep(0.02)
    raise AssertionError(f"Timed out: {description}; last={last}")


def stop(process, group=False):
    if process.poll() is None:
        if group:
            os.killpg(process.pid, signal.SIGTERM)
        else:
            process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            if group:
                os.killpg(process.pid, signal.SIGKILL)
            else:
                process.kill()
            process.wait()


class Capture:
    def __init__(self, env, geometry):
        self.env = env
        self.width = geometry["width"]
        self.height = geometry["height"]
        self.region = f'{geometry["x"]},{geometry["y"]} {self.width}x{self.height}'

    def read(self):
        result = subprocess.run(["grim", "-t", "ppm", "-g", self.region, "-"],
                                env=self.env, capture_output=True, check=True, timeout=3)
        magic, dimensions, maximum, pixels = result.stdout.split(b"\n", 3)
        assert magic == b"P6" and maximum == b"255"
        assert dimensions == f"{self.width} {self.height}".encode()
        assert len(pixels) == self.width * self.height * 3
        return pixels

    @staticmethod
    def changed(pixels):
        return pixels[::3].translate(DARK_PIXEL).count(b"\1") >= 16

    def first_x(self, pixels):
        return min(index % self.width for index, value in enumerate(pixels[::3]) if value <= 251)

    def visible(self, started, limit=1.5):
        while time.monotonic() - started < limit:
            pixels = self.read()
            if self.changed(pixels):
                return round((time.monotonic() - started) * 1000, 3), pixels
        raise AssertionError("No changed compositor pixels before timeout")


def prepare_shell(work, env):
    shutil.copytree(ROOT / "src", work / "src")
    qa = work / "qa"
    qa.mkdir()
    shutil.copyfile(ROOT / "tests/integration/TimingControls.qml", qa / "TimingControls.qml")
    config = work / "config/dot-shell"
    config.mkdir(parents=True)
    (config / "config.json").write_text(json.dumps({"schemaVersion": 1, "edge": {"enabled": False}}))
    named = work / "config/quickshell"
    named.mkdir()
    (named / "timing-test").symlink_to(work, target_is_directory=True)
    env.update(XDG_CONFIG_HOME=str(work / "config"), DOT_SHELL_CONFIG_NAME="timing-test",
               XDG_CACHE_HOME=str(work / "cache"), XDG_STATE_HOME=str(work / "state"))
    source = (ROOT / "src/shell.qml").read_text()
    for directory in ("config", "services", "platform", "ipc", "surfaces/volume"):
        source = source.replace('import "' + directory + '"', 'import "src/' + directory + '"')
    source = source.replace("    Loader {", "    Loader {\n        id: observedSurface", 1)
    source = source.replace('import Quickshell\n', 'import Quickshell\nimport "qa"\n', 1)
    source = source.rstrip()[:-1] + '''
    TimingControls {
        settings: settingsService
        controller: osdController
        audio: soundService
        router: outputRouter
        surface: observedSurface
    }
}
'''
    (work / "shell.qml").write_text(source)


def run_trials(work, trials, frames):
    with ExitStack() as cleanup:
        runtime = work / "runtime"
        runtime.mkdir(mode=0o700)
        pw_runtime = work / "pipewire"
        pw_runtime.mkdir(mode=0o700)
        config = work / "niri.kdl"
        config.write_text("hotkey-overlay { skip-at-startup; }\nanimations { off; }\nxwayland-satellite { off; }\n")
        subprocess.run(["niri", "validate", "--config", str(config)], check=True, capture_output=True)
        host_display = Path(os.environ["WAYLAND_DISPLAY"])
        if not host_display.is_absolute():
            host_display = Path(os.environ["XDG_RUNTIME_DIR"]) / host_display
        nested_env = dict(os.environ, XDG_RUNTIME_DIR=str(runtime), WAYLAND_DISPLAY=str(host_display))
        for name in ("NIRI_SOCKET", "WAYLAND_SOCKET", "DISPLAY", "NOTIFY_SOCKET"):
            nested_env.pop(name, None)
        niri_log = cleanup.enter_context((work / "niri.log").open("w"))
        niri = subprocess.Popen(["dbus-run-session", "--", "niri", "--config", str(config)],
                                env=nested_env, stdout=niri_log, stderr=subprocess.STDOUT, start_new_session=True)
        cleanup.callback(stop, niri, True)
        ipc_socket = wait_for(lambda: list(runtime.glob("niri.*.sock")), bool, "private Niri IPC")[0]
        wayland_socket = wait_for(lambda: [path for path in runtime.glob("wayland-*") if path.is_socket()],
                                  bool, "private Wayland socket")[0]
        env = dict(nested_env, WAYLAND_DISPLAY=wayland_socket.name, NIRI_SOCKET=str(ipc_socket),
                   PIPEWIRE_RUNTIME_DIR=str(pw_runtime), PIPEWIRE_REMOTE="dot-shell-audio-test",
                   DBUS_SESSION_BUS_ADDRESS="unix:path=/nonexistent")
        def command(*args):
            return subprocess.run(args, env=env, capture_output=True, text=True, check=True, timeout=5).stdout
        pw_log = cleanup.enter_context((work / "pipewire.log").open("w"))
        daemon = subprocess.Popen(["pipewire", "-c", str(ROOT / "tests/integration/private-pipewire.conf")],
                                  env=env, stdout=pw_log, stderr=subprocess.STDOUT)
        cleanup.callback(stop, daemon)
        wait_for(lambda: (pw_runtime / "dot-shell-audio-test").exists(), bool, "private PipeWire socket")
        objects = json.loads(command("pw-dump"))
        sinks = {item["info"]["props"]["node.name"]: item["id"] for item in objects
                 if item.get("type") == "PipeWire:Interface:Node"}
        assert set(sinks) == {"dot-shell-test-a", "dot-shell-test-b"}
        command("pw-metadata", "0", "default.audio.sink", '{"name":"dot-shell-test-a"}', "Spa:String:JSON")
        prepare_shell(work, env)
        shell_log = cleanup.enter_context((work / "shell.log").open("w"))
        shell = subprocess.Popen(["qs", "-c", "timing-test", "--no-color"], env=env,
                                  stdout=shell_log, stderr=subprocess.STDOUT)
        cleanup.callback(stop, shell)
        def ipc(action, *args):
            return command("qs", "-c", "timing-test", "ipc", "call", "--", "timing_test", action, *map(str, args))
        def state():
            try:
                return json.loads(ipc("state"))
            except subprocess.CalledProcessError:
                return {"audio": {"available": False}}
        initial = wait_for(state, lambda value: value["audio"]["available"] and value.get("geometry", {}).get("usable"),
                           "private OSD readiness")
        assert initial["dwellMs"] == 100 and initial["emergeMs"] == 400 and not initial["reduced"]
        outputs = json.loads(command("niri", "msg", "-j", "outputs"))
        assert len(outputs) == 1
        output = next(iter(outputs.values()))["logical"]
        width, height = output["width"], output["height"]
        wait_for(state, lambda value: value.get("fixtureFullscreen") and value.get("fixtureWidth", 0) >= width
                 and value.get("fixtureHeight", 0) >= height, "opaque open-window fixture")
        windows = json.loads(command("niri", "msg", "-j", "windows"))
        assert any(window.get("title") == "Dot Shell timing fixture" for window in windows)
        capture = Capture(env, initial["geometry"])
        pointer = cleanup.enter_context(VirtualPointer(wayland_socket, work))
        results = {"environment": {"output": output, "geometry": initial["geometry"],
                    "niri": command("niri", "--version").strip(), "quickshell": command("qs", "--version").strip(),
                    "dwell_ms": initial["dwellMs"], "emerge_ms": initial["emergeMs"], "reduced_motion": initial["reduced"],
                    "backend": "nested Niri Winit", "open_window_fixture": True},
                   "external_ms": [], "direct_ms": [], "edge": [], "cancelled": []}
        def reset(automatic, edge):
            pointer.move(width // 2, height // 2, width, height)
            ipc("reset", "true" if automatic else "false", "true" if edge else "false")
            wait_for(capture.read, lambda pixels: not capture.changed(pixels), "clean white baseline")
            current = state()
            assert current["geometry"] == initial["geometry"], "Output geometry changed during measurement"
            return current["count"]
        for mode in ("external", "direct"):
            for index in range(trials):
                before = reset(mode == "external", False)
                percent = (20 if mode == "external" else 60) + index
                if mode == "external":
                    volume = (percent / 100) ** 3
                    args = ["pw-cli", "set-param", str(sinks["dot-shell-test-a"]), "Props",
                            json.dumps({"channelVolumes": [volume, volume]})]
                else:
                    args = [str(ROOT / "bin/dot-shell"), "ipc", "call", "volume_v1", "setPercent", str(percent)]
                started = time.monotonic()
                action = subprocess.Popen(args, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                try:
                    latency, _ = capture.visible(started)
                    stdout, stderr = action.communicate(timeout=5)
                    assert action.returncode == 0, stderr
                    if mode == "direct":
                        assert json.loads(stdout)["status"] == "accepted"
                finally:
                    stop(action)
                current = wait_for(state, lambda value: abs(value["audio"].get("percent", -1) - percent) < 0.5,
                                   "confirmed displayed value")
                assert current["count"] == before + 1 and current["loaded"], current
                results[mode + "_ms"].append(latency)
                assert latency <= 500, (mode, index, latency)
            print(f"PASS: {mode}: {trials}/{trials} visible responses, max {max(results[mode + '_ms']):.1f} ms", flush=True)
        for index in range(trials):
            before = reset(False, True)
            started = time.monotonic()
            pointer.move(width - 1, height // 2, width, height)
            latency, first = capture.visible(started)
            time.sleep(max(0, 0.35 - (time.monotonic() - started)))
            middle = capture.read()
            time.sleep(max(0, 0.55 - (time.monotonic() - started)))
            settled = capture.read()
            current = state()
            first_x, settled_x = capture.first_x(first), capture.first_x(settled)
            assert current["count"] == before + 1 and current["loaded"], current
            assert settled_x < first_x, (first_x, settled_x)
            filenames = []
            for tag, pixels in (("first", first), ("middle", middle), ("settled", settled)):
                filename = f"edge-{index + 1:02d}-{tag}.ppm"
                (frames / filename).write_bytes(f"P6\n{capture.width} {capture.height}\n255\n".encode() + pixels)
                filenames.append(filename)
            results["edge"].append({"first_visible_ms": latency, "first_x": first_x,
                                    "middle_x": capture.first_x(middle), "settled_x": settled_x,
                                    "frames": filenames})
        print(f"PASS: edge dwell: {trials}/{trials}, each field expands right-to-left", flush=True)
        for index in range(trials):
            before = reset(False, True)
            entered = time.monotonic()
            pointer.move(width - 1, height // 2, width, height)
            time.sleep(0.02)
            pointer.move(width // 2, height // 2, width, height)
            residency = (time.monotonic() - entered) * 1000
            assert residency < initial["dwellMs"], residency
            time.sleep(0.15)
            current = state()
            assert current["phase"] == "dormant" and current["count"] == before, current
            assert not capture.changed(capture.read())
            results["cancelled"].append({"residency_ms": round(residency, 3), "summoned": False})
        print(f"PASS: early edge exit: {trials}/{trials} cancelled", flush=True)
        return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--trials", type=int, default=20, choices=range(1, 21))
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    frames = args.output.parent / (args.output.stem + "-frames")
    frames.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="dot-shell-native-timing-") as directory:
        work = Path(directory)
        try:
            results = run_trials(work, args.trials, frames)
        except Exception:
            for log in work.glob("*.log"):
                print(log.name + ":\n" + log.read_text()[-5000:])
            raise
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(results, indent=2) + "\n")


if __name__ == "__main__":
    main()
