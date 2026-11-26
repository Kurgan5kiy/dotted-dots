.pragma library

function length(bounds, spacing) {
    return Math.max(spacing * 5, bounds.end - bounds.start + spacing * 4) + (bounds.kind === "clock" ? spacing : 0);
}

function depth(reserveDepth, visualDepth, spacing, kind) {
    return Math.min(visualDepth - 8, reserveDepth + spacing + (kind === "clock" ? spacing / 2 : 0));
}

function regions(repeater, target, vertical) {
    if (!repeater)
        return [];
    const result = [];
    for (let i = 0; i < repeater.count; i++) {
        const widget = repeater.itemAt(i);
        if (!widget)
            continue;
        const origin = widget.mapToItem(target, 0, 0);
        const start = vertical ? origin.y : origin.x;
        const extent = vertical ? widget.height : widget.width;
        if (extent > 0)
            result.push({ start: start, end: start + extent, kind: widget.kind });
    }
    return result;
}
