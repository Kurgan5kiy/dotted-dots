.pragma library

function initial() {
    return {
        workspaces: ({}),
        outputId: null,
        ready: false,
        windowFocused: false,
        diagnostic: "waiting_for_initial_state"
    };
}

function clone(state) {
    var workspaces = ({});
    Object.keys(state.workspaces || ({})).forEach(function(id) {
        workspaces[id] = Object.assign(({}), state.workspaces[id]);
    });
    return {
        workspaces: workspaces,
        outputId: state.outputId,
        ready: state.ready,
        windowFocused: state.windowFocused,
        diagnostic: state.diagnostic
    };
}

function refresh(state) {
    var ids = Object.keys(state.workspaces);
    var focused = null;
    for (var i = 0; i < ids.length; i++) {
        if (state.workspaces[ids[i]].is_focused) {
            focused = state.workspaces[ids[i]];
            break;
        }
    }
    state.outputId = focused && typeof focused.output === "string" ? focused.output : null;
    state.windowFocused = !!(focused && focused.active_window_id !== null && focused.active_window_id !== undefined);
    return state;
}

function reduce(previous, event) {
    var state = clone(previous || initial());
    if (!event || typeof event !== "object") return state;
    if (event.WorkspacesChanged && Array.isArray(event.WorkspacesChanged.workspaces)) {
        if (!event.WorkspacesChanged.workspaces.every(function(workspace) {
            return workspace && typeof workspace.id === "number" && isFinite(workspace.id)
                && typeof workspace.is_focused === "boolean"
                && (workspace.output === null || typeof workspace.output === "string");
        })) return invalidate(state, "invalid_workspace_snapshot");
        state.workspaces = ({});
        event.WorkspacesChanged.workspaces.forEach(function(workspace) {
            if (workspace && workspace.id !== undefined)
                state.workspaces[String(workspace.id)] = {
                    id: workspace.id,
                    idx: workspace.idx,
                    name: workspace.name,
                    output: workspace.output,
                    is_active: workspace.is_active,
                    is_focused: workspace.is_focused,
                    active_window_id: workspace.active_window_id
                };
        });
        state.ready = true;
        state.diagnostic = null;
        return refresh(state);
    }
    if (event.WorkspaceActivated && event.WorkspaceActivated.id !== undefined) {
        var activeId = String(event.WorkspaceActivated.id);
        Object.keys(state.workspaces).forEach(function(id) {
            var workspace = state.workspaces[id];
            if (workspace.output === state.workspaces[activeId]?.output)
                workspace.is_active = id === activeId;
        });
        if (event.WorkspaceActivated.focused) {
            Object.keys(state.workspaces).forEach(function(id) { state.workspaces[id].is_focused = id === activeId; });
            return refresh(state);
        }
        return state;
    }
    if (event.WorkspaceActiveWindowChanged && event.WorkspaceActiveWindowChanged.workspace_id !== undefined) {
        var workspace = state.workspaces[String(event.WorkspaceActiveWindowChanged.workspace_id)];
        if (workspace) {
            workspace.active_window_id = event.WorkspaceActiveWindowChanged.active_window_id;
            return refresh(state);
        }
        return state;
    }
    if (event.WindowFocusChanged) {
        state.windowFocused = event.WindowFocusChanged.id !== null && event.WindowFocusChanged.id !== undefined;
        return state;
    }
    if (event.WindowsChanged && Array.isArray(event.WindowsChanged.windows)) {
        state.windowFocused = event.WindowsChanged.windows.some(function(window) { return !!window.is_focused; });
        return state;
    }
    if (event.WindowOpenedOrChanged && event.WindowOpenedOrChanged.window && event.WindowOpenedOrChanged.window.is_focused) {
        state.windowFocused = true;
        return state;
    }
    return state;
}

function invalidate(previous, reason) {
    var state = clone(previous || initial());
    state.workspaces = ({});
    state.outputId = null;
    state.ready = false;
    state.windowFocused = false;
    state.diagnostic = reason || "event_stream_unavailable";
    return state;
}
