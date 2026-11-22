import QtQuick

Item {
    id: root
    property real progress: 0
    property bool vertical: false
    property bool showHead: true
    Rectangle {
        x: root.vertical ? (parent.width - width) / 2 : parent.width - width
        y: root.vertical ? parent.height - height : (parent.height - height) / 2
        width: root.vertical ? 1 : parent.width * root.progress
        height: root.vertical ? parent.height * root.progress : 1
        color: "#dddddd"
    }
    Rectangle {
        x: root.vertical ? (parent.width - width) / 2 : parent.width * (1 - root.progress) - width / 2
        y: root.vertical ? parent.height * (1 - root.progress) - height / 2 : (parent.height - height) / 2
        width: 6
        height: 6
        radius: 3
        color: "white"
        visible: root.showHead
    }
}
