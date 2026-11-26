import QtQuick
import QtTest
import "../../src/platform/Routing.js" as Routing

TestCase {
    name: "Routing"

    function test_visibleSelectionLock() {
        var screens = [
            {
                name: "one"
            },
            {
                name: "two"
            }
        ];
        var selected = Routing.selectForInvocation(screens, null, "one", "two");
        compare(selected, screens[0]);
        compare(Routing.keepOrSelect(screens, selected, true, null, "two", ""), selected);
        compare(Routing.keepOrSelect(screens, selected, false, null, "two", ""), screens[1]);
    }

    function test_outputLossOverridesLock() {
        var screens = [
            {
                name: "two"
            }
        ];
        var removed = {
            name: "one"
        };
        compare(Routing.keepOrSelect(screens, removed, true, null, "two", ""), screens[0]);
        compare(Routing.keepOrSelect([], removed, true, null, "two", ""), null);
    }
}
