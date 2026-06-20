import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

import "./components"
import "../../theme"

PanelWindow {
    id: barWindow
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    implicitWidth: 500

    mask: Region {}

    Rectangle {
        id: bg
        radius: 30

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: "transparent"
        clip: true
        border.width: 5
        border.color: Colors.transparent(Colors.palette().base, 1)
        layer.enabled: true
        layer.smooth: true

        Canvas {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 36
            height: 36

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                ctx.moveTo(width, 0);
                ctx.arc(width, 0, width, Math.PI, Math.PI * 1.5, true);
                ctx.closePath();
                ctx.fillStyle = Colors.palette().base;
                ctx.fill();
            }
        }

        Canvas {
            anchors.top: parent.top
            anchors.left: parent.left
            width: 36
            height: 36

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                ctx.moveTo(width, height);
                ctx.arc(width, height, width, Math.PI * 0.5, Math.PI, true);
                ctx.closePath();
                ctx.fillStyle = Colors.palette().base;
                ctx.fill();
            }
        }

        Canvas {
            anchors.top: parent.top
            anchors.right: parent.right
            width: 36
            height: 36

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                ctx.moveTo(0, height);
                ctx.arc(0, height, width, 0, Math.PI * 0.5, true);
                ctx.closePath();
                ctx.fillStyle = Colors.palette().base;
                ctx.fill();
            }
        }

        Canvas {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 36
            height: 36
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width, height);
                ctx.arc(0, 0, width, Math.PI * 0.5, 0, true);
                ctx.closePath();
                ctx.fillStyle = Colors.palette().base;
                ctx.fill();
            }
        }
    }
}
