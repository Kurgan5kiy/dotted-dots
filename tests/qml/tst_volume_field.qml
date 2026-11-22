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
    width: 240
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
        id: runtimeControllerFactory
        Controller {}
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
        mouseMove(testCase, 220, 270);
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
    function test_initialLevelDoesNotFillFromZero() {
        var fixture = createTemporaryObject(fixtureFactory, this);
        var audio = createTemporaryObject(audioFactory, this);
        var controller = createTemporaryObject(controllerFactory, this, {
            phase: "emerging",
            interactive: false
        });
        var field = createTemporaryObject(fieldFactory, fixture, {
            preferences: Validation.defaults(),
            audio: audio,
            controller: controller
        });
        compare(field.presentedNode, field.currentNode);
        compare(field.currentNode, 10);
        wait(30);
        verify(field.light.proximity < 1);
        compare(field.presentedNode, 10);
        controller.phase = "interactive";
        controller.interactive = true;
        compare(field.presentedNode, 10);
    }
    function test_nodesFollowAnimatedEndpoint() {
        var scene = setup(0);
        scene.audio.percent = 100;
        wait(35);
        verify(scene.field.presentedNode < scene.field.currentNode);
        var ahead = Math.min(scene.field.intervals, Math.ceil(scene.field.presentedNode) + 1);
        compare(findChild(scene.field, "volumeNode" + ahead).coverage, 1);
        scene.audio.percent = 0;
        wait(35);
        var nearest = Math.ceil(scene.field.presentedNode);
        if ((nearest - scene.field.presentedNode) * scene.field.spacing > 3)
            compare(findChild(scene.field, "volumeNode" + nearest).coverage, 1);
        scene.audio.percent = 80;
        wait(20);
        scene.audio.percent = 10;
        tryCompare(scene.field, "presentedNode", 2);
        compare(findChild(scene.field, "volumeNode3").coverage, 1);
        compare(findChild(scene.field, "volumeNode1").coverage, 0);
    }
    function test_pointerMovesLightNotControls() {
        var scene = setup(0);
        var trace = findChild(scene.field, "volumeTrace");
        var beforeX = trace.x;
        var beforeY = trace.y;
        scene.field.light.trackPointer(1, 40);
        wait(200);
        verify(scene.field.light.followX < -20);
        verify(scene.field.light.followY < -15);
        compare(trace.x, beforeX);
        compare(trace.y, beforeY);
        scene.field.light.leavePointer();
        scene.controller.phase = "retracting";
        scene.controller.interactive = false;
        for (var frame = 0; frame <= 6; frame++) {
            if (frame > 0)
                wait(100);
            grabImage(scene.fixture).save(Qt.resolvedUrl("../../dist/visual/pointer-retreat-" + frame + ".png").toString().replace(/^file:\/\//, ""));
            if (frame === 3) {
                verify(scene.field.light.lightScale < 1);
                verify(scene.field.light.controlAt(135, 81) < scene.field.light.controlAt(135, 270));
                grabImage(scene.fixture).save(Qt.resolvedUrl("../../dist/visual/pointer-retreat.png").toString().replace(/^file:\/\//, ""));
            }
        }
        compare(trace.x, beforeX);
        compare(trace.y, beforeY);
    }
    function test_reducedMotionDisablesLightTravelAndShrink() {
        var scene = setup(0);
        var prefs = Validation.defaults();
        prefs.motion.reduced = true;
        scene.field.preferences = prefs;
        verify(!scene.field.light.settling);
        scene.field.light.trackPointer(1, 40);
        scene.field.light.leavePointer();
        scene.controller.phase = "retracting";
        wait(120);
        compare(scene.field.light.lightScale, 1);
        compare(scene.field.light.fieldOffset, 0);
        compare(scene.field.light.shapes[0].x, 0);
        compare(scene.field.light.shapes[0].y, 0);
    }
    function test_realHoverEventsStartAndReverseRetreat() {
        var scene = setup(0);
        var controller = createTemporaryObject(runtimeControllerFactory, this, {
            preferences: Validation.defaults(),
            phase: "interactive"
        });
        scene.field.controller = controller;
        mouseMove(scene.field, 170, 270);
        tryCompare(controller, "hovered", true);
        mouseMove(scene.field, 10, 100);
        wait(200);
        verify(scene.field.light.followX < -20);
        verify(scene.field.light.followY < -10);
        mouseMove(testCase, 220, 100);
        compare(controller.phase, "retracting");
        verify(scene.field.light.pointerRetreat);
        wait(100);
        verify(scene.field.light.lightScale < 1);
        var scaleBeforeReentry = scene.field.light.lightScale;
        var offsetBeforeReentry = scene.field.light.fieldOffset;
        mouseMove(scene.field, 170, 270);
        compare(controller.phase, "interactive");
        verify(!scene.field.light.pointerRetreat);
        fuzzyCompare(scene.field.light.lightScale, scaleBeforeReentry, 0.02);
        fuzzyCompare(scene.field.light.fieldOffset, offsetBeforeReentry, 1);
        mouseMove(testCase, 220, 270);
    }
    function test_followBoundary_data() {
        return [
            {
                tag: "left",
                px: 1,
                py: 270
            },
            {
                tag: "top",
                px: 135,
                py: 1
            },
            {
                tag: "bottom",
                px: 135,
                py: 539
            }
        ];
    }
    function test_followBoundary(data) {
        var scene = setup(0);
        var prefs = Validation.defaults();
        prefs.motion.followRange = 48;
        prefs.motion.liquidStrength = 2;
        scene.field.preferences = prefs;
        scene.field.light.trackPointer(data.px, data.py);
        wait(200);
        var image = grabImage(scene.fixture);
        for (var y = 0; y < 540; y += 6)
            verify(image.red(0, y) >= 254, "Dark field clipped at left edge, y=" + y);
        for (var x = 0; x < 180; x += 6) {
            verify(image.red(x, 0) >= 254, "Dark field clipped at top edge, x=" + x);
            verify(image.red(x, 539) >= 254, "Dark field clipped at bottom edge, x=" + x);
        }
        image.save(Qt.resolvedUrl("../../dist/visual/pointer-" + data.tag + "-boundary.png").toString().replace(/^file:\/\//, ""));
    }
}
