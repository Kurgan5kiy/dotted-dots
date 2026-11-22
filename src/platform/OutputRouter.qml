import QtQuick
import Quickshell
import "Routing.js" as Routing

QtObject {
    id: root
    required property var preferences
    property var selected: null
    property bool fixedPlacement: false
    property string anchor: preferences.placement.anchor
    property bool fromEdge: false
    readonly property var screens: Quickshell.screens
    readonly property var geometry: selected ? Routing.geometry(selected.width, selected.height, preferences.field, fromEdge ? 0 : preferences.placement.margin, anchor) : ({
            usable: false,
            width: 0,
            height: 0,
            x: 0,
            y: 0
        })
    signal outputLost
    function choose(screen: var): void {
        if (fixedPlacement && Routing.contains(screens, selected))
            return;
        selected = screen || Routing.select(screens, preferences.placement.output);
        fromEdge = screen !== null;
        anchor = screen ? "right-center" : preferences.placement.anchor;
    }
    onScreensChanged: {
        if (!Routing.contains(screens, selected)) {
            outputLost();
            selected = Routing.select(screens, preferences.placement.output);
        }
    }
    Component.onCompleted: choose(null)
}
