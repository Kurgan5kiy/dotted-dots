pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "config"
import "services"
import "platform"
import "ipc"
import "surfaces/volume"
import "surfaces/bar"
import "platform/EdgeZones.js" as EdgeZones

ShellRoot {
    id: root
    property bool pendingShow: false
    property int barRevealSerial: 0
    property string barRevealOutput: ""
    Preferences {
        id: settingsService
    }
    NiriFocusAdapter {
        id: focusAdapter
    }
    NiriWorkspaceAdapter {
        id: workspaceService
        niriFocus: focusAdapter
    }
    BatteryService {
        id: batteryService
    }
    TrayService {
        id: trayService
    }
    AudioService {
        id: soundService
        onAudioChanged: {
            if (settingsService.values.triggers.externalAudioChanges)
                root.show(null, "");
        }
        onActionAccepted: root.show(null, "")
    }
    OutputRouter {
        id: outputRouter
        preferences: settingsService.values
        fixedPlacement: osdController.visible
        focusOutput: focusAdapter.ready ? focusAdapter.outputId : ""
        onOutputLost: {
            if (osdController.visible)
                root.pendingShow = true;
            osdController.dragging = false;
        }
        onGeometryChanged: {
            if (root.pendingShow && geometry.usable)
                Qt.callLater(() => root.show(null, ""));
        }
    }
    Controller {
        id: osdController
        preferences: settingsService.values
    }
    function show(screen: var, side: string): void {
        if (screen === null)
            focusAdapter.ensureRunning();
        outputRouter.choose(screen, side);
        if (outputRouter.geometry.usable) {
            pendingShow = false;
            osdController.show();
        } else {
            pendingShow = true;
            console.warn("No usable output for volume OSD");
        }
    }
    VolumeActions {
        audio: soundService
        preferences: settingsService.values
        onShowRequested: root.show(null, "")
    }
    BarActions {
        onRevealRequested: output => {
            root.barRevealOutput = output;
            root.barRevealSerial += 1;
        }
    }
    Variants {
        model: Quickshell.screens
        BarWindow {
            required property ShellScreen modelData
            screen: modelData
            visible: settingsService.values.bar.outputs === "all" || settingsService.values.bar.outputs.indexOf(modelData.name) !== -1
            profile: settingsService.values.bar
            audio: soundService
            battery: batteryService
            tray: trayService
            workspaceAdapter: workspaceService
            outputName: modelData.name
            outputLength: settingsService.values.bar.edge === "left" || settingsService.values.bar.edge === "right" ? modelData.height : modelData.width
            gridSpacing: settingsService.values.field.spacing
            reducedMotion: settingsService.values.motion.reduced
            motionPreferences: settingsService.values.motion
            keyboardRevealSerial: root.barRevealSerial
            keyboardRevealOutput: root.barRevealOutput
            edgeSensorEnabled: settingsService.values.edge.enabled && settingsService.values.bar.edge === EdgeZones.resolveSide(settingsService.values.edge, modelData.name)
            edgeDwellMs: settingsService.values.edge.dwellMs
            osdVisible: osdController.visible
            onVolumeRequested: root.show(modelData, "")
            onVolumeEdgeRequested: side => root.show(modelData, side)
        }
    }
    Variants {
        model: Quickshell.screens
        EdgeSensor {
            required property ShellScreen modelData
            screen: modelData
            outputName: modelData.name
            outputHeight: modelData.height
            preferences: settingsService.values
            suppressed: settingsService.values.bar.outputs === "all" || settingsService.values.bar.outputs.indexOf(modelData.name) !== -1 ? (settingsService.values.bar.edge === EdgeZones.resolveSide(settingsService.values.edge, modelData.name)) : false
            osdVisible: osdController.visible
            onSummoned: side => root.show(modelData, side)
        }
    }
    Loader {
        active: osdController.visible && outputRouter.geometry.usable
        sourceComponent: VolumeOsd {
            audio: soundService
            preferences: settingsService.values
            controller: osdController
            router: outputRouter
        }
    }
}
