pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../src/config/Validation.js" as Validation
import "../../src/surfaces/volume"

// Finite, input-transparent probe using simulated audio only.
ShellRoot {
    id: root
    property string stage: "warmup"
    property real cursorPhase: 0
    readonly property var visualField: field.item
    readonly property var preferences: {
        const values = Validation.defaults();
        if (Quickshell.env("DOT_SHELL_BENCH_DENSE") === "1") {
            values.field.width = 800;
            values.field.height = 600;
            values.field.spacing = 16;
        }
        return values;
    }
    function mark(next: string): void {
        stage = next;
        console.info("BENCH_PHASE", next);
    }
    onCursorPhaseChanged: {
        if (visualField) {
            const light = visualField.light || visualField;
            light.trackPointer(preferences.field.width * (0.5 + 0.45 * Math.sin(cursorPhase)), preferences.field.height * (0.5 + 0.45 * Math.cos(cursorPhase)));
        }
    }
    QtObject {
        id: simulatedAudio
        property bool available: true
        property real percent: 50
        property bool muted: false
        property string error: ""
    }
    QtObject {
        id: simulatedController
        property string phase: "interactive"
        property bool interactive: true
        property bool hovered: false
        property bool dragging: false
    }
    PanelWindow {
        anchors {
            top: true
            left: true
        }
        implicitWidth: root.preferences.field.width
        implicitHeight: root.preferences.field.height
        visible: root.stage !== "dormant"
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "dot-shell-performance-probe"
        Loader {
            id: field
            anchors.fill: parent
            active: root.stage !== "dormant"
            sourceComponent: VolumeField {
                preferences: root.preferences
                audio: simulatedAudio
                controller: simulatedController
            }
        }
    }
    SequentialAnimation {
        running: true
        PauseAnimation {
            duration: 1000
        }
        ScriptAction {
            script: root.mark("motion")
        }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "cursorPhase"
                from: 0
                to: Math.PI * 6
                duration: 10000
            }
            SequentialAnimation {
                NumberAnimation {
                    target: simulatedAudio
                    property: "percent"
                    to: 100
                    duration: 2500
                }
                NumberAnimation {
                    target: simulatedAudio
                    property: "percent"
                    to: 0
                    duration: 2500
                }
                NumberAnimation {
                    target: simulatedAudio
                    property: "percent"
                    to: 100
                    duration: 2500
                }
                NumberAnimation {
                    target: simulatedAudio
                    property: "percent"
                    to: 50
                    duration: 2500
                }
            }
        }
        ScriptAction {
            script: root.mark("settling")
        }
        PauseAnimation {
            duration: 6500
        }
        ScriptAction {
            script: root.mark("settled")
        }
        PauseAnimation {
            duration: 10000
        }
        ScriptAction {
            script: root.mark("dormant")
        }
        PauseAnimation {
            duration: 10000
        }
        ScriptAction {
            script: {
                root.mark("finished");
                Qt.quit();
            }
        }
    }
}
