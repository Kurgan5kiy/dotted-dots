import QtQuick
import QtTest
import "../../src/surfaces/volume/Lifecycle.js" as Lifecycle

TestCase {
    name: "Edge"
    function test_repeatedCancellation() {
        var state = "armed";
        for (var i = 0; i < 20; i++) {
            state = Lifecycle.edge(state, "enter");
            compare(state, "dwelling");
            state = Lifecycle.edge(state, "leave");
            compare(state, "armed");
            state = Lifecycle.edge(state, "elapsed");
            compare(state, "armed");
        }
    }
    function test_latchedUntilLeave() {
        var state = Lifecycle.edge(Lifecycle.edge("armed", "enter"), "elapsed");
        compare(state, "latched");
        compare(Lifecycle.edge(state, "enter"), "latched");
        compare(Lifecycle.edge(state, "elapsed"), "latched");
        compare(Lifecycle.edge(state, "dismiss"), "latched");
        compare(Lifecycle.edge(state, "leave"), "armed");
    }
}
