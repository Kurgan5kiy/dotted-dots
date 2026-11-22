import QtQuick
import QtTest
import "../../src/visual"

TestCase {
    name: "AnimatedValue"
    Component {
        id: factory
        AnimatedValue {
            value: 50
        }
    }
    function test_initialValueIsImmediate() {
        var item = createTemporaryObject(factory, this);
        compare(item.displayedText, "50%");
        compare(item.progress, 1);
    }
    function test_rapidChangesKeepLatestValue() {
        var item = createTemporaryObject(factory, this);
        item.value = 75;
        verify(item.animating);
        compare(item.displayedText, "75%");
        compare(item.progress, 0);
        wait(40);
        item.value = 20;
        wait(20);
        compare(item.displayedText, "20%");
        item.value = 90;
        tryCompare(item, "progress", 1);
        compare(item.displayedText, "90%");
        compare(item.direction, 1);
    }
    function test_reducedMotionAndUnavailable() {
        var item = createTemporaryObject(factory, this, {
            reducedMotion: true
        });
        item.value = 20;
        compare(item.displayedText, "20%");
        compare(item.progress, 1);
        item.available = false;
        compare(item.displayedText, "—");
        compare(item.progress, 1);
    }
}
