import QtQuick
import QtTest
import "../../src/surfaces/bar"

TestCase {
    name: "BarMotion"
    when: windowShown
    visible: true
    width: 600
    height: 72
    Component {
        id: lightFactory
        BarHoverLight {
            vertical: false
            hostWidth: 600
            hostHeight: 72
            motion: ({
                    followMs: 120,
                    departureDrift: 32
                })
        }
    }
    Component {
        id: patchFactory
        BarAmbientPatch {
            zoneIndex: 0
            vertical: false
            active: false
            edge: "top"
            spacing: 18
            hostWidth: 600
            hostHeight: 72
            workspaceNodes: []
            motion: ({
                    followMs: 120,
                    departureDrift: 32
                })
        }
    }
    function test_pointerFollowAndBoundedRetreat() {
        const light = createTemporaryObject(lightFactory, this, {
            reducedMotion: false
        });
        verify(light !== null);
        light.enter(200, 30);
        compare(light.followDurationMs, 420);
        tryCompare(light, "centerX", 200, 700);
        light.track(300, 32);
        wait(120);
        verify(light.centerX > 200 && light.centerX < 290);
        tryCompare(light, "centerX", 300, 700);
        light.leave();
        compare(light.lit, false);
        verify(light.centerX <= 332);
        tryCompare(light, "opacity", 0, 500);
    }
    function test_reducedMotionHoldsLightStationary() {
        const light = createTemporaryObject(lightFactory, this, {
            reducedMotion: true
        });
        verify(light !== null);
        light.enter(200, 30);
        light.track(300, 32);
        compare(light.centerX, 200);
        light.leave();
        tryCompare(light, "opacity", 0, 300);
    }
    function test_ambientDepthMovesTowardInterior() {
        for (const edge of ["top", "bottom", "left", "right"]) {
            const vertical = edge === "left" || edge === "right";
            const light = createTemporaryObject(lightFactory, this, {
                edge: edge,
                vertical: vertical,
                reducedMotion: false
            });
            verify(light !== null);
            light.driftDepth = 18;
            if (edge === "top")
                compare(light.y + light.height, light.hostHeight);
            else if (edge === "bottom")
                compare(light.y, 0);
            else if (edge === "left")
                compare(light.x + light.width, light.hostWidth);
            else
                compare(light.x, 0);
            light.destroy();
        }
    }
    function test_ambientPatchesUseDistributedZonesAndStop() {
        for (let index = 0; index < 4; index++) {
            const patch = createTemporaryObject(patchFactory, this, {
                zoneIndex: index
            });
            verify(patch !== null);
            patch.active = true;
            patch.chooseRegion();
            compare(patch.lit, true);
            verify(patch.periodMs >= 3300 + index * 450);
            verify(patch.periodMs < 4400 + index * 450);
            verify(patch.alongPoint > index * 600 / 4);
            verify(patch.alongPoint < (index + 1) * 600 / 4);
            verify(patch.fieldLength >= 300 && patch.fieldLength <= 560);
            patch.active = false;
            compare(patch.lit, false);
            patch.destroy();
        }
    }
    function test_ambientPatchKeepsMovingUntilDisabled() {
        const patch = createTemporaryObject(patchFactory, this, {
            zoneIndex: 1
        });
        verify(patch !== null);
        patch.active = true;
        const phase = patch.phase;
        wait(360);
        verify(patch.phase > phase);
        verify(patch.fieldStrength >= 0 && patch.fieldStrength <= 1);
        patch.active = false;
        const stoppedPhase = patch.phase;
        wait(360);
        compare(patch.phase, stoppedPhase);
    }
}
