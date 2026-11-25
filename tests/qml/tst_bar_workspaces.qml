import QtQuick
import QtTest
import "../../src/platform/WorkspaceModel.js" as WorkspaceModel

TestCase {
    name: "BarWorkspaces"
    function test_outputScopeOrderAndReference() {
        const workspaces = {
            9: {
                id: 9,
                idx: 3,
                output: "eDP-1",
                name: null
            },
            3: {
                id: 3,
                idx: 1,
                output: "HDMI-A-1",
                name: "chat"
            },
            5: {
                id: 5,
                idx: 1,
                output: "eDP-1",
                name: null
            }
        };
        const internal = WorkspaceModel.forOutput(workspaces, "eDP-1");
        compare(internal.length, 2);
        compare(internal[0].id, 5);
        compare(internal[1].id, 9);
        compare(WorkspaceModel.reference("eDP-1", internal[0]), "1");
        compare(WorkspaceModel.reference("eDP-1", workspaces[3]), null);
        compare(WorkspaceModel.reference("HDMI-A-1", workspaces[3]), "chat");
        compare(WorkspaceModel.reference("eDP-1", {
            idx: 0,
            output: "eDP-1"
        }), null);
    }
    function test_trailingEmptyNiriWorkspaceBecomesRegularDot() {
        const workspaces = {
            1: {
                id: 1,
                idx: 1,
                output: "eDP-1",
                name: null,
                is_active: false,
                active_window_id: 14
            },
            2: {
                id: 2,
                idx: 2,
                output: "eDP-1",
                name: null,
                is_active: true,
                active_window_id: 15
            },
            3: {
                id: 3,
                idx: 3,
                output: "eDP-1",
                name: null,
                is_active: false,
                active_window_id: null
            }
        };
        compare(WorkspaceModel.forOutput(workspaces, "eDP-1").length, 2);
        workspaces[3].is_active = true;
        compare(WorkspaceModel.forOutput(workspaces, "eDP-1").length, 3);
        workspaces[3].is_active = false;
        workspaces[3].name = "later";
        compare(WorkspaceModel.forOutput(workspaces, "eDP-1").length, 3);
    }
}
