pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "WorkspaceDisplay.js" as WorkspaceDisplay
import "../../surfaces/bar/Lattice.js" as Lattice
import "../../services/TrayState.js" as TrayState
import "FontChoice.js" as FontChoice

Item {
    id: root
    required property string kind
    required property bool vertical
    required property string edge
    required property real gridSpacing
    required property real reserveDepth
    required property var audio
    required property var battery
    required property var tray
    required property var workspaceAdapter
    required property string outputName
    signal volumeRequested
    signal menuStateChanged(bool open)
    readonly property int workspaceCount: kind === "workspaces" ? workspaceAdapter.forOutput(outputName).length : 0
    implicitWidth: vertical ? reserveDepth : kind === "workspaces" ? (workspaceCount + 1) * gridSpacing : Math.max(gridSpacing, Math.ceil((content.implicitWidth + 12) / gridSpacing) * gridSpacing)
    implicitHeight: vertical ? (kind === "workspaces" ? (workspaceCount + 1) * gridSpacing : Math.max(gridSpacing, Math.ceil((content.implicitHeight + 8) / gridSpacing) * gridSpacing)) : reserveDepth

    function workspaceNodeLocal(index: int): point {
        return vertical ? Qt.point(content.x + gridSpacing / 2, content.y + Lattice.node(index, gridSpacing)) : Qt.point(content.x + Lattice.node(index, gridSpacing), content.y + gridSpacing / 2);
    }
    function dotExclusion(target: var): var {
        if (kind !== "clock" || content.width <= 0 || content.height <= 0)
            return null;
        const origin = content.mapToItem(target, 0, 0);
        const padX = vertical ? 3 : gridSpacing;
        const padY = vertical ? gridSpacing : 3;
        return {
            x: origin.x - padX,
            y: origin.y - padY,
            width: content.width + 2 * padX,
            height: content.height + 2 * padY
        };
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    Grid {
        id: content
        x: root.kind === "workspaces" ? (root.vertical ? Lattice.crossCellOffset(root.edge, root.reserveDepth, root.gridSpacing) : root.gridSpacing) : root.vertical ? Lattice.contentCrossOffset(root.edge, root.reserveDepth, root.gridSpacing, width) : (root.width - width) / 2
        y: root.kind === "workspaces" ? (root.vertical ? root.gridSpacing : Lattice.crossCellOffset(root.edge, root.reserveDepth, root.gridSpacing)) : root.vertical ? (root.height - height) / 2 : Lattice.contentCrossOffset(root.edge, root.reserveDepth, root.gridSpacing, height)
        columns: root.vertical ? 1 : 100
        rowSpacing: root.kind === "workspaces" ? 0 : 4
        columnSpacing: root.kind === "workspaces" ? 0 : 5
        Repeater {
            model: root.kind === "workspaces" ? root.workspaceAdapter.forOutput(root.outputName) : []
            delegate: Rectangle {
                id: workspaceItem
                required property var modelData
                activeFocusOnTab: true
                width: root.gridSpacing
                height: root.gridSpacing
                color: "transparent"
                property bool showNumber: false
                function showActivatedNumber(): void {
                    if (WorkspaceDisplay.shouldFlash(modelData.id, root.workspaceAdapter.activatedWorkspaceId, root.workspaceAdapter.activatedAtMs, Date.now())) {
                        showNumber = true;
                        numberTimer.restart();
                    } else {
                        showNumber = false;
                        numberTimer.stop();
                    }
                }
                Component.onCompleted: {
                    showActivatedNumber();
                }
                Connections {
                    target: root.workspaceAdapter
                    function onActivationSerialChanged() {
                        workspaceItem.showActivatedNumber();
                    }
                }
                Timer {
                    id: numberTimer
                    interval: 900
                    onTriggered: workspaceItem.showNumber = false
                }
                Rectangle {
                    objectName: "workspaceDot"
                    anchors.centerIn: parent
                    visible: !workspaceItem.showNumber
                    width: workspaceItem.modelData.is_active ? 8 : 5
                    height: width
                    radius: width / 2
                    color: workspaceItem.modelData.is_active ? "#ffffff" : "#b8ffffff"
                }
                Text {
                    objectName: "workspaceNumber"
                    anchors.centerIn: parent
                    visible: workspaceItem.showNumber
                    text: String(workspaceItem.modelData.idx)
                    color: "white"
                    font.family: FontChoice.choose(Qt.fontFamilies())
                    font.weight: Font.Light
                    font.pixelSize: 11
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.workspaceAdapter.activate(root.outputName, workspaceItem.modelData)
                }
                Keys.onReturnPressed: root.workspaceAdapter.activate(root.outputName, workspaceItem.modelData)
                Keys.onSpacePressed: root.workspaceAdapter.activate(root.outputName, workspaceItem.modelData)
            }
        }
        Text {
            objectName: "clockText"
            visible: root.kind === "clock"
            text: visible ? Qt.formatTime(clock.date, "HH:mm") : ""
            color: "white"
            font.family: FontChoice.choose(Qt.fontFamilies())
            font.weight: Font.Light
            font.pixelSize: 16
        }
        Text {
            visible: root.kind === "volume"
            activeFocusOnTab: true
            text: root.audio.available ? (root.vertical ? String(Math.round(root.audio.percent)) : (root.audio.muted ? "◌ " : "◖ ") + Math.round(root.audio.percent) + "%") : "◌"
            color: root.audio.available ? "white" : "#88ffffff"
            font.pixelSize: 13
            MouseArea {
                anchors.fill: parent
                onClicked: root.volumeRequested()
            }
            Keys.onReturnPressed: root.volumeRequested()
            Keys.onSpacePressed: root.volumeRequested()
        }
        Text {
            visible: root.kind === "battery" && root.battery.available
            text: root.vertical ? String(root.battery.percent) : (root.battery.charging ? "⚡ " : "▰ ") + root.battery.percent + "%"
            color: "white"
            font.pixelSize: 13
        }
        Repeater {
            model: root.kind === "tray" ? root.tray.items : null
            delegate: Item {
                id: trayItem
                required property var modelData
                activeFocusOnTab: true
                width: 28
                height: 28
                Image {
                    id: trayIcon
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: trayItem.modelData.icon.startsWith("image://") ? trayItem.modelData.icon : Quickshell.iconPath(trayItem.modelData.icon)
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.centerIn: parent
                    visible: trayIcon.status === Image.Error
                    text: trayItem.modelData.title.slice(0, 1).toUpperCase()
                    color: "white"
                    font.pixelSize: 13
                }
                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.menu
                    anchor.item: trayItem
                    onOpened: root.menuStateChanged(true)
                    onClosed: root.menuStateChanged(false)
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (TrayState.action(mouse.button === Qt.RightButton, trayItem.modelData.onlyMenu, trayItem.modelData.hasMenu) === "menu")
                            menuAnchor.open();
                        else
                            trayItem.modelData.activate();
                    }
                }
                Keys.onReturnPressed: {
                    if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu)
                        menuAnchor.open();
                    else
                        trayItem.modelData.activate();
                }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Menu && trayItem.modelData.hasMenu) {
                        menuAnchor.open();
                        event.accepted = true;
                    }
                }
            }
        }
    }
}
