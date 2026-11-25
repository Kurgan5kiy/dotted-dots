import QtQuick
import QtTest
import "../../src/config/Validation.js" as Validation

TestCase {
    name: "BarConfig"
    function test_defaultsAndMigration() {
        var defaults = Validation.defaults();
        compare(defaults.schemaVersion, 3);
        compare(defaults.bar.edge, "top");
        compare(defaults.bar.visibility, "always");
        compare(defaults.bar.outputs, "all");
        compare(defaults.bar.widgets.length, 5);
        var migrated = Validation.validate({
            schemaVersion: 2,
            edge: {
                side: "left"
            }
        });
        compare(migrated.values.schemaVersion, 3);
        compare(migrated.values.edge.side, "left");
    }
    function test_invalidEntriesDoNotDisableValidEntries() {
        var result = Validation.validate({
            schemaVersion: 3,
            bar: {
                edge: "left",
                outputs: ["DP-1", "DP-1"],
                widgets: [
                    {
                        type: "clock",
                        group: "center",
                        enabled: true,
                        priority: 80
                    },
                    {
                        type: "clock",
                        group: "end",
                        enabled: true,
                        priority: 10
                    },
                    {
                        type: "invalid",
                        group: "end",
                        enabled: true,
                        priority: 10
                    }
                ]
            }
        });
        compare(result.values.bar.edge, "left");
        compare(result.values.bar.outputs, "all");
        compare(result.values.bar.widgets.length, 1);
        compare(result.values.bar.widgets[0].type, "clock");
        verify(result.warnings.length >= 3);
    }
}
