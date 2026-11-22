pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    required property real feather
    required property var shapes
    property real offset: 0
    property color fillColor: "#181818"
    property real centerOpacity: 1
    Repeater {
        model: 3
        Item {
            id: layer
            required property int index
            readonly property var shape: root.shapes[index]
            width: root.width * 2
            height: root.height
            x: root.offset + shape.x
            y: shape.y
            opacity: shape.opacity * root.centerOpacity
            transform: Scale {
                origin.x: root.width
                origin.y: root.height / 2
                xScale: layer.shape.sx
                yScale: layer.shape.sy
            }
            FeatheredBackdrop {
                anchors.fill: parent
                feather: root.feather
                fillColor: root.fillColor
            }
        }
    }
}
