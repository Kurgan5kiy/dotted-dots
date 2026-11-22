import QtQuick
import Quickshell.Services.Pipewire
import "AudioState.js" as AudioState

QtObject {
    id: root
    property var sink: Pipewire.defaultAudioSink
    readonly property bool available: Pipewire.ready && sink !== null && sink.ready && sink.audio !== null && isFinite(sink.audio.volume) && sink.audio.volume >= 0
    readonly property real percent: available ? sink.audio.volume * 100 : 0
    readonly property bool muted: available ? sink.audio.muted : false
    property var pending: null
    property string error: ""
    property var previous: ({
            available: false
        })
    signal audioChanged
    signal actionAccepted

    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
    property Timer deadline: Timer {
        interval: 1000
        onTriggered: {
            root.pending = null;
            root.error = "Audio change was not confirmed";
        }
    }
    function snapshot(): var {
        return {
            available: available,
            sinkId: available ? sink.id : null,
            percent: available ? sink.audio.volume * 100 : null,
            muted: available ? sink.audio.muted : null
        };
    }
    function observe(): void {
        const current = snapshot();
        if (pending && (!current.available || current.sinkId !== pending.sinkId)) {
            pending = null;
            deadline.stop();
        }
        if (AudioState.confirmed(current, pending)) {
            pending = null;
            deadline.stop();
            error = "";
        }
        const updated = AudioState.changed(previous, current);
        previous = current;
        if (updated)
            audioChanged();
    }
    onAvailableChanged: observe()
    onPercentChanged: observe()
    onMutedChanged: observe()
    onSinkChanged: {
        pending = null;
        deadline.stop();
        error = "";
        observe();
    }
    function act(kind: string, value: real, step: int, cap: int): string {
        const request = AudioState.request(kind, value, snapshot(), pending, step, cap);
        if (request.status === "rejected") {
            error = request.error === "unavailable" ? "Audio unavailable" : "Invalid volume";
            return JSON.stringify({
                version: 1,
                status: request.status,
                error: request.error
            });
        }
        error = "";
        if (!request.noop) {
            pending = {
                sinkId: sink.id,
                percent: request.percent !== null ? request.percent : (pending ? pending.percent : null),
                muted: request.muted !== null ? request.muted : (pending ? pending.muted : null)
            };
            deadline.restart();
            if (request.percent !== null)
                sink.audio.volume = request.percent / 100;
            if (request.muted !== null)
                sink.audio.muted = request.muted;
            observe();
        }
        actionAccepted();
        return JSON.stringify({
            version: 1,
            status: "accepted"
        });
    }
}
