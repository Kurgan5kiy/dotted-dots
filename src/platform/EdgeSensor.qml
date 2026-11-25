import QtQuick
import Quickshell
import Quickshell.Wayland
import "EdgeZones.js" as EdgeZones
import "../surfaces/volume/Lifecycle.js" as Lifecycle

PanelWindow {
    id: root
    required property var preferences
    required property string outputName
    required property real outputHeight
    property bool osdVisible: false
    property bool suppressed: false
    property string edgeState: "armed"
    readonly property string side: EdgeZones.resolveSide(preferences.edge, outputName)
    readonly property var zone: EdgeZones.bounds(outputHeight)
    signal summoned(string side)
    anchors {
        left: root.side === "left"
        right: root.side === "right"
        top: true
    }
    margins.top: zone.middleTop
    implicitWidth: preferences.edge.width
    implicitHeight: zone.middleHeight
    visible: preferences.edge.enabled && !suppressed
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
                root.summoned(root.side);
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
