pragma ComponentBehavior: Bound
import QtQuick
import "../../visual"
import "../../visual/PointerLight.js" as PointerLight
import "Lattice.js" as Lattice

Item {
    id: root
    required property var motion
    required property bool reducedMotion
    required property bool vertical
    required property real hostWidth
    required property real hostHeight
    property string edge: "top"
    property real spacing: 18
    property var workspaceNodes: []
    property var dotExclusions: []
    property bool lit: false
    property bool pointerSeen: false
    property point lastPointer: Qt.point(0, 0)
    property point lastDelta: Qt.point(0, 0)
    property real centerX: hostWidth / 2
    property real centerY: hostHeight / 2
    property real strength: 1
    property real driftAlong: 0
    property real driftDepth: 0
    property bool animateOpacity: true
    property bool animatePosition: true
    property real dotGain: 0.35
    property int fadeMs: 240
    readonly property int followDurationMs: motion.followMs === 0 ? 0 : Math.max(420, Math.min(650, Math.round(motion.followMs * 3)))
    readonly property real crossCenter: vertical ? centerX + (edge === "right" ? -driftDepth : driftDepth) : centerY + (edge === "bottom" ? -driftDepth : driftDepth)
    readonly property real crossRadius: Math.max(1, vertical ? (edge === "right" ? crossCenter : hostWidth - crossCenter) : (edge === "bottom" ? crossCenter : hostHeight - crossCenter))
    width: vertical ? crossRadius * 2 : 390
    height: vertical ? 390 : crossRadius * 2
    x: centerX - width / 2 + (vertical ? (edge === "right" ? -driftDepth : driftDepth) : driftAlong)
    y: centerY - height / 2 + (vertical ? driftAlong : (edge === "bottom" ? -driftDepth : driftDepth))
    opacity: lit ? 0.95 * strength : 0
    onXChanged: dots.requestPaint()
    onYChanged: dots.requestPaint()
    onSpacingChanged: dots.requestPaint()
    onEdgeChanged: dots.requestPaint()
    onWorkspaceNodesChanged: {
        if (opacity > 0)
            dots.requestPaint();
    }
    onDotExclusionsChanged: dots.requestPaint()
    onHostWidthChanged: dots.requestPaint()
    onHostHeightChanged: dots.requestPaint()

    function enter(px: real, py: real): void {
        pointerSeen = true;
        lastPointer = Qt.point(px, py);
        lastDelta = Qt.point(0, 0);
        centerX = px;
        centerY = py;
        lit = true;
    }
    function track(px: real, py: real): void {
        if (!pointerSeen)
            return;
        lastDelta = Qt.point(px - lastPointer.x, py - lastPointer.y);
        lastPointer = Qt.point(px, py);
        if (!reducedMotion) {
            centerX = px;
            centerY = py;
        }
    }
    function leave(): void {
        if (!pointerSeen)
            return;
        if (!reducedMotion) {
            const drift = PointerLight.departure(lastPointer.x, lastPointer.y, lastDelta.x, lastDelta.y, hostWidth, hostHeight, 0, motion.departureDrift);
            centerX = Math.max(-motion.departureDrift, Math.min(hostWidth + motion.departureDrift, lastPointer.x + drift.x));
            centerY = Math.max(-motion.departureDrift, Math.min(hostHeight + motion.departureDrift, lastPointer.y + drift.y));
        }
        pointerSeen = false;
        lit = false;
    }
    FeatheredBackdrop {
        anchors.fill: parent
        feather: Math.min(root.width, root.height) * 0.40
        fillColor: "#181818"
    }
    Canvas {
        id: dots
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (root.spacing <= 0)
                return;
            const firstX = root.edge === "right" ? root.hostWidth - root.spacing / 2 : root.spacing / 2;
            const firstY = root.edge === "bottom" ? root.hostHeight - root.spacing / 2 : root.spacing / 2;
            const startX = Math.floor((root.x - firstX) / root.spacing);
            const endX = Math.ceil((root.x + width - firstX) / root.spacing);
            const startY = Math.floor((root.y - firstY) / root.spacing);
            const endY = Math.ceil((root.y + height - firstY) / root.spacing);
            for (let row = startY; row <= endY; row++) {
                const globalY = firstY + row * root.spacing;
                if (globalY < 0 || globalY >= root.hostHeight)
                    continue;
                for (let column = startX; column <= endX; column++) {
                    const globalX = firstX + column * root.spacing;
                    if (globalX < 0 || globalX >= root.hostWidth || Lattice.isOccupied(globalX, globalY, root.workspaceNodes) || Lattice.isCovered(globalX, globalY, root.dotExclusions))
                        continue;
                    const x = globalX - root.x;
                    const y = globalY - root.y;
                    const distance = Math.sqrt(Math.pow((x - width / 2) / (width / 2), 2) + Math.pow((y - height / 2) / (height / 2), 2));
                    const t = Math.max(0, Math.min(1, (distance - 0.18) / 0.82));
                    const alpha = 1 - t * t * (3 - 2 * t);
                    if (alpha < 0.015)
                        continue;
                    ctx.fillStyle = "rgba(255,255,255," + (root.dotGain * alpha) + ")";
                    ctx.beginPath();
                    ctx.arc(x, y, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                }
            }
        }
    }
    Behavior on centerX {
        enabled: root.animatePosition
        NumberAnimation {
            duration: root.reducedMotion ? 0 : root.followDurationMs
            easing.type: Easing.OutSine
        }
    }
    Behavior on centerY {
        enabled: root.animatePosition
        NumberAnimation {
            duration: root.reducedMotion ? 0 : root.followDurationMs
            easing.type: Easing.OutSine
        }
    }
    Behavior on opacity {
        enabled: root.animateOpacity
        NumberAnimation {
            duration: root.reducedMotion ? 100 : root.fadeMs
            easing.type: Easing.InOutSine
        }
    }
}
