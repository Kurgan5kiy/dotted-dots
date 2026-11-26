pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import "WorkspaceModel.js" as WorkspaceModel

QtObject {
    id: root
    required property var niriFocus
    readonly property var workspaces: niriFocus.workspaceSnapshot
    readonly property int activationSerial: niriFocus.activationSerial
    readonly property int activatedWorkspaceId: niriFocus.activatedWorkspaceId
    readonly property real activatedAtMs: niriFocus.activatedAtMs
    property string pendingOutput: ""
    property string pendingReference: ""

    function forOutput(name: string): var {
        return WorkspaceModel.forOutput(workspaces, name);
    }

    function activate(output: string, workspace: var): void {
        const reference = WorkspaceModel.reference(output, workspace);
        if (reference === null)
            return;
        pendingOutput = output;
        pendingReference = reference;
        monitorAction.command = ["niri", "msg", "action", "focus-monitor", output];
        monitorAction.running = true;
    }

    property Process monitorAction: Process {
        onExited: (code, status) => {
            if (code === 0 && root.pendingReference.length > 0) {
                root.workspaceAction.command = ["niri", "msg", "action", "focus-workspace", root.pendingReference];
                root.workspaceAction.running = true;
            }
            root.pendingReference = "";
        }
    }
    property Process workspaceAction: Process {}
}
