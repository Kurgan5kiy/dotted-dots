pragma ComponentBehavior: Bound
import QtQuick
import "../../visual"

Item {
    id: root
    required property var preferences
    required property real percent
    required property bool available
    required property bool interactive
    required property var illumination
    required property int intervals
    readonly property real spacing: preferences.field.spacing
    readonly property real chainHeight: intervals * spacing
    readonly property int currentNode: available ? Math.min(intervals, Math.floor(Math.max(0, percent) / preferences.volume.maxPercent * intervals + 0.001)) : -1
    readonly property real presentedNode: trace.progress * intervals
    property bool ready: false
    signal percentRequested(int percent)
    signal dragStateChanged(bool dragging)
    Component.onCompleted: ready = true
    PathTrace {
        id: trace
        objectName: "volumeTrace"
        z: 1
        x: (root.width - width) / 2
        y: 16
        width: root.preferences.field.lineWidth
        height: root.chainHeight
        vertical: true
        strokeWidth: root.preferences.field.lineWidth
        showHead: root.available
        illumination: (px, py) => root.illumination(trace.x + px, trace.y + py)
        progress: root.currentNode < 0 ? 0 : root.currentNode / root.intervals
        Behavior on progress {
            enabled: root.ready && root.interactive && !root.preferences.motion.reduced
            NumberAnimation {
                duration: root.preferences.timing.levelMs
                easing.type: Easing.InOutCubic
            }
        }
    }
    Repeater {
        model: root.intervals + 1
        Rectangle {
            required property int index
            objectName: "volumeNode" + index
            x: (root.width - width) / 2
            y: 16 + root.chainHeight - index * root.spacing - height / 2
            width: root.preferences.field.dotRadius * 2
            height: width
            radius: width / 2
            color: "#b8b8b8"
            readonly property real coverage: root.available ? Math.max(0, Math.min(1, (index - root.presentedNode) * root.spacing / 3)) : 1
            opacity: coverage * root.illumination(root.width / 2, y + height / 2)
        }
    }
    MouseArea {
        anchors.fill: parent
        enabled: root.interactive && root.available
        cursorShape: Qt.PointingHandCursor
        function adjust(position: real): void {
            const node = Math.max(0, Math.min(root.intervals, Math.round((root.chainHeight - (position - 16)) / root.spacing)));
            root.percentRequested(Math.round(node / root.intervals * root.preferences.volume.maxPercent));
        }
        onPressed: mouse => {
            root.dragStateChanged(true);
            adjust(mouse.y);
        }
        onPositionChanged: mouse => {
            if (pressed)
                adjust(mouse.y);
        }
        onReleased: root.dragStateChanged(false)
        onCanceled: root.dragStateChanged(false)
    }
}
