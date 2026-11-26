import QtQuick
import QtTest
import "../../src/platform/EdgeZones.js" as EdgeZones
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
    function test_invocationSelection() {
        var screens = [
            {
                name: "one"
            },
            {
                name: "two"
            }
        ];
        compare(Routing.selectForInvocation(screens, null, "two", "one"), screens[1]);
        compare(Routing.selectForInvocation(screens, screens[0], "two", ""), screens[0]);
        compare(Routing.selectForInvocation(screens, null, "missing", "two"), screens[1]);
        compare(Routing.selectForInvocation(screens, null, "missing", "missing"), screens[0]);
    }
    function test_profileResolution() {
        var edge = {
            side: "right",
            outputs: {
                one: {
                    side: "left"
                },
                two: {
                    copyOf: "one",
                    mirror: false
                },
                three: {
                    copyOf: "one",
                    mirror: true
                }
            }
        };
        compare(EdgeZones.resolveSide(edge, "one"), "left");
        compare(EdgeZones.resolveSide(edge, "two"), "left");
        compare(EdgeZones.resolveSide(edge, "three"), "right");
        compare(EdgeZones.resolveSide(edge, "missing"), "right");
    }
    function test_middleThird() {
        compare(EdgeZones.bounds(100).topHeight, 33);
        compare(EdgeZones.bounds(100).middleTop, 33);
        compare(EdgeZones.bounds(100).middleHeight, 34);
        compare(EdgeZones.bounds(100).bottomTop, 67);
        compare(EdgeZones.zoneAt(32, 100), "top");
        compare(EdgeZones.zoneAt(33, 100), "middle");
        compare(EdgeZones.zoneAt(66, 100), "middle");
        compare(EdgeZones.zoneAt(67, 100), "bottom");
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
        for (let i = 0; i < scales.length; i++) {
            const logicalWidth = 1920 / scales[i];
            const logicalHeight = 1200 / scales[i];
            const g = Routing.geometry(logicalWidth, logicalHeight, {
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
