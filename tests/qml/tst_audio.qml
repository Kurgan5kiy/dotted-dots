import QtQuick
import QtTest
import "../../src/services/AudioState.js" as AudioState

TestCase {
    name: "Audio"
    function test_unavailable() {
        compare(AudioState.request("increase", 0, {
            available: false
        }, null, 5, 100).error, "unavailable");
    }
    function test_externalTrigger() {
        verify(!AudioState.changed({
            available: false
        }, {
            available: true,
            sinkId: 1
        }));
        verify(!AudioState.changed({
            available: true,
            sinkId: 1
        }, {
            available: true,
            sinkId: 2
        }));
        verify(AudioState.changed({
            available: true,
            sinkId: 1,
            percent: 40,
            muted: false
        }, {
            available: true,
            sinkId: 1,
            percent: 45,
            muted: false
        }));
    }
}
