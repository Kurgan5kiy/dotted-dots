.pragma library

function snapStart(value, spacing) { return Math.max(0, Math.round(value / spacing) * spacing); }
function snapEnd(value, spacing) { return Math.max(0, Math.floor(value / spacing) * spacing); }
function node(index, spacing) { return spacing / 2 + index * spacing; }
function crossCellOffset(edge, reserve, spacing) {
    const index = Math.max(0, Math.min(Math.floor((reserve - spacing) / spacing),
                                        Math.round((reserve / 2 - spacing / 2) / spacing)));
    return edge === "top" || edge === "left" ? index * spacing : reserve - spacing - index * spacing;
}
function contentCrossOffset(edge, reserve, spacing, extent) {
    return crossCellOffset(edge, reserve, spacing) + (spacing - extent) / 2;
}
function isOccupied(x, y, nodes) {
    return nodes.some(function(node) { return Math.abs(node.x - x) < 0.5 && Math.abs(node.y - y) < 0.5; });
}
function isCovered(x, y, regions) {
    return regions.some(function(region) { return x >= region.x && x <= region.x + region.width && y >= region.y && y <= region.y + region.height; });
}
