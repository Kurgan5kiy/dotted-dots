.pragma library

function forOutput(workspaces, output) {
    const entries = Object.values(workspaces || ({})).filter(function(workspace) {
        return workspace && workspace.output === output;
    }).sort(function(a, b) { return a.idx - b.idx; });
    while (entries.length > 1) {
        const last = entries[entries.length - 1];
        if (last.active_window_id !== null || last.is_active || last.name)
            break;
        entries.pop();
    }
    return entries;
}
function reference(output, workspace) {
    if (!workspace || workspace.output !== output)
        return null;
    if (typeof workspace.name === "string" && workspace.name.length > 0)
        return workspace.name;
    return Number.isInteger(workspace.idx) && workspace.idx > 0 ? String(workspace.idx) : null;
}
