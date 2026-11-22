import QtQuick
import QtTest
import "../../src/visual/PointerLight.js" as PointerLight

TestCase {
    name: "PointerLight"
    function test_boundedFollow() {
        var center = PointerLight.target(135, 270, 180, 540, 24);
        compare(center.x, 0);
        compare(center.y, 0);
        var outside = PointerLight.target(-400, 2000, 180, 540, 24);
        compare(outside.x, -24);
        compare(outside.y, 24);
        compare(PointerLight.target(0, 0, 180, 540, 0).x, 0);
    }
    function test_departurePreservesOutwardDirection() {
        var result = PointerLight.departure(1, 200, -3, -4, 180, 540, 24, 32);
        var start = PointerLight.target(1, 200, 180, 540, 24);
        fuzzyCompare(result.x - start.x, -19.2, 0.001);
        fuzzyCompare(result.y - start.y, -25.6, 0.001);
    }
    function test_departureWithoutMotionUsesNearestEdge() {
        var result = PointerLight.departure(100, 539, 0, 0, 180, 540, 24, 32);
        var start = PointerLight.target(100, 539, 180, 540, 24);
        compare(result.x, start.x);
        compare(result.y, start.y + 32);
    }
}
