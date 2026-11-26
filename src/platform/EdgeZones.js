.pragma library

function bounds(height) {
    var safeHeight = Math.max(0, Math.floor(height));
    var outer = Math.floor(safeHeight / 3);
    return {
        topHeight: outer,
        middleTop: outer,
        middleHeight: safeHeight - outer * 2,
        bottomTop: safeHeight - outer,
        bottomHeight: outer
    };
}

function zoneAt(y, height) {
    var value = bounds(height);
    if (y < value.middleTop) return "top";
    if (y < value.bottomTop) return "middle";
    return "bottom";
}

function resolveSide(edge, outputId) {
    var fallback = edge && (edge.side === "left" || edge.side === "right") ? edge.side : "right";
    var profiles = edge && edge.outputs && typeof edge.outputs === "object" ? edge.outputs : ({});
    var profile = profiles[outputId];
    if (!profile) return fallback;
    if (profile.side === "left" || profile.side === "right") return profile.side;
    if (typeof profile.copyOf === "string") {
        var source = profiles[profile.copyOf];
        if (source && (source.side === "left" || source.side === "right")) {
            if (profile.mirror)
                return source.side === "left" ? "right" : "left";
            return source.side;
        }
    }
    return fallback;
}
