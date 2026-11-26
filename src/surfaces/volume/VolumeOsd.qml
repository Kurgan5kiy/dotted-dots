import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var preferences
    required property var audio
    required property var controller
    required property var router
    screen: router.selected
    visible: controller.visible && router.geometry.usable
    anchors {
        top: true
        left: true
    }
    margins.left: router.geometry.x
    margins.top: router.geometry.y
    implicitWidth: Math.max(1, router.geometry.width)
    implicitHeight: Math.max(1, router.geometry.height)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "dot-shell-volume"
    VolumeField {
        anchors.fill: parent
        preferences: root.preferences
        audio: root.audio
        controller: root.controller
        side: root.router.side
    }
}
