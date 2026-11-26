pragma ComponentBehavior: Bound
import QtQuick
import QtTest
import "../../src/surfaces/bar"
import "../../src/surfaces/bar/ModuleAccent.js" as ModuleAccent
import "../visual"

TestCase {
    name: "BarVisual"
    when: windowShown
    visible: true
    width: 800
    height: 240
    Component {
        id: sceneFactory
        Fixture {
            property string edge: "top"
            property var excludedNodes: []
            width: edge === "top" || edge === "bottom" ? 240 : 78
            height: edge === "top" || edge === "bottom" ? 78 : 240
            BarField {
                anchors.fill: parent
                edge: parent.edge
                spacing: 18
                workspaceNodes: parent.excludedNodes
            }
        }
    }
    Component {
        id: hoverFactory
        Fixture {
            property alias glow: hoverLight
            property bool reducedMotion: false
            width: 600
            height: 78
            BarField {
                anchors.fill: parent
                edge: "top"
                spacing: 18
                workspaceNodes: [
                    {
                        x: 45,
                        y: 27
                    }
                ]
            }
            BarHoverLight {
                id: hoverLight
                vertical: false
                hostWidth: 600
                hostHeight: 78
                reducedMotion: parent.reducedMotion
                motion: ({
                        followMs: 120,
                        departureDrift: 32
                    })
            }
        }
    }
    Component {
        id: ambientFactory
        Fixture {
            property string edge: "top"
            width: edge === "top" || edge === "bottom" ? 240 : 78
            height: edge === "top" || edge === "bottom" ? 78 : 240
            BarAmbientPatch {
                id: patch
                anchors.fill: parent
                zoneIndex: 0
                vertical: parent.edge === "left" || parent.edge === "right"
                active: false
                edge: parent.edge
                spacing: 18
                hostWidth: parent.width
                hostHeight: parent.height
                workspaceNodes: []
                motion: ({
                        followMs: 120,
                        departureDrift: 32
                    })
                alongPoint: 120
                fieldLength: 400
            }
            property alias patch: patch
        }
    }
    Component {
        id: movingFactory
        Fixture {
            id: scene
            width: 800
            height: 78
            BarField {
                anchors.fill: parent
                edge: "top"
                spacing: 18
                workspaceNodes: []
            }
            Repeater {
                model: 4
                delegate: BarAmbientPatch {
                    required property int index
                    zoneIndex: index
                    vertical: false
                    active: true
                    edge: "top"
                    spacing: 18
                    hostWidth: 800
                    hostHeight: 78
                    workspaceNodes: []
                    motion: ({
                            followMs: 120,
                            departureDrift: 32
                        })
                }
            }
        }
    }
    Component {
        id: moduleFactory
        Fixture {
            id: scene
            property real accentStrength: 0.30
            width: 500
            height: 78
            BarField {
                anchors.fill: parent
                edge: "top"
                spacing: 18
                workspaceNodes: []
            }
            Repeater {
                model: [
                    {
                        start: 62,
                        end: 98,
                        kind: "clock"
                    },
                    {
                        start: 335,
                        end: 455
                    }
                ]
                delegate: BarHoverLight {
                    required property var modelData
                    vertical: false
                    edge: "top"
                    spacing: 18
                    workspaceNodes: []
                    hostWidth: 500
                    hostHeight: 78
                    motion: ({
                            followMs: 120,
                            departureDrift: 32
                        })
                    reducedMotion: false
                    animateOpacity: false
                    dotGain: 0.25
                    lit: true
                    strength: scene.accentStrength + (modelData.kind === "clock" ? 0.08 : 0)
                    width: ModuleAccent.length(modelData, 18)
                    height: 2 * (ModuleAccent.depth(36, 78, 18, modelData.kind) + 8)
                    centerX: (modelData.start + modelData.end) / 2
                    centerY: -8
                }
            }
        }
    }
    function test_moduleAccentsStayLocalAndBreathe() {
        const scene = createTemporaryObject(moduleFactory, this);
        verify(scene !== null);
        wait(80);
        const first = grabImage(scene);
        verify(first.red(80, 35) + 5 < first.red(225, 35));
        verify(first.red(390, 35) + 5 < first.red(225, 35));
        scene.accentStrength = 0.48;
        wait(80);
        const stronger = grabImage(scene);
        verify(stronger.red(80, 35) < first.red(80, 35));
        verify(stronger.red(80, 77) > 248);
        const output = Qt.resolvedUrl("../../dist/visual/bar-module-accent.png").toString().replace(/^file:\/\//, "");
        stronger.save(output);
    }
    function test_ambientFieldMovesContinuously() {
        const scene = createTemporaryObject(movingFactory, this);
        verify(scene !== null);
        const frames = [];
        for (let frame = 0; frame < 3; frame++) {
            wait(frame === 0 ? 160 : 1200);
            const shot = grabImage(scene);
            frames.push(shot);
            const output = Qt.resolvedUrl("../../dist/visual/bar-breathe-" + frame + ".png").toString().replace(/^file:\/\//, "");
            shot.save(output);
        }
        let change = 0;
        for (let x = 9; x < 800; x += 18)
            change += Math.abs(frames[0].red(x, 55) - frames[2].red(x, 55));
        verify(change > 100, "ambient change=" + change);
    }
    function test_hoverLightCaptures() {
        for (const reduced of [false, true]) {
            const scene = createTemporaryObject(hoverFactory, this, {
                reducedMotion: reduced
            });
            verify(scene !== null);
            scene.glow.enter(300, 30);
            wait(260);
            const image = grabImage(scene);
            const suffix = reduced ? "reduced" : "hover";
            const output = Qt.resolvedUrl("../../dist/visual/bar-" + suffix + ".png").toString().replace(/^file:\/\//, "");
            image.save(output);
        }
    }
    function test_hoverRevealsDarkSurface() {
        const scene = createTemporaryObject(hoverFactory, this, {
            reducedMotion: false
        });
        verify(scene !== null);
        wait(80);
        const before = grabImage(scene).red(300, 45);
        scene.glow.enter(300, 30);
        wait(300);
        const image = grabImage(scene);
        const after = image.red(300, 45);
        verify(after <= before);
        verify(image.red(300, 77) > 248, "hover boundary red=" + image.red(300, 77));
    }
    function test_ambientFieldFadesBeforeWindowBoundary_data() {
        return [
            {
                tag: "top",
                edge: "top"
            },
            {
                tag: "bottom",
                edge: "bottom"
            },
            {
                tag: "left",
                edge: "left"
            },
            {
                tag: "right",
                edge: "right"
            }
        ];
    }
    function test_ambientFieldFadesBeforeWindowBoundary(data) {
        const scene = createTemporaryObject(ambientFactory, this, {
            edge: data.edge
        });
        verify(scene !== null);
        scene.patch.lit = true;
        wait(160);
        const image = grabImage(scene);
        const horizontal = data.edge === "top" || data.edge === "bottom";
        const boundaryX = data.edge === "right" ? 0 : horizontal ? 120 : 77;
        const boundaryY = data.edge === "bottom" ? 0 : horizontal ? 77 : 120;
        verify(image.red(boundaryX, boundaryY) > 248);
        if (data.edge === "top") {
            const output = Qt.resolvedUrl("../../dist/visual/bar-ambient-patch.png").toString().replace(/^file:\/\//, "");
            image.save(output);
        }
    }
    function test_workspaceDotReplacesDecorativeNode() {
        const scene = createTemporaryObject(sceneFactory, this, {
            edge: "top",
            variant: 0,
            excludedNodes: [
                {
                    x: 99,
                    y: 27
                }
            ]
        });
        verify(scene !== null);
        wait(80);
        const image = grabImage(scene);
        verify(image.red(117, 27) > image.red(99, 27) + 10);
    }
    function test_ordinaryDotsRemainBesideWorkspaceModule() {
        const scene = createTemporaryObject(sceneFactory, this, {
            edge: "top",
            variant: 0,
            excludedNodes: [
                {
                    x: 27,
                    y: 27
                },
                {
                    x: 45,
                    y: 27
                }
            ]
        });
        verify(scene !== null);
        wait(80);
        const image = grabImage(scene);
        verify(image.red(9, 27) > image.red(27, 27) + 10);
        verify(image.red(63, 27) > image.red(45, 27) + 10);
        verify(Math.abs(image.red(9, 27) - image.red(63, 27)) < 3);
    }
    function test_feather_data() {
        const rows = [];
        for (const edge of ["top", "bottom", "left", "right"])
            for (let variant = 0; variant < 4; variant++)
                rows.push({
                    tag: edge + "-" + variant,
                    edge: edge,
                    variant: variant
                });
        return rows;
    }
    function test_feather(data) {
        const scene = createTemporaryObject(sceneFactory, this, {
            edge: data.edge,
            variant: data.variant
        });
        verify(scene !== null);
        wait(80);
        const image = grabImage(scene);
        compare(image.width, scene.width);
        compare(image.height, scene.height);
        if (data.variant === 0) {
            const horizontal = data.edge === "top" || data.edge === "bottom";
            const reverse = data.edge === "bottom" || data.edge === "right";
            const inner = reverse ? 78 - 20 : 20;
            const outer = reverse ? 78 - 77 : 77;
            const coreRed = horizontal ? image.red(120, inner) : image.red(inner, 120);
            const fadedRed = horizontal ? image.red(120, outer) : image.red(outer, 120);
            verify(coreRed + 80 < fadedRed);
            verify(fadedRed > 248);
        }
        const output = Qt.resolvedUrl("../../dist/visual/bar-" + data.tag + ".png").toString().replace(/^file:\/\//, "");
        image.save(output);
    }
}
