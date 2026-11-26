import QtQuick
import QtTest
import "../../src/surfaces/bar/RevealState.js" as RevealState

TestCase {
    name: "BarReveal"
    function test_pointerCycleAndReentry() {
        let phase = RevealState.initial(true);
        compare(phase, "hidden");
        phase = RevealState.enter(phase);
        compare(phase, "revealing");
        compare(RevealState.shown(phase), false);
        phase = RevealState.elapsed(phase);
        compare(phase, "visible");
        phase = RevealState.release(phase);
        compare(phase, "hiding");
        compare(RevealState.shown(phase), true);
        phase = RevealState.enter(phase);
        compare(phase, "visible");
        phase = RevealState.release(phase);
        phase = RevealState.dismiss(phase, false);
        compare(phase, "hidden");
    }
    function test_holdAndCancelledReveal() {
        compare(RevealState.initial(false), "visible");
        compare(RevealState.release("revealing"), "hidden");
        compare(RevealState.dismiss("hiding", true), "visible");
        compare(RevealState.hold("hidden"), "visible");
        compare(RevealState.hold("hiding"), "visible");
    }
    function test_twentyPointerCyclesReturnToHidden() {
        let phase = RevealState.initial(true);
        for (let i = 0; i < 20; i++) {
            phase = RevealState.enter(phase);
            phase = RevealState.elapsed(phase);
            phase = RevealState.release(phase);
            phase = RevealState.dismiss(phase, false);
            compare(phase, "hidden");
        }
    }
}
