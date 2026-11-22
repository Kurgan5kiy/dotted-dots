pragma ComponentBehavior: Bound
import QtQuick
import "../../visual"

Item {
    id: root
    required property var preferences
    required property var audio
    required property var controller

    readonly property real spacing: preferences.field.spacing
    readonly property real columnX: spacing / 2 + (Math.floor(width / spacing) - 3) * spacing
    readonly property real chainTop: spacing / 2 + 4 * spacing
    readonly property int intervals: Math.max(2, Math.floor(height / spacing) - 10)
    readonly property real chainHeight: intervals * spacing
    readonly property int currentNode: audio.available ? Math.min(intervals, Math.floor(Math.max(0, audio.percent) / preferences.volume.maxPercent * intervals + 0.001)) : -1
    readonly property int fadeMs: preferences.motion.reduced ? 100 : (controller.phase === "retracting" ? preferences.timing.retractMs : preferences.timing.emergeMs)

    Item {
        id: scene
        anchors.fill: parent
        clip: true
        property bool entered: false
        Component.onCompleted: entered = true
        opacity: !entered || root.controller.phase === "retracting" || root.controller.phase === "dormant" ? 0 : 1
        Behavior on opacity {
            NumberAnimation {
                duration: root.fadeMs
                easing.type: Easing.OutCubic
            }
        }
        transform: Scale {
            origin.x: root.width
            origin.y: root.height / 2
            xScale: root.preferences.motion.reduced ? 1 : (!scene.entered || root.controller.phase === "retracting" ? 0.1 : 1)
            Behavior on xScale {
                NumberAnimation {
                    duration: root.fadeMs
                    easing.type: Easing.OutCubic
                }
            }
        }
        FeatheredBackdrop {
            width: root.width * 2
            height: root.height
            feather: root.preferences.field.feather
            fillColor: root.preferences.field.backdropColor
            centerOpacity: root.preferences.field.backdropOpacity
        }
        DotField {
            anchors.fill: parent
            extentWidth: root.width * 2
            followBackdrop: true
            backdropOpacity: root.preferences.field.backdropOpacity
            excludedColumnX: root.columnX
            excludedYStart: root.chainTop
            excludedYEnd: root.chainTop + root.chainHeight
            spacing: root.spacing
            dotRadius: root.preferences.field.dotRadius
            feather: root.preferences.field.feather
        }
        Text {
            objectName: "volumeValue"
            x: root.columnX - width / 2
            y: root.chainTop - height - 2
            text: root.audio.available ? Math.round(root.audio.percent) + "%" : "—"
            font.family: root.preferences.typography.family
            font.pixelSize: root.preferences.typography.pixelSize
            font.weight: root.preferences.typography.weight
            font.italic: root.preferences.typography.italic
            color: "white"
            opacity: root.controller.phase === "constructing" || root.controller.interactive ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: root.preferences.motion.reduced ? 0 : root.preferences.timing.constructMs
                }
            }
        }
        PathTrace {
            id: trace
            x: root.columnX - width / 2
            y: root.chainTop
            width: 1
            height: root.chainHeight
            vertical: true
            showHead: root.audio.available
            progress: root.controller.phase === "emerging" || root.currentNode < 0 ? 0 : root.currentNode / root.intervals
            Behavior on progress {
                enabled: !root.preferences.motion.reduced
                NumberAnimation {
                    duration: root.controller.interactive ? root.preferences.timing.levelMs : root.preferences.timing.traceMs
                    easing.type: Easing.InOutCubic
                }
            }
        }
        Repeater {
            model: root.intervals + 1
            Rectangle {
                required property int index
                x: root.columnX - width / 2
                y: root.chainTop + root.chainHeight - index * root.spacing - height / 2
                width: root.preferences.field.dotRadius * 2
                height: width
                radius: width / 2
                color: "#888888"
                visible: index > Math.max(root.currentNode, Math.ceil(trace.progress * root.intervals))
            }
        }
        MouseArea {
            x: root.columnX - 16
            y: root.chainTop - 16
            width: 32
            height: root.chainHeight + 32
            enabled: root.controller.interactive && root.audio.available
            cursorShape: Qt.PointingHandCursor
            function adjust(position: real): void {
                const node = Math.max(0, Math.min(root.intervals, Math.round((root.chainHeight - (position - 16)) / root.spacing)));
                root.audio.act("setPercent", Math.round(node / root.intervals * root.preferences.volume.maxPercent), root.preferences.volume.stepPercent, root.preferences.volume.maxPercent);
            }
            onPressed: mouse => {
                root.controller.dragging = true;
                adjust(mouse.y);
            }
            onPositionChanged: mouse => {
                if (pressed)
                    adjust(mouse.y);
            }
            onReleased: root.controller.dragging = false
            onCanceled: root.controller.dragging = false
        }
        Item {
            x: root.columnX - 16
            y: root.chainTop + root.chainHeight + 20
            width: 32
            height: 32
            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: 4
                color: root.audio.muted ? "#999999" : "white"
                Rectangle {
                    anchors.centerIn: parent
                    width: 3
                    height: 3
                    radius: 1.5
                    color: root.preferences.field.backdropColor
                    visible: root.audio.muted
                }
            }
            MouseArea {
                anchors.fill: parent
                enabled: root.controller.interactive && root.audio.available
                cursorShape: Qt.PointingHandCursor
                onClicked: root.audio.act("toggleMute", 0, root.preferences.volume.stepPercent, root.preferences.volume.maxPercent)
            }
        }
        Text {
            x: 24
            y: root.height / 2
            width: Math.max(1, root.columnX - 44)
            text: root.audio.error || (!root.audio.available ? "Audio unavailable" : "")
            wrapMode: Text.WordWrap
            color: "white"
            font.pixelSize: 11
        }
    }
    HoverHandler {
        onHoveredChanged: root.controller.hovered = hovered
    }
}
