import QtQuick
import QtTest
import "../../src/platform/NiriEvents.js" as NiriEvents

TestCase {
    name: "NiriFocus"

    function snapshot() {
        return {
            WorkspacesChanged: {
                workspaces: [
                    {
                        id: 1,
                        output: "eDP-1",
                        is_focused: false,
                        active_window_id: 10
                    },
                    {
                        id: 2,
                        output: "DP-1",
                        is_focused: true,
                        active_window_id: 20
                    }
                ]
            }
        };
    }

    function test_initialSnapshot() {
        var state = NiriEvents.reduce(NiriEvents.initial(), snapshot());
        verify(state.ready);
        compare(state.outputId, "DP-1");
        verify(state.windowFocused);
        compare(state.diagnostic, null);
    }

    function test_emptyWorkspaceAndActivation() {
        var state = NiriEvents.reduce(NiriEvents.initial(), snapshot());
        state = NiriEvents.reduce(state, {
            WorkspaceActiveWindowChanged: {
                workspace_id: 2,
                active_window_id: null
            }
        });
        verify(!state.windowFocused);
        compare(state.outputId, "DP-1");
        state = NiriEvents.reduce(state, {
            WorkspaceActivated: {
                id: 1,
                focused: true
            }
        });
        compare(state.outputId, "eDP-1");
        verify(state.windowFocused);
    }

    function test_unknownMalformedAndInvalidation() {
        var state = NiriEvents.reduce(NiriEvents.initial(), {
            FutureEvent: {
                private: "ignored"
            }
        });
        verify(!state.ready);
        compare(state.diagnostic, "waiting_for_initial_state");
        state = NiriEvents.reduce(state, null);
        verify(!state.ready);
        state = NiriEvents.invalidate(NiriEvents.reduce(state, snapshot()), "stream_closed");
        verify(!state.ready);
        compare(state.outputId, null);
        compare(state.diagnostic, "stream_closed");
    }
}
