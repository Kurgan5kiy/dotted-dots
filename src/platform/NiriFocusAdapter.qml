import QtQuick
import Quickshell.Io
import "NiriEvents.js" as NiriEvents

QtObject {
    id: root
    property var state: NiriEvents.initial()
    property var workspaceSnapshot: ({})
    property int reconnectAttempts: 0
    property int activationSerial: 0
    property int activatedWorkspaceId: -1
    property real activatedAtMs: 0
    readonly property string outputId: state.outputId || ""
    readonly property bool ready: state.ready
    readonly property bool windowFocused: state.windowFocused
    readonly property string diagnostic: state.diagnostic || ""

    function ensureRunning(): void {
        if (!stream.running) {
            reconnectAttempts = 0;
            stream.running = true;
        }
    }

    function consume(line: string): void {
        try {
            const event = JSON.parse(line);
            const activation = event.WorkspaceActivated;
            if (activation && activation.focused && typeof activation.id === "number") {
                activatedWorkspaceId = activation.id;
                activatedAtMs = Date.now();
                activationSerial += 1;
            }
            state = NiriEvents.reduce(state, event);
            if (event.WorkspacesChanged || event.WorkspaceActivated)
                workspaceSnapshot = state.workspaces;
            if (state.ready)
                reconnectAttempts = 0;
        } catch (error) {
            console.warn("Ignored malformed Niri event-stream message");
        }
    }

    property Process stream: Process {
        command: ["niri", "msg", "-j", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => root.consume(line)
        }
        onExited: (exitCode, exitStatus) => {
            root.state = NiriEvents.invalidate(root.state, "event_stream_closed");
            root.workspaceSnapshot = ({});
            if (root.reconnectAttempts < 3) {
                root.reconnectAttempts += 1;
                root.reconnect.restart();
            }
        }
    }

    property Timer reconnect: Timer {
        interval: 2000
        repeat: false
        onTriggered: {
            if (!root.stream.running)
                root.stream.running = true;
        }
    }
}
