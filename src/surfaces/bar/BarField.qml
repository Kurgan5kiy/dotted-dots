import QtQuick
import "Lattice.js" as Lattice

Canvas {
    id: root
    required property string edge
    required property real spacing
    property var workspaceNodes: []
    property var dotExclusions: []
    property string nodeSignature: ""
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onEdgeChanged: requestPaint()
    onWorkspaceNodesChanged: {
        const signature = workspaceNodes.map(node => Math.round(node.x * 10) + ":" + Math.round(node.y * 10)).join("|");
        if (signature !== nodeSignature) {
            nodeSignature = signature;
            requestPaint();
        }
    }
    onSpacingChanged: requestPaint()
    onDotExclusionsChanged: requestPaint()

    function smoothstep(t: real): real {
        const v = Math.max(0, Math.min(1, t));
        return v * v * (3 - 2 * v);
    }
    function fieldAlpha(depth: real): real {
        return 0.96 * (1 - smoothstep((depth - 10) / 36));
    }
    onPaint: {
        const context = getContext("2d");
        context.clearRect(0, 0, width, height);
        const horizontal = edge === "top" || edge === "bottom";
        const reverse = edge === "bottom" || edge === "right";
        const length = horizontal ? width : height;
        const depth = horizontal ? height : width;
        if (length <= 0 || depth <= 0)
            return;
        const edgeGradient = horizontal ? context.createLinearGradient(0, reverse ? height : 0, 0, reverse ? height - 46 : 46) : context.createLinearGradient(reverse ? width : 0, 0, reverse ? width - 46 : 46, 0);
        edgeGradient.addColorStop(0, "rgba(18,18,20,0.96)");
        edgeGradient.addColorStop(0.22, "rgba(18,18,20,0.96)");
        edgeGradient.addColorStop(0.55, "rgba(18,18,20,0.66)");
        edgeGradient.addColorStop(1, "rgba(18,18,20,0)");
        context.fillStyle = edgeGradient;
        context.fillRect(0, 0, width, height);
        for (let row = 0; row < Math.ceil(height / spacing); row++) {
            const y = edge === "bottom" ? height - spacing / 2 - row * spacing : spacing / 2 + row * spacing;
            for (let column = 0; column < Math.ceil(width / spacing); column++) {
                const x = edge === "right" ? width - spacing / 2 - column * spacing : spacing / 2 + column * spacing;
                if (Lattice.isOccupied(x, y, workspaceNodes) || Lattice.isCovered(x, y, dotExclusions))
                    continue;
                const localDepth = reverse ? (horizontal ? height - y : width - x) : (horizontal ? y : x);
                const alpha = fieldAlpha(localDepth);
                if (alpha < 0.015)
                    continue;
                context.fillStyle = "rgba(255,255,255," + (0.35 * alpha) + ")";
                context.beginPath();
                context.arc(x, y, 1.5, 0, Math.PI * 2);
                context.fill();
            }
        }
    }
}
