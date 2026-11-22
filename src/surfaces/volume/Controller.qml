import QtQuick
import "Lifecycle.js" as Lifecycle

QtObject {
    id: root
    required property var preferences
    property string phase: "dormant"
    property bool hovered: false
    property bool dragging: false
    readonly property bool visible: phase !== "dormant"
    readonly property bool interactive: phase === "interactive"
    function refreshIdle(): void {
        idle.stop();
        if (phase === "interactive" && !hovered && !dragging)
            idle.restart();
    }
    function show(): void {
        if (phase === "dormant")
            phase = "emerging";
        else if (phase === "retracting")
            phase = "interactive";
        else
            refreshIdle();
    }
    onHoveredChanged: {
        if (hovered && phase === "retracting")
            show();
        else if (!hovered && !dragging && (phase === "interactive" || phase === "emerging"))
            phase = "retracting";
        refreshIdle();
    }
    onDraggingChanged: {
        if (!dragging && !hovered && phase === "interactive")
            phase = "retracting";
        refreshIdle();
    }
    onPhaseChanged: {
        stage.stop();
        if (phase === "dormant") {
            hovered = false;
            dragging = false;
        } else if (phase !== "interactive") {
            stage.interval = Lifecycle.delay(phase, preferences.timing, preferences.motion.reduced);
            stage.restart();
        }
        refreshIdle();
    }
    property Timer stage: Timer {
        interval: 0
        onTriggered: root.phase = root.phase === "retracting" ? "dormant" : Lifecycle.next(root.phase)
    }
    property Timer idle: Timer {
        interval: root.preferences.timing.idleMs
        onTriggered: root.phase = "retracting"
    }
}
