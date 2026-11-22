pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Isolated, bounded diagnostic. It does not change audio or compositor configuration.
ShellRoot {
    id: root
    property int summons: 0

    Timer {
        interval: 300000
        running: true
        onTriggered: Qt.quit()
    }

    IpcHandler {
        target: "edge_test"
        function count(): int {
            return root.summons;
        }
        function stop(): void {
            Qt.quit();
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: output
            required property ShellScreen modelData
            property bool shown: false
            property bool armed: true

            Timer {
                id: dwell
                interval: 200
                onTriggered: {
                    if (!output.armed)
                        return;
                    output.armed = false;
                    output.shown = true;
                    root.summons++;
                    console.info("edge-test summon", output.modelData.name, Date.now());
                    idle.restart();
                }
            }
            Timer {
                id: idle
                interval: 2000
                onTriggered: {
                    output.shown = false;
                    console.info("edge-test dismiss", output.modelData.name, Date.now());
                }
            }

            PanelWindow {
                screen: output.modelData
                anchors {
                    right: true
                    top: true
                    bottom: true
                }
                implicitWidth: 1
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "dot-shell-edge-test-sensor"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        console.info("edge-test enter", output.modelData.name, Date.now());
                        if (output.armed && !output.shown)
                            dwell.restart();
                    }
                    onExited: {
                        dwell.stop();
                        output.armed = true;
                        console.info("edge-test leave", output.modelData.name, Date.now());
                    }
                }
            }

            PanelWindow {
                screen: output.modelData
                visible: output.shown
                anchors.right: true
                implicitWidth: 300
                implicitHeight: 120
                color: "#222222"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "dot-shell-edge-test-panel"

                Text {
                    anchors.centerIn: parent
                    color: "white"
                    text: "Edge sensor diagnostic\n200 ms dwell · 2 s idle\nHover keeps this panel open"
                    horizontalAlignment: Text.AlignHCenter
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: idle.stop()
                    onExited: idle.restart()
                }
            }
        }
    }
}
