import QtQuick

import "../theme"

Canvas {
    id: squiggleCanvas
    width: parent.implicitWidth
    height: 40

    property real padding: 5
    property real lineWidth: 4
    property real lineHeight: 20
    property real amplitude: 8
    property real frequency: 10

    property double value: 0.0
    property double tempValue: 0.0
    property bool scrollable: false
    property bool dragging: false
    required property var onUpdate

    readonly property real currentX: padding + tempValue * (width - 2 * padding)

    onValueChanged: {
        if (!dragging)
            tempValue = value;
    }

    onTempValueChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        ctx.lineWidth = 3;
        ctx.lineCap = "round";

        // ---- line BEFORE cursor ----
        ctx.strokeStyle = Colors.palette().pink;
        ctx.beginPath();
        for (var x = padding; x <= currentX; x++) {
            var y = height / 2 + Math.sin(x / frequency) * amplitude;
            if (x === padding)
                ctx.moveTo(x, y);
            else
                ctx.lineTo(x, y);
        }
        ctx.stroke();

        // ---- line AFTER cursor ----

        ctx.strokeStyle = Colors.palette().overlay0;
        ctx.beginPath();

        var flatY = height / 2 + Math.sin(currentX / frequency) * amplitude;
        var startX = Math.min(currentX + 7, width - padding);

        ctx.moveTo(startX, flatY);
        ctx.lineTo(width - padding, flatY);

        ctx.stroke();

        if (squiggleCanvas.scrollable) {
            var lw = lineWidth;
            var lh = lineHeight;
            var centerY = height / 2 + Math.sin(currentX / frequency) * amplitude;
            var topY = centerY - lh / 2;
            var bottomY = centerY + lh / 2;

            ctx.fillStyle = Colors.palette().pink;
            ctx.beginPath();
            ctx.arc(currentX, topY + lw / 2, lw / 2, Math.PI, 0, false);
            ctx.rect(currentX - lw / 2, topY + lw / 2, lw, lh - lw);
            ctx.arc(currentX, bottomY - lw / 2, lw / 2, 0, Math.PI, false);
            ctx.fill();
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: squiggleCanvas.dragging = true
        onReleased: mouse => {
            squiggleCanvas.dragging = false;
            squiggleCanvas.onUpdate(mouse.x);
        }
        onCanceled: squiggleCanvas.dragging = false
        onPositionChanged: mouse => squiggleCanvas.tempValue = Math.max(0, Math.min(1, (mouseX) / (width - 2)))
    }
}
