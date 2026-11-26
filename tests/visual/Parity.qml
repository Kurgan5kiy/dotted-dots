import QtQuick
import QtTest
import "../../src/surfaces/volume"
import "../../src/config/Validation.js" as Validation

// Optional before/after check; baseline is an external copy of src, never Git history.
TestCase {
    id: testCase
    name: "VisualParity"
    when: windowShown
    visible: true
    width: 400
    height: 540
    property string baselinePath: ""
    Component {
        id: fixtureFactory
        Fixture {
            width: 180
            height: 540
        }
    }
    Component {
        id: audioFactory
        QtObject {
            property bool available: true
            property real percent: 50
            property bool muted: false
            property string error: ""
        }
    }
    Component {
        id: controllerFactory
        QtObject {
            property string phase: "interactive"
            property bool interactive: true
            property bool hovered: false
            property bool dragging: false
        }
    }
    Component {
        id: currentFactory
        VolumeField {
            width: 180
            height: 540
        }
    }
    function test_pixels_data() {
        return [
            {
                tag: "bright",
                variant: 0,
                moved: false,
                opacity: 1
            },
            {
                tag: "dark",
                variant: 1,
                moved: false,
                opacity: 1
            },
            {
                tag: "colorful",
                variant: 2,
                moved: false,
                opacity: 1
            },
            {
                tag: "busy",
                variant: 3,
                moved: false,
                opacity: 1
            },
            {
                tag: "follow",
                variant: 0,
                moved: true,
                opacity: 1
            },
            {
                tag: "translucent",
                variant: 0,
                moved: true,
                opacity: 0.35
            }
        ];
    }
    function test_pixels(data) {
        if (!baselinePath)
            skip("Pass a before-refactor src copy through test-visual-parity.sh");
        mouseMove(testCase, 395, 10);
        var baselineFactory = Qt.createComponent("file://" + baselinePath + "/surfaces/volume/VolumeField.qml");
        compare(baselineFactory.status, Component.Ready, baselineFactory.errorString());
        var preferences = Validation.defaults();
        preferences.motion.liquidStrength = 0;
        preferences.field.backdropOpacity = data.opacity;
        var left = createTemporaryObject(fixtureFactory, this, {
            variant: data.variant
        });
        var right = createTemporaryObject(fixtureFactory, this, {
            variant: data.variant,
            x: 200
        });
        var audio = createTemporaryObject(audioFactory, this);
        var controller = createTemporaryObject(controllerFactory, this);
        var baseline = createTemporaryObject(baselineFactory, left, {
            width: 180,
            height: 540,
            preferences: preferences,
            audio: audio,
            controller: controller
        });
        var current = createTemporaryObject(currentFactory, right, {
            preferences: preferences,
            audio: audio,
            controller: controller
        });
        verify(baseline !== null && current !== null);
        wait(500);
        if (data.moved) {
            baseline.trackPointer(1, 100);
            current.light.trackPointer(1, 100);
            wait(200);
        }
        var before = grabImage(left);
        var after = grabImage(right);
        var maxDifference = 0;
        for (let y = 0; y < 540; y++) {
            for (let x = 0; x < 180; x++) {
                maxDifference = Math.max(maxDifference, Math.abs(before.red(x, y) - after.red(x, y)), Math.abs(before.green(x, y) - after.green(x, y)), Math.abs(before.blue(x, y) - after.blue(x, y)));
            }
        }
        verify(maxDifference <= 1, "Maximum RGB channel difference: " + maxDifference);
    }
}
