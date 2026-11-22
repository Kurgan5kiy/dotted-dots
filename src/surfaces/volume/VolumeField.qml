pragma ComponentBehavior: Bound
import QtQuick
import "../../visual"

Item {
    id: root
    required property var preferences
    required property var audio
    required property var controller
    readonly property FieldLight light: fieldLight
    readonly property real spacing: preferences.field.spacing
    readonly property real columnX: spacing / 2 + (Math.floor(width / spacing) - 3) * spacing
    readonly property real chainTop: spacing / 2 + 4 * spacing
    readonly property int intervals: Math.max(2, Math.floor(height / spacing) - 10)
    readonly property real chainHeight: intervals * spacing
    readonly property int currentNode: chain.currentNode
    readonly property real presentedNode: chain.presentedNode
    onCurrentNodeChanged: {
        if (fieldLight.ready)
            fieldLight.settle();
    }
    FieldLight {
        id: fieldLight
        preferences: root.preferences
        width: root.width
        height: root.height
        shown: root.controller.phase !== "dormant" && root.controller.phase !== "retracting"
    }
    FontLoader {
        id: calligraphy
        source: Qt.resolvedUrl("../../assets/fonts/allura/Allura-Regular.ttf")
    }
    Item {
        anchors.fill: parent
        clip: true
        opacity: fieldLight.proximity
        FluidBackdrop {
            anchors.fill: parent
            shapes: fieldLight.shapes
            offset: fieldLight.fieldOffset
            feather: root.preferences.field.feather
            fillColor: root.preferences.field.backdropColor
            centerOpacity: root.preferences.field.backdropOpacity
        }
        DotField {
            anchors.fill: parent
            samples: fieldLight.samples
            backdropOpacity: root.preferences.field.backdropOpacity
            excludedColumnX: root.columnX
            excludedYStart: root.chainTop
            excludedYEnd: root.chainTop + root.chainHeight
            spacing: root.spacing
            dotRadius: root.preferences.field.dotRadius
        }
        AnimatedValue {
            objectName: "volumeValue"
            x: root.columnX - width / 2
            y: root.chainTop - height - 2
            opacity: fieldLight.controlAt(root.columnX, y + height / 2)
            value: root.audio.percent
            available: root.audio.available
            duration: root.preferences.timing.numberMs
            travel: root.preferences.typography.travel
            reducedMotion: root.preferences.motion.reduced || !root.controller.interactive
            numberFont: Qt.font({
                family: root.preferences.typography.family === "Allura" && calligraphy.status === FontLoader.Ready ? calligraphy.name : root.preferences.typography.family,
                pixelSize: root.preferences.typography.pixelSize,
                weight: root.preferences.typography.weight,
                italic: root.preferences.typography.italic
            })
        }
        VolumeChain {
            id: chain
            x: root.columnX - 16
            y: root.chainTop - 16
            width: 32
            height: root.chainHeight + 32
            preferences: root.preferences
            percent: root.audio.percent
            available: root.audio.available
            interactive: root.controller.interactive
            intervals: root.intervals
            illumination: (px, py) => fieldLight.controlAt(chain.x + px, chain.y + py)
            onPercentRequested: percent => root.audio.act("setPercent", percent, root.preferences.volume.stepPercent, root.preferences.volume.maxPercent)
            onDragStateChanged: dragging => root.controller.dragging = dragging
        }
        MuteDot {
            x: root.columnX - width / 2
            y: root.chainTop + root.chainHeight + 20
            opacity: fieldLight.controlAt(root.columnX, y + height / 2)
            enabled: root.controller.interactive && root.audio.available
            muted: root.audio.muted
            reducedMotion: root.preferences.motion.reduced
            onToggled: root.audio.act("toggleMute", 0, root.preferences.volume.stepPercent, root.preferences.volume.maxPercent)
        }
        Text {
            x: 24
            y: root.height / 2
            width: Math.max(1, root.columnX - 44)
            text: root.audio.error || (!root.audio.available ? "Audio unavailable" : "")
            wrapMode: Text.WordWrap
            color: "white"
            opacity: fieldLight.controlAt(x + width / 2, y + height / 2)
            font.pixelSize: 11
        }
    }
    HoverHandler {
        onPointChanged: {
            if (hovered)
                fieldLight.trackPointer(point.position.x, point.position.y);
        }
        onHoveredChanged: {
            if (hovered)
                fieldLight.enterPointer(point.position.x, point.position.y);
            else if (fieldLight.pointerSeen)
                fieldLight.leavePointer();
            root.controller.hovered = hovered;
        }
    }
}
