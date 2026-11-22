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
        prefs.timing.traceMs = 5;
        prefs.timing.constructMs = 5;
        prefs.timing.retractMs = 10;
        prefs.timing.idleMs = 30;
        var controller = createTemporaryObject(controllerFactory, this, {
            preferences: prefs
        });
        verify(controller !== null);
        controller.show();
        controller.hovered = true;
        tryCompare(controller, "phase", "interactive");
        wait(80);
        compare(controller.phase, "interactive");
        controller.hovered = false;
        tryCompare(controller, "phase", "dormant");
        controller.show();
        tryCompare(controller, "phase", "interactive");
        controller.dragging = true;
        wait(80);
        compare(controller.phase, "interactive");
        controller.dragging = false;
        tryCompare(controller, "phase", "dormant");
    }
    function test_constructionOrder() {
        compare(Lifecycle.next("emerging"), "tracing");
        compare(Lifecycle.next("tracing"), "constructing");
        compare(Lifecycle.next("constructing"), "interactive");
        compare(Lifecycle.next("interactive"), "interactive");
        compare(Lifecycle.next("dormant"), "dormant");
    }
    function test_reducedMotion() {
        compare(Lifecycle.delay("emerging", {}, true), 100);
        compare(Lifecycle.delay("tracing", {}, true), 0);
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
