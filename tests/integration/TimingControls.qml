import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Observation/reset controls in a private copy; not a production IPC target.
Scope {
    id: root
    required property var settings
    required property var controller
    required property var audio
    required property var router
    required property var surface
    property int summons: 0
    Connections {
        target: root.controller
        function onPhaseChanged(): void {
            if (root.controller.phase === "emerging")
                root.summons++;
        }
    }
    IpcHandler {
        target: "timing_test"
        function state(): string {
            return JSON.stringify({
                audio: root.audio.snapshot(),
                phase: root.controller.phase,
                count: root.summons,
                loaded: root.surface.item !== null,
                geometry: root.router.geometry,
                dwellMs: root.settings.values.edge.dwellMs,
                emergeMs: root.settings.values.timing.emergeMs,
                reduced: root.settings.values.motion.reduced,
                fixtureFullscreen: fixture.visibility === Window.FullScreen,
                fixtureWidth: fixture.width,
                fixtureHeight: fixture.height
            });
        }
        function reset(automatic: bool, edge: bool): void {
            const values = JSON.parse(JSON.stringify(root.settings.values));
            values.triggers.externalAudioChanges = automatic;
            values.edge.enabled = edge;
            root.settings.values = values;
            root.controller.phase = "dormant";
        }
    }
    Window {
        id: fixture
        title: "Dot Shell timing fixture"
        color: "white"
        visibility: Window.FullScreen
        flags: Qt.Window | Qt.WindowDoesNotAcceptFocus | Qt.WindowTransparentForInput
    }
    PanelWindow {
        screen: root.router.selected
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "white"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "dot-shell-timing-fixture"
    }
    Timer {
        interval: 120000
        running: true
        onTriggered: Qt.quit()
    }
}
