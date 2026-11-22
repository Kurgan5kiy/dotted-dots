import QtQuick
import Quickshell
import Quickshell.Wayland
import "../surfaces/volume/Lifecycle.js" as Lifecycle

PanelWindow {
    id: root
    required property var preferences
    property bool osdVisible: false
    property string edgeState: "armed"
    signal summoned
    anchors {
        right: true
        top: true
        bottom: true
    }
    implicitWidth: preferences.edge.width
    visible: preferences.edge.enabled
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "dot-shell-edge"
    onVisibleChanged: {
        dwell.stop();
        edgeState = "armed";
    }
    Timer {
        id: dwell
        interval: root.preferences.edge.dwellMs
        onTriggered: {
            root.edgeState = Lifecycle.edge(root.edgeState, "elapsed");
            if (root.edgeState === "latched")
                root.summoned();
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            root.edgeState = Lifecycle.edge(root.edgeState, "enter");
            if (root.edgeState === "dwelling" && !root.osdVisible)
                dwell.restart();
        }
        onExited: {
            dwell.stop();
            root.edgeState = Lifecycle.edge(root.edgeState, "leave");
        }
    }
}
