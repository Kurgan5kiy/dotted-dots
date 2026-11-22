import QtQuick
import Quickshell.Io

QtObject {
    id: root
    required property var audio
    required property var preferences
    signal showRequested
    property IpcHandler handler: IpcHandler {
        target: "volume_v1"
        function show(): string {
            root.showRequested();
            return JSON.stringify({
                version: 1,
                status: "accepted"
            });
        }
        function increase(): string {
            return root.audio.act("increase", 0, root.preferences.volume.stepPercent, root.preferences.volume.maxPercent);
        }
        function decrease(): string {
            return root.audio.act("decrease", 0, root.preferences.volume.stepPercent, root.preferences.volume.maxPercent);
        }
        function setPercent(value: int): string {
            return root.audio.act("setPercent", value, root.preferences.volume.stepPercent, root.preferences.volume.maxPercent);
        }
        function toggleMute(): string {
            return root.audio.act("toggleMute", 0, root.preferences.volume.stepPercent, root.preferences.volume.maxPercent);
        }
        function state(): string {
            const current = root.audio.snapshot();
            return JSON.stringify({
                version: 1,
                available: current.available,
                percent: current.percent,
                muted: current.muted
            });
        }
    }
}
