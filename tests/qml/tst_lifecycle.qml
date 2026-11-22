import QtQuick
import QtTest
import "../../src/surfaces/volume/Lifecycle.js" as Lifecycle
import "../../src/surfaces/volume"
import "../../src/config/Validation.js" as Validation

TestCase {
    name: "Lifecycle"
    Component {
        id: controllerFactory
        Controller {}
    }
    function test_liveTimersAndHover() {
        var prefs = Validation.defaults();
        prefs.timing.emergeMs = 5;
        prefs.timing.retractMs = 10;
        prefs.timing.idleMs = 100;
        var controller = createTemporaryObject(controllerFactory, this, {
            preferences: prefs
        });
        verify(controller !== null);
        controller.show();
        controller.hovered = true;
        tryCompare(controller, "phase", "interactive");
        wait(180);
        compare(controller.phase, "interactive");
        controller.hovered = false;
        tryCompare(controller, "phase", "dormant");
        controller.show();
        tryCompare(controller, "phase", "interactive");
        controller.dragging = true;
        wait(180);
        compare(controller.phase, "interactive");
        controller.dragging = false;
        tryCompare(controller, "phase", "dormant");
    }
    function test_constructionOrder() {
        compare(Lifecycle.next("emerging"), "interactive");
        compare(Lifecycle.next("interactive"), "interactive");
        compare(Lifecycle.next("dormant"), "dormant");
    }
    function test_pointerDepartureAndReentry() {
        var prefs = Validation.defaults();
        prefs.timing.retractMs = 400;
        var controller = createTemporaryObject(controllerFactory, this, {
            preferences: prefs,
            phase: "interactive",
            hovered: true
        });
        controller.hovered = false;
        compare(controller.phase, "retracting");
        controller.hovered = true;
        compare(controller.phase, "interactive");
        controller.dragging = true;
        controller.hovered = false;
        compare(controller.phase, "interactive");
        controller.dragging = false;
        compare(controller.phase, "retracting");
    }
    function test_reducedMotion() {
        compare(Lifecycle.delay("emerging", {}, true), 100);
        compare(Lifecycle.delay("retracting", {}, true), 100);
    }
    function test_cancelAndRearm() {
        compare(Lifecycle.edge("armed", "enter"), "dwelling");
        compare(Lifecycle.edge("dwelling", "leave"), "armed");
        compare(Lifecycle.edge("dwelling", "elapsed"), "latched");
        compare(Lifecycle.edge("latched", "enter"), "latched");
        compare(Lifecycle.edge("latched", "leave"), "armed");
    }
}
