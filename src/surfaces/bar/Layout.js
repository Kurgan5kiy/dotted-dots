.pragma library

function extent(entry, vertical, workspaceCount, trayCount) {
    if (vertical) {
        if (entry.type === "workspaces") return Math.max(36, workspaceCount * 30 + 8);
        if (entry.type === "tray") return Math.max(36, trayCount * 32 + 8);
        return 36;
    }
    if (entry.type === "workspaces") return Math.max(36, workspaceCount * 31 + 12);
    if (entry.type === "tray") return Math.max(36, trayCount * 33 + 12);
    if (entry.type === "clock") return 62;
    return 72;
}

function arrange(entries, available, vertical, workspaceCount, trayCount) {
    var visible = entries.filter(function(entry) { return entry.enabled; });
    var overflow = [];
    function size() {
        var groups = ["start", "center", "end"];
        return groups.reduce(function(total, group) {
            var items = visible.filter(function(entry) { return entry.group === group; });
            return total + items.reduce(function(sum, entry) {
                return sum + extent(entry, vertical, workspaceCount, trayCount) + 8;
            }, 0);
        }, 24) + (overflow.length ? 40 : 0);
    }
    while (visible.length > 1 && size() > available) {
        var candidate = visible.filter(function(entry) { return entry.type !== "workspaces"; })
            .sort(function(a, b) { return a.priority - b.priority; })[0];
        if (!candidate) break;
        visible.splice(visible.indexOf(candidate), 1);
        overflow.unshift(candidate);
    }
    return { visible: visible, overflow: overflow };
}
