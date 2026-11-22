.pragma library

// Shared geometry for the cached backdrop layers and decorative-dot alpha.
function describe(phase, strength) {
    var envelope = Math.pow(Math.sin(phase / 6), 2) * strength;
    return [
        {x: 3 * Math.sin(phase) * envelope, y: 3 * Math.sin(phase * 2) * envelope,
            sx: 1 + 0.025 * Math.sin(phase * 2) * envelope,
            sy: 1 + 0.015 * Math.sin(phase * 3) * envelope, opacity: 1},
        {x: (-5 + 3 * Math.sin(phase * 2)) * envelope,
            y: (-12 + 8 * Math.sin(phase)) * envelope,
            sx: 1 + 0.04 * envelope, sy: 1 + 0.02 * Math.sin(phase) * envelope,
            opacity: 0.18 * envelope},
        {x: (-7 + 4 * Math.sin(phase * 3)) * envelope,
            y: (10 + 8 * Math.sin(phase * 2)) * envelope,
            sx: 1 + 0.035 * envelope, sy: 1 - 0.02 * Math.sin(phase) * envelope,
            opacity: 0.14 * envelope}
    ];
}
function alphaAt(x, y, width, height, feather, offset, shapes, centerOpacity) {
    return sample(prepare(shapes, width, height, feather, offset), x, y, centerOpacity);
}

// Shared once per shape update instead of repeating geometry work per dot.
function prepare(shapes, width, height, feather, offset) {
    var inner = Math.max(0.1, 1 - feather / Math.min(width, height / 2));
    return shapes.filter(function(shape) { return shape.opacity > 0; }).map(function(shape) {
        return {cx: width + offset + shape.x, cy: height / 2 + shape.y,
            inverseX: 1 / (width * shape.sx), inverseY: 1 / (height / 2 * shape.sy),
            inner: inner, innerSquared: inner * inner, inverseFeather: 1 / (1 - inner),
            opacity: shape.opacity};
    });
}

function sample(coefficients, x, y, centerOpacity) {
    if (centerOpacity === undefined) centerOpacity = 1;
    var transparent = 1;
    for (var i = 0; i < coefficients.length; i++) {
        var shape = coefficients[i];
        var dx = (x - shape.cx) * shape.inverseX;
        var dy = (y - shape.cy) * shape.inverseY;
        var squared = dx * dx + dy * dy;
        if (squared >= 1) continue;
        var alpha = shape.opacity * centerOpacity;
        if (squared > shape.innerSquared) {
            var t = (Math.sqrt(squared) - shape.inner) * shape.inverseFeather;
            alpha *= 1 - t * t * (3 - 2 * t);
        }
        transparent *= 1 - alpha;
    }
    return 1 - transparent;
}

function transformed(shapes, x, y, scale) {
    return shapes.map(function(shape) {
        return {x: x + shape.x * scale, y: y + shape.y * scale,
            sx: shape.sx * scale, sy: shape.sy * scale, opacity: shape.opacity};
    });
}

// Keep each feathered ellipse inside the non-screen edges of the local surface.
// Its center still follows the pointer; only an overflowing radius contracts.
function contained(shapes, width, height, offset, inset) {
    return shapes.map(function(shape) {
        var horizontalLimit = (width + offset + shape.x - inset) / width;
        var verticalLimit = (height / 2 - Math.abs(shape.y) - inset) / (height / 2);
        return {x: shape.x, y: shape.y,
            sx: Math.min(shape.sx, Math.max(0.01, horizontalLimit)),
            sy: Math.min(shape.sy, Math.max(0.01, verticalLimit)),
            opacity: shape.opacity};
    });
}
