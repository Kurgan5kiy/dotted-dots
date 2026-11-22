pragma ComponentBehavior: Bound
import QtQuick
import "FluidShape.js" as FluidShape

Item {
    id: root
    required property real spacing
    required property real dotRadius
    required property var samples
    property real backdropOpacity: 1
    property real excludedColumnX: -1
    property real excludedYStart: -1
    property real excludedYEnd: -1
    readonly property int columns: Math.max(1, Math.floor(width / spacing))
    readonly property int rows: Math.max(1, Math.floor(height / spacing))
    Repeater {
        model: Math.min(2048, root.columns * root.rows)
        Rectangle {
            required property int index
            readonly property real cx: root.spacing / 2 + (index % root.columns) * root.spacing
            readonly property real cy: root.spacing / 2 + Math.floor(index / root.columns) * root.spacing
            x: cx - root.dotRadius
            y: cy - root.dotRadius
            width: root.dotRadius * 2
            height: width
            radius: root.dotRadius
            color: "white"
            visible: !(Math.abs(cx - root.excludedColumnX) < 0.5 && cy >= root.excludedYStart && cy <= root.excludedYEnd)
            opacity: visible ? 0.35 * FluidShape.sample(root.samples, cx, cy, root.backdropOpacity) : 0
        }
    }
}
