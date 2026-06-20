import QtQuick 2.9

Item {
    id: root

    property int size: 150
    property int lineWidth: 8

    property double value1: 0.3   // GPU temp
    property double value2: 0.5   // GPU usage

    property color color1: "#29b6f6"
    property color color2: "#f44336"
    property color backgroundColor: "#e0e0e0"

    property int animationDuration: 1000
    property real gapDegrees: 15 // transparent gap between segments

    width: size + 20
    height: size + 20

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.lineCap = 'round';
            ctx.lineWidth = root.lineWidth;

            var x = width / 2;
            var y = height / 2;
            var radius = root.size / 2 - root.lineWidth;

            var startAngle = Math.PI * 3 / 8; // 135°
            var totalSweep = Math.PI * 5 / 3; // 270°
            var gap = (Math.PI / 180) * root.gapDegrees;

            // --- Segment fractions ---
            var segment1Fraction = 0.5; // fraction of totalSweep
            var segment2Fraction = 1 - segment1Fraction;

            // --- Segment 1 background ---
            var seg1Start = startAngle;
            var seg1End = seg1Start + totalSweep * segment1Fraction;
            ctx.beginPath();
            ctx.arc(x, y, radius, seg1Start, seg1End);
            ctx.strokeStyle = root.backgroundColor;
            ctx.stroke();

            // --- Segment 1 foreground ---
            var arc1Length = (seg1End - seg1Start) * value1;
            var arc1End = Math.min(seg1Start + arc1Length, seg1End - gap); // clip to leave gap
            ctx.beginPath();
            ctx.arc(x, y, radius, seg1Start, arc1End);
            ctx.strokeStyle = root.color1;
            ctx.stroke();

            // --- Segment 2 background ---
            var seg2Start = seg1End + gap; // leave gap after segment1
            var seg2End = seg2Start + totalSweep * segment2Fraction;
            ctx.beginPath();
            ctx.arc(x, y, radius, seg2Start, seg2End);
            ctx.strokeStyle = root.backgroundColor;
            ctx.stroke();

            // --- Segment 2 foreground ---
            var arc2Length = (seg2End - seg2Start) * value2;
            var arc2End = Math.min(seg2Start + arc2Length, seg2End - gap); // clip to leave gap
            ctx.beginPath();
            ctx.arc(x, y, radius, seg2Start, arc2End);
            ctx.strokeStyle = root.color2;
            ctx.stroke();

            // --- Center text ---
            ctx.fillStyle = "#000";
            ctx.font = "bold 16px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillText("GPU", x, y);

            // Foreground arc2 (clipped for gap)
            var labelAngle = seg2End + gap;

            var textRadius = radius;
            var textX = x + textRadius * Math.cos(labelAngle);
            var textY = y + textRadius * Math.sin(labelAngle);

            ctx.fillStyle = "#000";
            ctx.font = "14px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillText("Gay", textX, textY);
        }
    }

    onValue1Changed: canvas.deg1 = value1 * 270
    onValue2Changed: canvas.deg2 = value2 * 270
}
