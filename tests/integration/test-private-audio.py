#!/usr/bin/env python3
"""Exercise the real AudioService against private null sinks, never host audio."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time


def wait_for(read, predicate, description, timeout=5):
    end = time.monotonic() + timeout
    last = None
    while time.monotonic() < end:
        last = read()
        if predicate(last):
            return last
        time.sleep(0.03)
    raise AssertionError(f"Timed out: {description}; last state: {last}")


def stop(process):
    if process is not None and process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def main():
    root = Path(__file__).resolve().parents[2]
    with tempfile.TemporaryDirectory(prefix="dot-shell-audio-test-") as workspace:
        work = Path(workspace)
        runtime = work / "runtime"
        runtime.mkdir(mode=0o700)
        env = dict(os.environ, PIPEWIRE_RUNTIME_DIR=str(runtime),
                   PIPEWIRE_REMOTE="dot-shell-audio-test")
        daemon = shell = None
        with (work / "pipewire.log").open("w") as pw_log, (work / "shell.log").open("w") as qs_log:
            try:
                daemon = subprocess.Popen(["pipewire", "-c", str(root / "tests/integration/private-pipewire.conf")],
                                          env=env, stdout=pw_log, stderr=subprocess.STDOUT)
                wait_for(lambda: (runtime / "dot-shell-audio-test").exists(), bool, "private server socket")
                def command(*args):
                    return subprocess.run(args, env=env, text=True, capture_output=True, check=True, timeout=5).stdout
                objects = json.loads(command("pw-dump"))
                sinks = {item["info"]["props"]["node.name"]: item["id"] for item in objects
                         if item.get("type") == "PipeWire:Interface:Node"}
                assert set(sinks) == {"dot-shell-test-a", "dot-shell-test-b"}, sinks
                command("pw-metadata", "0", "default.audio.sink", '{"name":"dot-shell-test-a"}', "Spa:String:JSON")
                shutil.copytree(root / "src", work / "src")
                entry = work / "shell.qml"
                entry.write_text('''import QtQuick
import Quickshell
import Quickshell.Io
import "src/services"
ShellRoot {
    AudioService { id: service }
    IpcHandler {
        target: "audio_test"
        function state(): string {
            const state = service.snapshot();
            state.pending = service.pending;
            state.error = service.error;
            return JSON.stringify(state);
        }
        function setPercent(percent: int): string { return service.act("setPercent", percent, 5, 100); }
        function armUnconfirmed(): void {
            service.pending = {sinkId: service.snapshot().sinkId, percent: 87, muted: null};
            service.deadline.restart();
        }
    }
    Timer { interval: 30000; running: true; onTriggered: Qt.quit() }
}
''')
                shell = subprocess.Popen(["qs", "-p", str(entry), "--no-color"], env=env,
                                         stdout=qs_log, stderr=subprocess.STDOUT)
                def ipc(action, *args):
                    return command("qs", "-p", str(entry), "ipc", "call", "--", "audio_test", action, *map(str, args))
                def state():
                    try:
                        return json.loads(ipc("state"))
                    except subprocess.CalledProcessError:
                        return {"available": False}
                initial = wait_for(state, lambda value: value["available"], "default sink tracking")
                assert initial["sinkId"] == sinks["dot-shell-test-a"]
                assert json.loads(ipc("setPercent", 40))["status"] == "accepted"
                wait_for(state, lambda value: abs(value["percent"] - 40) < 0.5 and value["pending"] is None,
                         "confirmed real null-sink write")
                print("PASS: tracked default sink and confirmed write")
                ipc("armUnconfirmed")
                wait_for(state, lambda value: value.get("pending") is None and bool(value.get("error")),
                         "1000 ms confirmation deadline")
                print("PASS: injected unconfirmed request reaches actual service deadline")
                ipc("armUnconfirmed")
                command("pw-metadata", "0", "default.audio.sink", '{"name":"dot-shell-test-b"}', "Spa:String:JSON")
                wait_for(state, lambda value: value.get("sinkId") == sinks["dot-shell-test-b"]
                         and value.get("pending") is None and value.get("error") == "", "stale-sink cancellation")
                print("PASS: default switch cancels stale pending request")
                command("pw-cli", "destroy", str(sinks["dot-shell-test-b"]))
                wait_for(state, lambda value: not value["available"], "sink removal")
                assert json.loads(ipc("setPercent", 40))["error"] == "unavailable"
                command("pw-metadata", "0", "default.audio.sink", '{"name":"dot-shell-test-a"}', "Spa:String:JSON")
                recovered = wait_for(state, lambda value: value["available"] and value.get("sinkId") == sinks["dot-shell-test-a"], "sink recovery")
                assert abs(recovered["percent"] - 40) < 0.5
                print("PASS: removal, unavailable rejection and default-sink recovery")
                stop(shell)
                shell = None
                # Instrument a private copy of the actual shell root. Production
                # service, trigger policy, routing, controller and IPC stay intact.
                config = work / "config/dot-shell"
                config.mkdir(parents=True)
                (config / "config.json").write_text(json.dumps({
                    "schemaVersion": 1, "edge": {"enabled": False},
                    "motion": {"reduced": True}, "placement": {"anchor": "left-center"}
                }))
                env["XDG_CONFIG_HOME"] = str(work / "config")
                source = (work / "src/shell.qml").read_text()
                for directory in ("config", "services", "platform", "ipc", "surfaces/volume"):
                    source = source.replace('import "' + directory + '"', 'import "src/' + directory + '"')
                source = source.replace("    Loader {", "    Loader {\n        id: observedSurface", 1)
                instrument = '''
    property int testSummons: 0
    Connections {
        target: osdController
        function onPhaseChanged(): void {
            if (osdController.phase === "emerging") root.testSummons++;
        }
    }
    IpcHandler {
        target: "osd_test"
        function state(): string {
            return JSON.stringify({audio: soundService.snapshot(), phase: osdController.phase,
                count: root.testSummons, loaded: observedSurface.item !== null});
        }
        function reset(automatic: bool): void {
            const values = JSON.parse(JSON.stringify(settingsService.values));
            values.triggers.externalAudioChanges = automatic;
            settingsService.values = values;
            osdController.phase = "dormant";
        }
    }
    Timer { interval: 30000; running: true; onTriggered: Qt.quit() }
'''
                source = source.replace('import Quickshell\n', 'import Quickshell\nimport Quickshell.Io\n', 1)
                entry.write_text(source.rstrip()[:-1] + instrument + "}\n")
                window = work / "src/surfaces/volume/VolumeOsd.qml"
                window.write_text(window.read_text().replace('    color: "transparent"',
                    '    mask: Region {}\n    color: "transparent"', 1))
                shell = subprocess.Popen(["qs", "-p", str(entry), "--no-color"], env=env,
                                         stdout=qs_log, stderr=subprocess.STDOUT)
                def osd(action, *args):
                    return command("qs", "-p", str(entry), "ipc", "call", "--", "osd_test", action, *map(str, args))
                def osd_state():
                    try:
                        return json.loads(osd("state"))
                    except subprocess.CalledProcessError:
                        return {"audio": {"available": False}}
                wait_for(osd_state, lambda value: value["audio"]["available"], "full private OSD startup")
                for mode in ("external", "direct", "disabled"):
                    for index in range(20):
                        automatic = mode == "external"
                        osd("reset", "true" if automatic else "false")
                        before = osd_state()["count"]
                        percent = 25 + index
                        if mode == "direct":
                            result = command("qs", "-p", str(entry), "ipc", "call", "--", "volume_v1", "setPercent", str(percent))
                            assert json.loads(result)["status"] == "accepted"
                        else:
                            volume = (percent / 100) ** 3
                            command("pw-cli", "set-param", str(sinks["dot-shell-test-a"]), "Props",
                                    json.dumps({"channelVolumes": [volume, volume]}))
                        current = wait_for(osd_state, lambda value: abs(value["audio"].get("percent", -1) - percent) < 0.5,
                                           f"{mode} trial {index + 1} confirmed state")
                        if mode == "disabled":
                            time.sleep(0.05)
                            current = osd_state()
                            assert current["phase"] == "dormant" and current["count"] == before, current
                        else:
                            current = wait_for(osd_state, lambda value: value.get("loaded", False), "single OSD creation")
                            assert current["count"] == before + 1 and current["phase"] != "dormant", current
                    print(f"PASS: {mode}: 20/20 confirmed states and expected summon policy")
            except Exception:
                pw_log.flush()
                qs_log.flush()
                print((work / "pipewire.log").read_text())
                print((work / "shell.log").read_text())
                raise
            finally:
                stop(shell)
                stop(daemon)


if __name__ == "__main__":
    main()
