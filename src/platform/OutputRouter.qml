import QtQuick
import Quickshell
import "EdgeZones.js" as EdgeZones
import "Routing.js" as Routing

QtObject {
    id: root
    required property var preferences
    property var selected: null
    property bool fixedPlacement: false
    property string focusOutput: ""
    property string side: "right"
    property bool fromEdge: false
    readonly property bool locked: fixedPlacement && selected !== null
    readonly property string screenId: selected ? selected.name : ""
    readonly property string anchor: side + "-center"
    readonly property var screens: Quickshell.screens
    readonly property var geometry: selected ? Routing.geometry(selected.width, selected.height, preferences.field, fromEdge ? 0 : preferences.placement.margin, anchor) : ({
            usable: false,
            width: 0,
            height: 0,
            x: 0,
            y: 0
        })
    signal outputLost

    function choose(screen: var, requestedSide: string): void {
        if (locked && Routing.contains(screens, selected))
            return;
        selected = Routing.selectForInvocation(screens, screen, focusOutput, preferences.placement.fallbackOutput);
        fromEdge = screen !== null;
        side = requestedSide || (selected ? EdgeZones.resolveSide(preferences.edge, selected.name) : preferences.edge.side);
    }

    onScreensChanged: {
        if (!Routing.contains(screens, selected)) {
            outputLost();
            selected = Routing.selectForInvocation(screens, null, focusOutput, preferences.placement.fallbackOutput);
            fromEdge = false;
            side = selected ? EdgeZones.resolveSide(preferences.edge, selected.name) : preferences.edge.side;
        }
    }
    Component.onCompleted: choose(null, "")
}
