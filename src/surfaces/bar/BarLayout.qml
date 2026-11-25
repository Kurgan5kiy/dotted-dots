pragma ComponentBehavior: Bound
import QtQuick
import "../../widgets/bar"
import "ModuleAccent.js" as ModuleAccent

Item {
    id: root
    required property var entries
    required property bool vertical
    required property string edge
    required property real gridSpacing
    required property real reserveDepth
    required property var audio
    required property var battery
    required property var tray
    required property var workspaceAdapter
    required property string outputName
    signal volumeRequested
    signal menuStateChanged(bool open)
    property var widgetRepeater: null
    implicitWidth: loader.implicitWidth
    implicitHeight: loader.implicitHeight
    function workspaceNodes(target: var): var {
        if (!widgetRepeater)
            return [];
        const nodes = [];
        for (let i = 0; i < widgetRepeater.count; i++) {
            const widget = widgetRepeater.itemAt(i);
            if (!widget || widget.kind !== "workspaces")
                continue;
            for (let j = 0; j < root.workspaceAdapter.forOutput(root.outputName).length; j++) {
                const local = widget.workspaceNodeLocal(j);
                nodes.push(widget.mapToItem(target, local.x, local.y));
            }
        }
        return nodes;
    }
    function moduleRegions(target: var): var {
        return ModuleAccent.regions(widgetRepeater, target, root.vertical);
    }
    function dotExclusions(target: var): var {
        if (!widgetRepeater)
            return [];
        const regions = [];
        for (let i = 0; i < widgetRepeater.count; i++) {
            const widget = widgetRepeater.itemAt(i);
            if (!widget)
                continue;
            const region = widget.dotExclusion(target);
            if (region)
                regions.push(region);
        }
        return regions;
    }

    Component {
        id: horizontalLayout
        Row {
            Component.onCompleted: root.widgetRepeater = horizontalRepeater
            Component.onDestruction: {
                if (root.widgetRepeater === horizontalRepeater)
                    root.widgetRepeater = null;
            }
            spacing: root.gridSpacing
            Repeater {
                id: horizontalRepeater
                model: root.entries
                delegate: BarWidget {
                    required property var modelData
                    kind: modelData.type
                    vertical: false
                    edge: root.edge
                    gridSpacing: root.gridSpacing
                    reserveDepth: root.reserveDepth
                    audio: root.audio
                    battery: root.battery
                    tray: root.tray
                    workspaceAdapter: root.workspaceAdapter
                    outputName: root.outputName
                    onVolumeRequested: root.volumeRequested()
                    onMenuStateChanged: open => root.menuStateChanged(open)
                }
            }
        }
    }
    Component {
        id: verticalLayout
        Column {
            Component.onCompleted: root.widgetRepeater = verticalRepeater
            Component.onDestruction: {
                if (root.widgetRepeater === verticalRepeater)
                    root.widgetRepeater = null;
            }
            spacing: root.gridSpacing
            Repeater {
                id: verticalRepeater
                model: root.entries
                delegate: BarWidget {
                    required property var modelData
                    kind: modelData.type
                    vertical: true
                    edge: root.edge
                    gridSpacing: root.gridSpacing
                    reserveDepth: root.reserveDepth
                    audio: root.audio
                    battery: root.battery
                    tray: root.tray
                    workspaceAdapter: root.workspaceAdapter
                    outputName: root.outputName
                    onVolumeRequested: root.volumeRequested()
                    onMenuStateChanged: open => root.menuStateChanged(open)
                }
            }
        }
    }
    Loader {
        id: loader
        sourceComponent: root.vertical ? verticalLayout : horizontalLayout
    }
}
