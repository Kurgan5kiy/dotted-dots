pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    required property int zoneIndex
    required property bool vertical
    required property bool active
    required property string edge
    required property real spacing
    required property real hostWidth
    required property real hostHeight
    required property var workspaceNodes
    property var dotExclusions: []
    required property var motion
    property bool ready: false
    property bool lit: false
    property real alongPoint: 0
    property real basePoint: 0
    property real fieldLength: 460
    property real fieldStrength: 0.5
    property real phase: zoneIndex * Math.PI / 2
    readonly property int periodMs: 3300 + zoneIndex * 450 + Math.floor(Math.random() * 1100)
    readonly property real travelLength: vertical ? hostHeight : hostWidth
    readonly property real depthPoint: vertical ? (edge === "right" ? hostWidth + 8 : -8) : (edge === "bottom" ? hostHeight + 8 : -8)
    width: hostWidth
    height: hostHeight

    function chooseRegion(): void {
        basePoint = travelLength * (zoneIndex + 0.04 + Math.random() * 0.92) / 4;
        alongPoint = basePoint;
        fieldLength = Math.min(560, Math.max(300, travelLength * (0.22 + Math.random() * 0.17)));
    }
    onActiveChanged: {
        if (!ready)
            return;
        if (active) {
            chooseRegion();
            lit = true;
        } else {
            lit = false;
        }
    }
    Component.onCompleted: {
        ready = true;
        if (active) {
            chooseRegion();
            lit = true;
        }
    }

    BarHoverLight {
        vertical: root.vertical
        edge: root.edge
        spacing: root.spacing
        workspaceNodes: root.workspaceNodes
        dotExclusions: root.dotExclusions
        hostWidth: root.hostWidth
        hostHeight: root.hostHeight
        motion: root.motion
        reducedMotion: !root.active
        animatePosition: false
        animateOpacity: false
        dotGain: 0.60
        lit: root.lit
        strength: root.fieldStrength
        width: root.vertical ? crossRadius * 2 : root.fieldLength
        height: root.vertical ? root.fieldLength : crossRadius * 2
        centerX: root.vertical ? root.depthPoint : root.alongPoint
        centerY: root.vertical ? root.alongPoint : root.depthPoint
    }
    Timer {
        interval: 160
        running: root.active
        repeat: true
        onTriggered: {
            const previous = root.phase;
            root.phase += interval * Math.PI * 2 / root.periodMs;
            if (Math.floor((previous - Math.PI * 1.5) / (Math.PI * 2)) !== Math.floor((root.phase - Math.PI * 1.5) / (Math.PI * 2)))
                root.chooseRegion();
            root.fieldStrength = 0.5 + 0.5 * Math.sin(root.phase);
            root.alongPoint = root.basePoint + root.spacing * (1.0 * Math.sin(root.phase * 0.67 + root.zoneIndex) + 0.45 * Math.sin(root.phase * 1.9));
        }
    }
}
