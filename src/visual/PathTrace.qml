import QtQuick

Item {
    id: root
    property real progress: 0
    property bool vertical: false
    property bool showHead: true
    property real strokeWidth: 2
    property var illumination: null
    function lightAt(px: real, py: real): real {
        return illumination === null ? 1 : illumination(px, py);
    }
    Rectangle {
        id: line
        x: root.vertical ? (parent.width - width) / 2 : parent.width - width
        y: root.vertical ? parent.height - height : (parent.height - height) / 2
        width: root.vertical ? root.strokeWidth : parent.width * root.progress
        height: root.vertical ? parent.height * root.progress : root.strokeWidth
        gradient: Gradient {
            orientation: root.vertical ? Gradient.Vertical : Gradient.Horizontal
            GradientStop {
                position: 0
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x, line.y))
            }
            GradientStop {
                position: 0.125
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width * 0.125, line.y + line.height * 0.125))
            }
            GradientStop {
                position: 0.25
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width * 0.25, line.y + line.height * 0.25))
            }
            GradientStop {
                position: 0.375
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width * 0.375, line.y + line.height * 0.375))
            }
            GradientStop {
                position: 0.5
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width * 0.5, line.y + line.height * 0.5))
            }
            GradientStop {
                position: 0.625
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width * 0.625, line.y + line.height * 0.625))
            }
            GradientStop {
                position: 0.75
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width * 0.75, line.y + line.height * 0.75))
            }
            GradientStop {
                position: 0.875
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width * 0.875, line.y + line.height * 0.875))
            }
            GradientStop {
                position: 1
                color: Qt.rgba(1, 1, 1, root.lightAt(line.x + line.width, line.y + line.height))
            }
        }
    }
    Rectangle {
        x: root.vertical ? (parent.width - width) / 2 : parent.width * (1 - root.progress) - width / 2
        y: root.vertical ? parent.height * (1 - root.progress) - height / 2 : (parent.height - height) / 2
        width: 6
        height: 6
        radius: 3
        color: "white"
        visible: root.showHead
        opacity: root.lightAt(x + width / 2, y + height / 2)
    }
}
