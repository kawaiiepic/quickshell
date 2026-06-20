import QtQuick
import "../theme"

Rectangle {
    id: root

    color: "transparent"

    property int cornerSize: 24
    property int cornerRadius: 24
    property var sColor: Colors.transparent(Colors.palette().crust, 0.95)
    property int arrowSize: 10

    property bool show: true
    required property var parentWindow

    default property alias contentChildren: inner.data

    // anchors.fill: parent

    onShowChanged: {
        if (show) parentWindow.visible = true
    }

    transform: Translate {
        y: root.show ? 0 : root.height + root.arrowSize

        Behavior on y {
            SequentialAnimation {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                ScriptAction {
                    script: { if (!root.show) parentWindow.visible = false }
                }
            }
        }
    }

    // ── arrow pointing down ──────────────────────────────────────────────

    Canvas {
        id: arrow
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.arrowSize * 2
        height: root.arrowSize

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = root.sColor
            ctx.fill()
        }
    }

    // ── main body ────────────────────────────────────────────────────────

    Rectangle {
        id: inner
        color: root.sColor
        topLeftRadius: root.cornerRadius
        topRightRadius: root.cornerRadius
        bottomLeftRadius: root.cornerRadius
        bottomRightRadius: root.cornerRadius

        border.width: 1.5
        border.color: Colors.palette().crust

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: arrow.top
    }
}