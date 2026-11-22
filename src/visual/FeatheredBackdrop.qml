import QtQuick

Canvas {
    id: root
    required property real feather
    property color fillColor: "#181818"
    property real centerOpacity: 1
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onFeatherChanged: requestPaint()
    onFillColorChanged: requestPaint()
    onCenterOpacityChanged: requestPaint()
    onPaint: {
        if (width <= 0 || height <= 0)
            return;
        const ctx = getContext("2d");
        ctx.reset();
        ctx.clearRect(0, 0, width, height);
        ctx.save();
        ctx.translate(width / 2, height / 2);
        ctx.scale(width / 2, height / 2);
        const gradient = ctx.createRadialGradient(0, 0, 0, 0, 0, 1);
        const inner = Math.max(0.1, 1 - feather / Math.min(width / 2, height / 2));
        gradient.addColorStop(0, Qt.rgba(fillColor.r, fillColor.g, fillColor.b, centerOpacity));
        for (let i = 0; i <= 12; i++) {
            const t = i / 12;
            const alpha = 1 - t * t * (3 - 2 * t);
            gradient.addColorStop(inner + (1 - inner) * t, Qt.rgba(fillColor.r, fillColor.g, fillColor.b, alpha * centerOpacity));
        }
        ctx.fillStyle = gradient;
        ctx.fillRect(-1, -1, 2, 2);
        ctx.restore();
    }
}
