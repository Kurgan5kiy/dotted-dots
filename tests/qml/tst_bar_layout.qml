import QtQuick
import QtTest
import "../../src/surfaces/bar/Layout.js" as Layout
import "../../src/surfaces/bar/ModuleAccent.js" as ModuleAccent
import "../../src/config/Validation.js" as Validation

TestCase {
    name: "BarLayout"
    when: windowShown
    visible: true
    width: 600
    height: 100
    Component {
        id: liveLayout
        Item {
            property alias widgets: widgetRepeater
            width: 300
            height: 36
            Row {
                spacing: 18
                Repeater {
                    id: widgetRepeater
                    model: [36, 72]
                    delegate: Rectangle {
                        required property int modelData
                        width: modelData
                        height: 36
                    }
                }
            }
        }
    }
    function test_fullDisplayKeepsConfiguredOrder() {
        const entries = Validation.defaults().bar.widgets;
        const result = Layout.arrange(entries, 1920, false, 5, 3);
        compare(result.visible.length, 5);
        compare(result.overflow.length, 0);
        compare(result.visible[0].type, "workspaces");
        compare(result.visible[4].type, "tray");
    }
    function test_smallVerticalDisplayPreservesWorkspaces() {
        const entries = Validation.defaults().bar.widgets;
        const result = Layout.arrange(entries, 250, true, 5, 4);
        verify(result.overflow.length > 0);
        compare(result.visible[0].type, "workspaces");
        verify(result.overflow.some(entry => entry.type === "tray"));
    }
    function test_logicalScaleMatrix_data() {
        return [
            {
                tag: "1",
                scale: 1
            },
            {
                tag: "1.25",
                scale: 1.25
            },
            {
                tag: "1.5",
                scale: 1.5
            },
            {
                tag: "2",
                scale: 2
            }
        ];
    }
    function test_logicalScaleMatrix(data) {
        const logicalExtent = 600 / data.scale;
        const result = Layout.arrange(Validation.defaults().bar.widgets, logicalExtent, false, 5, 3);
        if (data.scale === 1) {
            compare(result.visible.length, 5);
            compare(result.overflow.length, 0);
        } else {
            verify(result.overflow.length > 0);
            compare(result.visible[0].type, "workspaces");
        }
    }
    function test_moduleAccentsFollowEachModuleSize() {
        compare(ModuleAccent.length({
            start: 10,
            end: 46
        }, 18), 108);
        compare(ModuleAccent.length({
            start: 10,
            end: 154
        }, 18), 216);
        compare(ModuleAccent.depth(36, 78, 18), 54);
        compare(ModuleAccent.depth(36, 78, 18, "clock"), 63);
        compare(ModuleAccent.length({
            start: 10,
            end: 154,
            kind: "clock"
        }, 18), 234);
        verify(ModuleAccent.depth(36, 78, 18) < 78);
    }
    function test_moduleRegionsUpdateWhenWidgetsChange() {
        const fixture = createTemporaryObject(liveLayout, this);
        verify(fixture !== null);
        wait(80);
        const before = ModuleAccent.regions(fixture.widgets, fixture, false);
        compare(before.length, 2);
        compare(before[0].end, 36);
        compare(before[1].start, 54);
        fixture.widgets.model = [90];
        wait(80);
        const after = ModuleAccent.regions(fixture.widgets, fixture, false);
        compare(after.length, 1);
        compare(after[0].start, 0);
        compare(after[0].end, 90);
    }
}
