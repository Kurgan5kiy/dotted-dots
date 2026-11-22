import QtQuick

Item {
    id: root
    required property bool muted
    required property bool reducedMotion
    signal toggled
    implicitWidth: 32
    implicitHeight: 32
    Rectangle {
        anchors.centerIn: parent
        width: 8
        height: 8
        radius: 4
        antialiasing: true
        scale: root.muted ? 0.75 : 1
        color: root.muted ? "#999999" : "white"
        Behavior on color {
            ColorAnimation {
                duration: root.reducedMotion ? 0 : 120
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: root.reducedMotion ? 0 : 120
                easing.type: Easing.OutCubic
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
