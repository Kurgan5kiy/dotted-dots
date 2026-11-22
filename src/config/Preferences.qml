import QtQuick
import Quickshell
import Quickshell.Io
import "Validation.js" as Validation

QtObject {
    id: root
    property var values: Validation.defaults()
    readonly property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/dot-shell/config.json"
    property FileView file: FileView {
        path: root.configPath
        onLoaded: {
            const result = Validation.parse(text());
            root.values = result.values;
            result.warnings.forEach(message => console.warn(message));
        }
        onLoadFailed: console.info("Dot Shell configuration unavailable; using defaults")
    }
}
