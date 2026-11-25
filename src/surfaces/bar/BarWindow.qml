pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "Layout.js" as BarGeometry
import "ModuleAccent.js" as ModuleAccent
import "Lattice.js" as Lattice
import "RevealState.js" as RevealState
import "../../widgets/bar"
import "../../platform/EdgeZones.js" as EdgeZones

PanelWindow {
    id: root
    required property var profile
    required property var audio
    required property var battery
    required property var tray
    required property var workspaceAdapter
    required property bool reducedMotion
    required property var motionPreferences
    required property bool edgeSensorEnabled
    required property int edgeDwellMs
    required property bool osdVisible
    required property int keyboardRevealSerial
    required property string keyboardRevealOutput
    required property string outputName
    required property real outputLength
    required property real gridSpacing
    signal volumeRequested
    signal volumeEdgeRequested(string side)
    readonly property bool vertical: profile.edge === "left" || profile.edge === "right"
    readonly property bool automatic: profile.visibility === "auto"
    readonly property real reserveDepth: Math.max(32, profile.thickness - 12, gridSpacing)
    readonly property real tileReserveDepth: Math.max(24, profile.thickness - 24, gridSpacing)
    readonly property real visualDepth: profile.thickness + 30
    property string revealPhase: RevealState.initial(automatic)
    readonly property bool revealed: RevealState.shown(revealPhase)
    property int openMenus: 0
    property bool overflowOpen: false
    readonly property var enabledWidgets: profile.widgets.filter(entry => entry.enabled && (entry.type !== "battery" || battery.available))
    readonly property var arrangement: BarGeometry.arrange(enabledWidgets, outputLength, vertical, workspaceAdapter.forOutput(outputName).length, tray.items.count || 0)
    readonly property var accentRegions: {
        if (!root.arrangement)
            return [];
        const positions = [startGroup.x, startGroup.y, centerGroup.x, centerGroup.y, endGroup.x, endGroup.y];
        if (positions.some(value => !Number.isFinite(value)))
            return [];
        return startGroup.moduleRegions(barField).concat(centerGroup.moduleRegions(barField), endGroup.moduleRegions(barField));
    }
    property real accentPhase: 0
    function group(name: string): var {
        return arrangement.visible.filter(entry => entry.group === name);
    }
    function menuState(open: bool): void {
        openMenus = Math.max(0, openMenus + (open ? 1 : -1));
        if (open) {
            hideTimer.stop();
            revealTimer.stop();
            revealPhase = RevealState.hold(revealPhase);
        } else
            beginHide();
    }
    function beginHide(): void {
        if (!automatic || hover.hovered || content.activeFocus || openMenus > 0)
            return;
        revealPhase = RevealState.release(revealPhase);
        if (revealPhase === "hiding")
            hideTimer.restart();
    }
    function reveal(): void {
        hideTimer.stop();
        revealPhase = RevealState.enter(revealPhase);
        if (revealPhase === "revealing")
            revealTimer.restart();
    }
    function crossOffset(size: real): real {
        const inward = profile.edge === "bottom" || profile.edge === "right";
        const windowDepth = vertical ? width : height;
        return (inward ? windowDepth - reserveDepth : 0) + (reserveDepth - size) / 2;
    }
    function workspaceNodes(): var {
        if (!workspaceAdapter.workspaces)
            return [];
        const positions = [startGroup.x, startGroup.y, centerGroup.x, centerGroup.y, endGroup.x, endGroup.y];
        if (positions.some(value => !Number.isFinite(value)))
            return [];
        return startGroup.workspaceNodes(barField).concat(centerGroup.workspaceNodes(barField), endGroup.workspaceNodes(barField));
    }
    function dotExclusions(): var {
        const positions = [startGroup.x, startGroup.y, centerGroup.x, centerGroup.y, endGroup.x, endGroup.y];
        if (positions.some(value => !Number.isFinite(value)))
            return [];
        return startGroup.dotExclusions(barField).concat(centerGroup.dotExclusions(barField), endGroup.dotExclusions(barField));
    }
    onKeyboardRevealSerialChanged: {
        if (root.keyboardRevealSerial > 0 && (root.keyboardRevealOutput === "" || root.keyboardRevealOutput === root.outputName)) {
            root.revealPhase = RevealState.hold(root.revealPhase);
            hideTimer.restart();
        }
    }
    anchors {
        top: profile.edge === "top" || vertical
        bottom: profile.edge === "bottom" || vertical
        left: profile.edge === "left" || !vertical
        right: profile.edge === "right" || !vertical
    }
    implicitWidth: vertical ? (automatic && !revealed ? 2 : visualDepth) : 1
    implicitHeight: vertical ? 1 : (automatic && !revealed ? 2 : visualDepth)
    exclusiveZone: automatic ? 0 : tileReserveDepth
    mask: Region {
        x: root.profile.edge === "right" ? Math.max(0, root.width - root.reserveDepth) : 0
        y: root.profile.edge === "bottom" ? Math.max(0, root.height - root.reserveDepth) : 0
        width: root.vertical ? Math.min(root.width, root.reserveDepth) : root.width
        height: root.vertical ? root.height : Math.min(root.height, root.reserveDepth)
    }
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "dot-shell-bar"
    onAutomaticChanged: revealPhase = RevealState.initial(automatic)
    Timer {
        id: revealTimer
        interval: root.profile.revealMs
        onTriggered: root.revealPhase = RevealState.elapsed(root.revealPhase)
    }
    Timer {
        id: hideTimer
        interval: root.profile.hideMs
        onTriggered: {
            if (root.automatic)
                root.revealPhase = RevealState.dismiss(root.revealPhase, hover.hovered || content.activeFocus || root.openMenus > 0);
        }
    }
    Timer {
        interval: 160
        running: root.revealed && !root.reducedMotion
        repeat: true
        onTriggered: root.accentPhase += interval * Math.PI * 2 / 7800
    }
    HoverHandler {
        id: hover
        onPointChanged: {
            if (hovered)
                barLight.track(point.position.x, point.position.y);
        }
        onHoveredChanged: {
            if (hovered)
                barLight.enter(point.position.x, point.position.y);
            else
                barLight.leave();
            if (!root.automatic)
                return;
            if (hovered)
                root.reveal();
            else {
                revealTimer.stop();
                root.beginHide();
            }
        }
    }
    Item {
        anchors.fill: parent
        clip: true
        Timer {
            id: edgeDwell
            interval: root.edgeDwellMs
            onTriggered: {
                if (!root.osdVisible)
                    root.volumeEdgeRequested(root.profile.edge);
            }
        }
        MouseArea {
            id: middleSensor
            z: 10
            visible: root.vertical && root.edgeSensorEnabled
            width: 2
            height: EdgeZones.bounds(parent.height).middleHeight
            x: root.profile.edge === "right" ? parent.width - width : 0
            y: EdgeZones.bounds(parent.height).middleTop
            hoverEnabled: true
            onEntered: {
                if (!root.osdVisible)
                    edgeDwell.restart();
            }
            onExited: edgeDwell.stop()
        }
        BarField {
            id: barField
            anchors.fill: parent
            edge: root.profile.edge
            spacing: root.gridSpacing
            workspaceNodes: root.workspaceNodes()
            dotExclusions: root.dotExclusions()
            opacity: root.automatic && !root.revealed ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: root.reducedMotion ? 80 : root.profile.revealMs
                }
            }
        }
        Repeater {
            model: root.accentRegions
            delegate: BarHoverLight {
                required property var modelData
                required property int index
                readonly property real accentDepth: ModuleAccent.depth(root.reserveDepth, root.visualDepth, root.gridSpacing, modelData.kind)
                vertical: root.vertical
                edge: root.profile.edge
                spacing: root.gridSpacing
                workspaceNodes: barField.workspaceNodes
                dotExclusions: barField.dotExclusions
                hostWidth: root.width
                hostHeight: root.height
                motion: root.motionPreferences
                reducedMotion: root.reducedMotion
                animatePosition: false
                animateOpacity: false
                dotGain: 0.25
                lit: root.revealed
                strength: (root.reducedMotion ? 0.32 : 0.30 + 0.09 * Math.sin(root.accentPhase + index * 0.85)) + (modelData.kind === "clock" ? 0.08 : 0)
                width: root.vertical ? 2 * (accentDepth + 8) : ModuleAccent.length(modelData, root.gridSpacing)
                height: root.vertical ? ModuleAccent.length(modelData, root.gridSpacing) : 2 * (accentDepth + 8)
                centerX: root.vertical ? (root.profile.edge === "right" ? root.width + 8 : -8) : (modelData.start + modelData.end) / 2
                centerY: root.vertical ? (modelData.start + modelData.end) / 2 : (root.profile.edge === "bottom" ? root.height + 8 : -8)
            }
        }
        Repeater {
            model: 4
            delegate: BarAmbientPatch {
                required property int index
                zoneIndex: index
                vertical: root.vertical
                active: root.revealed && !root.reducedMotion
                edge: root.profile.edge
                spacing: root.gridSpacing
                workspaceNodes: barField.workspaceNodes
                dotExclusions: barField.dotExclusions
                hostWidth: root.width
                hostHeight: root.height
                motion: root.motionPreferences
            }
        }
        BarHoverLight {
            id: barLight
            vertical: root.vertical
            edge: root.profile.edge
            spacing: root.gridSpacing
            workspaceNodes: barField.workspaceNodes
            dotExclusions: barField.dotExclusions
            hostWidth: root.width
            hostHeight: root.height
            motion: root.motionPreferences
            reducedMotion: root.reducedMotion
        }
        FocusScope {
            id: content
            anchors.fill: parent
            onActiveFocusChanged: {
                if (activeFocus) {
                    root.revealPhase = RevealState.hold(root.revealPhase);
                    hideTimer.stop();
                } else
                    root.beginHide();
            }
            opacity: root.automatic && !root.revealed ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: root.reducedMotion ? 80 : root.profile.revealMs
                }
            }
            BarLayout {
                id: startGroup
                entries: root.group("start")
                vertical: root.vertical
                edge: root.profile.edge
                gridSpacing: root.gridSpacing
                reserveDepth: root.reserveDepth
                audio: root.audio
                battery: root.battery
                tray: root.tray
                workspaceAdapter: root.workspaceAdapter
                outputName: root.outputName
                x: root.vertical ? root.crossOffset(width) : 0
                y: root.vertical ? 0 : root.crossOffset(height)
                onVolumeRequested: root.volumeRequested()
                onMenuStateChanged: open => root.menuState(open)
            }
            BarLayout {
                id: centerGroup
                entries: root.group("center")
                vertical: root.vertical
                edge: root.profile.edge
                gridSpacing: root.gridSpacing
                reserveDepth: root.reserveDepth
                audio: root.audio
                battery: root.battery
                tray: root.tray
                workspaceAdapter: root.workspaceAdapter
                outputName: root.outputName
                x: root.vertical ? root.crossOffset(width) : Lattice.snapStart((content.width - width) / 2, root.gridSpacing)
                y: root.vertical ? Lattice.snapStart((content.height - height) / 2, root.gridSpacing) : root.crossOffset(height)
                onVolumeRequested: root.volumeRequested()
                onMenuStateChanged: open => root.menuState(open)
            }
            BarLayout {
                id: endGroup
                entries: root.group("end")
                vertical: root.vertical
                edge: root.profile.edge
                gridSpacing: root.gridSpacing
                reserveDepth: root.reserveDepth
                audio: root.audio
                battery: root.battery
                tray: root.tray
                workspaceAdapter: root.workspaceAdapter
                outputName: root.outputName
                x: root.vertical ? root.crossOffset(width) : root.arrangement.overflow.length ? overflowButton.x - root.gridSpacing - width : Lattice.snapEnd(content.width - width, root.gridSpacing)
                y: root.vertical ? (root.arrangement.overflow.length ? overflowButton.y - root.gridSpacing - height : Lattice.snapEnd(content.height - height, root.gridSpacing)) : root.crossOffset(height)
                onVolumeRequested: root.volumeRequested()
                onMenuStateChanged: open => root.menuState(open)
            }
            Rectangle {
                id: overflowButton
                activeFocusOnTab: true
                visible: root.arrangement.overflow.length > 0
                width: root.reserveDepth
                height: root.reserveDepth
                radius: 18
                color: "#44ffffff"
                x: root.vertical ? root.crossOffset(width) : Lattice.snapEnd(content.width - width, root.gridSpacing)
                y: root.vertical ? Lattice.snapEnd(content.height - height, root.gridSpacing) : root.crossOffset(height)
                Text {
                    anchors.centerIn: parent
                    text: "⋯"
                    color: "white"
                    font.pixelSize: 18
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.overflowOpen = !root.overflowOpen
                }
                Keys.onReturnPressed: root.overflowOpen = !root.overflowOpen
                Keys.onSpacePressed: root.overflowOpen = !root.overflowOpen
            }
        }
    }
    PopupWindow {
        id: overflowPopup
        anchor.window: root
        anchor.item: overflowButton
        visible: root.overflowOpen && root.arrangement.overflow.length > 0
        implicitWidth: 180
        implicitHeight: Math.min(360, overflowColumn.implicitHeight + 16)
        color: "#ee181818"
        grabFocus: true
        onVisibleChanged: {
            root.menuState(visible);
            if (!visible)
                root.overflowOpen = false;
        }
        Flickable {
            anchors.fill: parent
            anchors.margins: 8
            contentHeight: overflowColumn.implicitHeight
            clip: true
            Column {
                id: overflowColumn
                spacing: 8
                Repeater {
                    model: root.arrangement.overflow
                    delegate: BarWidget {
                        required property var modelData
                        kind: modelData.type
                        vertical: false
                        edge: root.profile.edge
                        gridSpacing: root.gridSpacing
                        reserveDepth: root.reserveDepth
                        audio: root.audio
                        battery: root.battery
                        tray: root.tray
                        workspaceAdapter: root.workspaceAdapter
                        outputName: root.outputName
                        onVolumeRequested: root.volumeRequested()
                        onMenuStateChanged: open => root.menuState(open)
                    }
                }
            }
        }
    }
}
