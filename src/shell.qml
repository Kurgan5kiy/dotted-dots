pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "config"
import "services"
import "platform"
import "ipc"
import "surfaces/volume"

ShellRoot {
    id: root
    property bool pendingShow: false
    Preferences {
        id: settingsService
    }
    AudioService {
        id: soundService
        onAudioChanged: {
            if (settingsService.values.triggers.externalAudioChanges)
                root.show(null);
        }
        onActionAccepted: root.show(null)
    }
    OutputRouter {
        id: outputRouter
        preferences: settingsService.values
        fixedPlacement: osdController.visible
        onOutputLost: {
            if (osdController.visible)
                root.pendingShow = true;
            osdController.dragging = false;
        }
        onGeometryChanged: {
            if (root.pendingShow && geometry.usable)
                Qt.callLater(() => root.show(null));
        }
    }
    Controller {
        id: osdController
        preferences: settingsService.values
    }
    function show(screen: var): void {
        outputRouter.choose(screen);
        if (outputRouter.geometry.usable) {
            pendingShow = false;
            osdController.show();
        } else {
            pendingShow = true;
            console.warn("No usable output for volume OSD");
        }
        console.debug("OSD request", osdController.phase, JSON.stringify(outputRouter.geometry));
    }
    VolumeActions {
        audio: soundService
        preferences: settingsService.values
        onShowRequested: root.show(null)
    }
    Variants {
        model: Quickshell.screens
        EdgeSensor {
            required property ShellScreen modelData
            screen: modelData
            preferences: settingsService.values
            osdVisible: osdController.visible
            onSummoned: root.show(modelData)
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
