import QtQuick
import QtTest
import "../../src/surfaces/volume"
import "../../src/config/Validation.js" as Validation
import "../visual"

TestCase {
    id: testCase
    name: "VolumeField"
    when: windowShown
    visible: true
    width: 180
    height: 540
    Component {
        id: fixtureFactory
        Fixture {
            width: 180
            height: 540
        }
    }
    Component {
        id: fieldFactory
        VolumeField {
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
            property var lastRequest: null
            function act(kind, value, step, cap) {
                lastRequest = {
                    kind: kind,
                    value: value
                };
                if (kind === "toggleMute")
                    muted = !muted;
                if (kind === "setPercent")
                    percent = value;
            }
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
    function setup(variant) {
        var fixture = createTemporaryObject(fixtureFactory, this, {
            variant: variant
        });
        var audio = createTemporaryObject(audioFactory, this);
        var controller = createTemporaryObject(controllerFactory, this);
        var field = createTemporaryObject(fieldFactory, fixture, {
            preferences: Validation.defaults(),
            audio: audio,
            controller: controller
        });
        verify(field !== null);
        wait(750);
        verify(fixture.visible);
        return {
            fixture: fixture,
            field: field,
            audio: audio,
            controller: controller
        };
    }
    function test_render_data() {
        return [
            {
                tag: "bright",
                variant: 0
            },
            {
                tag: "dark",
                variant: 1
            },
            {
                tag: "colorful",
                variant: 2
            },
            {
                tag: "busy",
                variant: 3
            }
        ];
    }
    function test_render(data) {
        var scene = setup(data.variant);
        var image = grabImage(scene.fixture);
        compare(image.width, 180);
        compare(image.height, 540);
        // The edge-center backdrop is opaque, while its left boundary reveals the fixture.
        verify(image.red(178, 270) < 40);
        if (data.variant === 0)
            verify(image.red(0, 270) > 240);
        // A decorative center dot must remain on the dark field, not just its rim.
        verify(image.red(171, 261) > image.red(165, 261) + 10);
        var output = Qt.resolvedUrl("../../dist/visual/" + data.tag + ".png").toString().replace(/^file:\/\//, "");
        image.save(output);
    }
    function test_controlsSnapToNodes() {
        var scene = setup(0);
        mouseClick(scene.field, scene.field.columnX, scene.field.chainTop + scene.field.chainHeight / 4);
        compare(scene.audio.lastRequest.kind, "setPercent");
        compare(scene.audio.percent, 75);
        verify(!scene.controller.dragging);
        mouseClick(scene.field, scene.field.columnX, scene.field.chainTop + scene.field.chainHeight + 36);
        verify(scene.audio.muted);
        compare(scene.audio.lastRequest.kind, "toggleMute");
    }
}
