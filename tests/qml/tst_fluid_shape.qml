import QtQuick
import QtTest
import "../../src/visual/FluidShape.js" as FluidShape

TestCase {
    name: "FluidShape"
    function test_fieldTravelsInFromRight() {
        var shapes = FluidShape.describe(0, 1);
        compare(FluidShape.alphaAt(90, 270, 180, 540, 96, 180, shapes, 1), 0);
        verify(FluidShape.alphaAt(90, 270, 180, 540, 96, 0, shapes, 1) > 0.5);
        compare(FluidShape.alphaAt(0, 0, 180, 540, 96, 0, shapes, 1), 0);
    }
    function test_fieldTravelsInFromLeft() {
        var shapes = FluidShape.describe(0, 1);
        compare(FluidShape.alphaAt(90, 270, 180, 540, 96, -180, shapes, 1, "left"), 0);
        verify(FluidShape.alphaAt(90, 270, 180, 540, 96, 0, shapes, 1, "left") > 0.5);
        compare(FluidShape.alphaAt(180, 0, 180, 540, 96, 0, shapes, 1, "left"), 0);
    }
    function test_boundedSettlingReturnsToBase() {
        var first = FluidShape.describe(0, 1);
        var last = FluidShape.describe(Math.PI * 6, 1);
        fuzzyCompare(first[0].x, last[0].x, 0.0001);
        fuzzyCompare(first[0].sx, last[0].sx, 0.0001);
        fuzzyCompare(last[1].opacity, 0, 0.0001);
        var moving = FluidShape.describe(Math.PI * 2.5, 1);
        verify(Math.abs(moving[0].x) > 1);
        verify(moving[1].opacity > 0);
    }
    function test_reducedMotionShapeIsStatic() {
        var shape = FluidShape.describe(3, 0);
        compare(shape[0].x, 0);
        compare(shape[0].sx, 1);
        compare(shape[1].opacity, 0);
    }
    function test_followingShapesFadeBeforeSurfaceBoundary() {
        for (let phase = 0; phase <= Math.PI * 6; phase += 0.4) {
            const moved = FluidShape.transformed(FluidShape.describe(phase, 2), -48, -48, 1);
            const shapes = FluidShape.contained(moved, 180, 540, 0, 2);
            for (let y = 0; y <= 540; y += 18)
                compare(FluidShape.alphaAt(0, y, 180, 540, 96, 0, shapes, 1), 0);
            for (let x = 0; x <= 180; x += 18) {
                compare(FluidShape.alphaAt(x, 0, 180, 540, 96, 0, shapes, 1), 0);
                compare(FluidShape.alphaAt(x, 540, 180, 540, 96, 0, shapes, 1), 0);
            }
            // Preserve the follow offset; fitting changes radii, not position.
            compare(shapes[0].x, moved[0].x);
            compare(shapes[0].y, moved[0].y);
        }
    }
    function referenceAlpha(x, y, width, height, feather, offset, shapes, opacity) {
        var inner = Math.max(0.1, 1 - feather / Math.min(width, height / 2));
        var transparent = 1;
        for (let i = 0; i < shapes.length; i++) {
            const shape = shapes[i];
            const dx = (x - offset - shape.x - width) / (width * shape.sx);
            const dy = (y - shape.y - height / 2) / (height / 2 * shape.sy);
            const radius = Math.sqrt(dx * dx + dy * dy);
            const t = Math.max(0, Math.min(1, (radius - inner) / (1 - inner)));
            transparent *= 1 - (1 - t * t * (3 - 2 * t)) * shape.opacity * opacity;
        }
        return 1 - transparent;
    }
    function test_preparedSamplesMatchPreviousFormula() {
        var phases = [0, 2.5, 8.4, Math.PI * 6];
        var opacities = [0, 0.35, 1];
        for (const phase of phases) {
            const shapes = FluidShape.contained(FluidShape.transformed(FluidShape.describe(phase, 2), -36, 24, 0.8), 180, 540, 12, 2);
            const samples = FluidShape.prepare(shapes, 180, 540, 96, 12);
            for (const opacity of opacities) {
                for (let x = 0; x <= 180; x += 9) {
                    for (let y = 0; y <= 540; y += 18)
                        fuzzyCompare(FluidShape.sample(samples, x, y, opacity), referenceAlpha(x, y, 180, 540, 96, 12, shapes, opacity), 0.000000001);
                }
            }
        }
        compare(FluidShape.prepare(FluidShape.describe(0, 0), 180, 540, 96, 0).length, 1);
    }
}
