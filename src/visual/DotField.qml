pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    required property real spacing
    required property real dotRadius
    required property real feather
    property real extentWidth: width
    property bool followBackdrop: false
    property real backdropOpacity: 1
    property real excludedColumnX: -1
    property real excludedYStart: -1
    property real excludedYEnd: -1
    readonly property int columns: Math.max(1, Math.floor(width / spacing))
    readonly property int rows: Math.max(1, Math.floor(height / spacing))
    function falloff(distance: real): real {
        const t = Math.max(0, Math.min(1, distance / feather));
        return t * t * (3 - 2 * t);
    }
    function backgroundOpacity(cx: real, cy: real): real {
        const dx = (cx - root.extentWidth / 2) / (root.extentWidth / 2);
        const dy = (cy - root.height / 2) / (root.height / 2);
        const radius = Math.sqrt(dx * dx + dy * dy);
        const inner = Math.max(0.1, 1 - root.feather / Math.min(root.extentWidth / 2, root.height / 2));
        if (radius >= 1)
            return 0;
        if (radius <= inner)
            return 0.35 * root.backdropOpacity;
        const t = (radius - inner) / (1 - inner);
        return 0.35 * root.backdropOpacity * (1 - t * t * (3 - 2 * t));
    }
    Repeater {
        model: Math.min(2048, root.columns * root.rows)
        Rectangle {
            required property int index
            readonly property real cx: root.spacing / 2 + (index % root.columns) * root.spacing
            readonly property real cy: root.spacing / 2 + Math.floor(index / root.columns) * root.spacing
            x: cx - root.dotRadius
            y: cy - root.dotRadius
            width: root.dotRadius * 2
            height: width
            radius: root.dotRadius
            color: "white"
            visible: !(Math.abs(cx - root.excludedColumnX) < 0.5 && cy >= root.excludedYStart && cy <= root.excludedYEnd)
            opacity: root.followBackdrop ? root.backgroundOpacity(cx, cy) : 0.18 * root.falloff(Math.min(cx, root.extentWidth - cx)) * root.falloff(Math.min(cy, root.height - cy))
        }
    }
}
