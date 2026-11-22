import QtQuick
import QtTest
import "../../src/services/AudioState.js" as AudioState

TestCase {
    name: "Actions"
    property var snapshot: ({
            available: true,
            sinkId: 1,
            percent: 40,
            muted: false
        })
    function test_accumulate() {
        compare(AudioState.request("increase", 0, snapshot, {
            percent: 45,
            muted: null
        }, 5, 100).percent, 50);
    }
    function test_limits() {
        compare(AudioState.request("setPercent", 101, snapshot, null, 5, 100).error, "invalid_argument");
        compare(AudioState.request("setPercent", NaN, snapshot, null, 5, 100).error, "invalid_argument");
        verify(AudioState.request("increase", 0, {
            available: true,
            percent: 150
        }, null, 5, 100).noop);
        compare(AudioState.request("decrease", 0, {
            available: true,
            percent: 150
        }, null, 5, 100).percent, 100);
    }
    function test_confirmation() {
        verify(AudioState.confirmed(snapshot, {
            sinkId: 1,
            percent: 40.4,
            muted: null
        }));
        verify(!AudioState.confirmed(snapshot, {
            sinkId: 2,
            percent: 40,
            muted: null
        }));
        verify(!AudioState.confirmed(snapshot, {
            sinkId: 1,
            percent: null,
            muted: true
        }));
        compare(AudioState.request("toggleMute", 0, snapshot, {
            percent: null,
            muted: true
        }, 5, 100).muted, false);
    }
}
