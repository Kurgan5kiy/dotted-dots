import QtQuick
import QtTest
import "../../src/config/Validation.js" as Validation

TestCase {
    name: "Preferences"
    function test_defaults() {
        compare(Validation.validate({}).values.edge.dwellMs, 200);
        compare(Validation.defaults().triggers.externalAudioChanges, true);
    }
    function test_invalidFields() {
        var r = Validation.validate({
            schemaVersion: 1,
            timing: {
                idleMs: -1
            },
            edge: {
                enabled: false
            },
            field: {
                width: "800"
            }
        });
        compare(r.values.timing.idleMs, 2000);
        compare(r.values.edge.enabled, false);
        compare(r.values.field.width, 180);
        compare(r.warnings.length, 2);
    }
    function test_geometry() {
        compare(Validation.validate({
            schemaVersion: 1,
            field: {
                width: 800,
                height: 600,
                spacing: 8
            }
        }).values.field.width, 180);
        compare(Validation.validate({
            schemaVersion: 1,
            field: {
                height: 100,
                feather: 60
            }
        }).values.field.height, 540);
    }
    function test_schemaAndJson() {
        compare(Validation.parse("{broken").values.schemaVersion, 1);
        verify(Validation.validate({
            schemaVersion: 2
        }).warnings.length > 0);
        verify(Validation.validate({
            schemaVersion: 1,
            field: []
        }).warnings.length > 0);
        verify(Validation.validate({
            schemaVersion: 1,
            unknown: 1
        }).warnings.length > 0);
    }
}
