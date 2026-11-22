import QtQuick
import "FluidShape.js" as FluidShape
import "PointerLight.js" as PointerLight

// Motion and illumination only; no input surfaces, controls or system services.
QtObject {
    id: root
    required property var preferences
    required property real width
    required property real height
    required property bool shown
    readonly property bool reduced: preferences.motion.reduced
    readonly property int fadeMs: reduced ? 100 : shown ? preferences.timing.emergeMs : preferences.timing.retractMs
    readonly property int followMs: reduced ? 0 : pointerRetreat ? fadeMs : preferences.motion.followMs
    property bool ready: false
    property real proximity: 0
    property real fluidPhase: 0
    property real followX: 0
    property real followY: 0
    property real fieldTravel: width
    property real fieldScale: 1
    property point lastPointer: Qt.point(0, 0)
    property point lastDelta: Qt.point(0, 0)
    property bool pointerSeen: false
    property bool pointerRetreat: false
    readonly property real fieldOffset: reduced ? 0 : fieldTravel
    readonly property real lightScale: reduced ? 1 : fieldScale
    readonly property var shapes: {
        const fluid = FluidShape.describe(fluidPhase, reduced ? 0 : preferences.motion.liquidStrength);
        const shifted = FluidShape.transformed(fluid, reduced ? 0 : followX, reduced ? 0 : followY, lightScale);
        return FluidShape.contained(shifted, width, height, fieldOffset, 2);
    }
    readonly property var samples: FluidShape.prepare(shapes, width, height, preferences.field.feather, fieldOffset)
    readonly property var restingSamples: FluidShape.prepare(FluidShape.describe(0, 0), width, height, preferences.field.feather, 0)
    readonly property bool settling: liquid.running

    Component.onCompleted: {
        ready = true;
        updateTarget();
    }
    onShownChanged: {
        if (ready)
            updateTarget();
    }
    onReducedChanged: {
        if (reduced) {
            liquid.stop();
            fluidPhase = 0;
        }
    }
    function updateTarget(): void {
        proximity = shown ? 1 : 0;
        if (shown || !pointerRetreat)
            fieldTravel = shown ? 0 : width;
        fieldScale = shown || !pointerRetreat ? 1 : preferences.motion.departureScale;
        if (shown)
            settle();
    }
    function settle(): void {
        if (shown && !reduced && preferences.motion.liquidStrength > 0 && !liquid.running) {
            fluidPhase = 0;
            liquid.restart();
        }
    }
    function enterPointer(px: real, py: real): void {
        pointerRetreat = false;
        trackPointer(px, py);
    }
    function trackPointer(px: real, py: real): void {
        if (pointerSeen && Math.abs(px - lastPointer.x) + Math.abs(py - lastPointer.y) > 0.01)
            lastDelta = Qt.point(px - lastPointer.x, py - lastPointer.y);
        lastPointer = Qt.point(px, py);
        pointerSeen = true;
        const next = PointerLight.target(px, py, width, height, preferences.motion.followRange);
        followX = next.x;
        followY = next.y;
    }
    function leavePointer(): void {
        pointerRetreat = true;
        const next = PointerLight.departure(lastPointer.x, lastPointer.y, lastDelta.x, lastDelta.y, width, height, preferences.motion.followRange, preferences.motion.departureDrift);
        followX = next.x;
        followY = next.y;
        pointerSeen = false;
    }
    function controlAt(px: real, py: real): real {
        return Math.min(1, FluidShape.sample(samples, px, py) / Math.max(0.05, FluidShape.sample(restingSamples, px, py)));
    }
    property NumberAnimation liquid: NumberAnimation {
        target: root
        property: "fluidPhase"
        from: 0
        to: Math.PI * 6
        duration: root.preferences.motion.liquidMs
    }
    Behavior on proximity {
        NumberAnimation {
            duration: root.fadeMs
            easing.type: Easing.InOutSine
        }
    }
    Behavior on fieldTravel {
        NumberAnimation {
            duration: root.fadeMs
            easing.type: Easing.InOutSine
        }
    }
    Behavior on fieldScale {
        NumberAnimation {
            duration: root.fadeMs
            easing.type: Easing.InOutSine
        }
    }
    Behavior on followX {
        NumberAnimation {
            duration: root.followMs
            easing.type: Easing.OutCubic
        }
    }
    Behavior on followY {
        NumberAnimation {
            duration: root.followMs
            easing.type: Easing.OutCubic
        }
    }
}
