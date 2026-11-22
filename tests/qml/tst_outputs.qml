import QtQuick
import QtTest
import "../../src/platform/Routing.js" as Routing

TestCase {
    name: "Outputs"
    function test_selection() {
        var screens = [
            {
                name: "one"
            },
            {
                name: "two"
            }
        ];
        compare(Routing.select(screens, "two"), screens[1]);
        compare(Routing.select(screens, "missing"), screens[0]);
        compare(Routing.select([], "missing"), null);
        verify(!Routing.contains(screens, {
            name: "removed"
        }));
    }
    function test_placement() {
        var g = Routing.geometry(1920, 1200, {
            width: 180,
            height: 540,
            spacing: 18
        }, 0, "right-center");
        compare(g.x, 1740);
        compare(g.y, 330);
        verify(g.usable);
        verify(!Routing.geometry(100, 80, {
            width: 180,
            height: 540,
            spacing: 18
        }, 16, "center").usable);
        g = Routing.geometry(640, 480, {
            width: 800,
            height: 600,
            spacing: 18
        }, 16, "bottom-center");
        verify(g.x >= 0 && g.y >= 0 && g.width <= 640 && g.height <= 480);
    }
    function test_logicalScaleSizes() {
        var scales = [1, 1.25, 1.5, 2];
        for (var i = 0; i < scales.length; i++) {
            var logicalWidth = 1920 / scales[i];
            var logicalHeight = 1200 / scales[i];
            var g = Routing.geometry(logicalWidth, logicalHeight, {
                width: 180,
                height: 540,
                spacing: 18
            }, 0, "right-center");
            verify(g.usable);
            compare(g.x + g.width, logicalWidth);
            verify(g.y >= 0 && g.y + g.height <= logicalHeight);
        }
    }
}
