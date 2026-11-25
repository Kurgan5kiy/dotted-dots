import QtQuick
import Quickshell.Io

QtObject {
    id: root
    signal revealRequested(string output)
    property IpcHandler handler: IpcHandler {
        target: "bar_v1"
        function reveal(output: string): string {
            root.revealRequested(output);
            return JSON.stringify({
                version: 1,
                status: "accepted"
            });
        }
    }
}
