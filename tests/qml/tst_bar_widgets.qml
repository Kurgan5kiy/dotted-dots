import QtQuick
import QtTest
import "../../src/widgets/bar/WorkspaceDisplay.js" as WorkspaceDisplay
import "../../src/surfaces/bar/Layout.js" as Layout
import "../../src/widgets/bar/FontChoice.js" as FontChoice

TestCase {
    name: "BarWidgets"
    function test_workspaceNumberOnlyFollowsFreshMatchingActivation() {
        compare(WorkspaceDisplay.shouldFlash(3, 3, 1000, 1000), true);
        compare(WorkspaceDisplay.shouldFlash(3, 3, 1000, 1899), true);
        compare(WorkspaceDisplay.shouldFlash(3, 3, 1000, 1900), false);
        compare(WorkspaceDisplay.shouldFlash(2, 3, 1000, 1100), false);
        compare(WorkspaceDisplay.shouldFlash(3, 3, 1000, 999), false);
    }
    function test_reorderedEnabledWidgetsKeepTheirGroups() {
        const entries = [
            {
                type: "tray",
                group: "start",
                enabled: true,
                priority: 50
            },
            {
                type: "clock",
                group: "end",
                enabled: true,
                priority: 80
            },
            {
                type: "battery",
                group: "end",
                enabled: false,
                priority: 60
            },
            {
                type: "volume",
                group: "end",
                enabled: true,
                priority: 70
            }
        ];
        const visible = Layout.arrange(entries, 1500, false, 2, 1).visible;
        compare(visible.length, 3);
        compare(visible.filter(entry => entry.group === "start")[0].type, "tray");
        compare(visible.filter(entry => entry.group === "end")[0].type, "clock");
        compare(visible.filter(entry => entry.group === "end")[1].type, "volume");
    }
    function test_clockFontHasMonospaceFallback() {
        compare(FontChoice.choose(["Noto Sans", "FiraCode Nerd Font Mono"]), "FiraCode Nerd Font Mono");
        compare(FontChoice.choose(["Noto Sans"]), "monospace");
        compare(FontChoice.choose(null), "monospace");
    }
}
