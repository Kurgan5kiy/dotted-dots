.pragma library

function clamp(value, min, max) { return Math.max(min, Math.min(max, value)); }

function target(x, y, width, height, range) {
    return {x: clamp((x - width * 0.75) / (width * 0.75), -1, 1) * range,
        y: clamp((y - height / 2) / (height / 2), -1, 1) * range};
}

// No outside pointer feed: continue only a bounded distance along departure.
function departure(x, y, dx, dy, width, height, range, drift) {
    var edges = [{distance: x, x: -1, y: 0},
        {distance: width - x, x: 1, y: 0},
        {distance: y, x: 0, y: -1},
        {distance: height - y, x: 0, y: 1}];
    edges.sort(function(a, b) { return a.distance - b.distance; });
    var normal = edges[0];
    var length = Math.sqrt(dx * dx + dy * dy);
    if (length < 0.01 || dx * normal.x + dy * normal.y <= 0) {
        dx = normal.x;
        dy = normal.y;
        length = 1;
    }
    var start = target(x, y, width, height, range);
    return {x: start.x + dx / length * drift, y: start.y + dy / length * drift};
}
