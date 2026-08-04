import QtQuick
import "../theme"

Rectangle {
    id: root

    color: "transparent"

    property string pos: "bottom"
    property int cornerSize: 24
    property int cornerRadius: 24
    property var sColor: Colors.transparent(Colors.palette().base, 1)

    property bool show: true
    required property var parentWindow

    default property alias contentChildren: inner.data

    property int padding: 10
    property int addedHeight: root.pos == "left" ? leftCorner.height * 2 : 0

    implicitWidth: inner.implicitWidth + padding
    implicitHeight: inner.implicitHeight + addedHeight + padding

    onShowChanged: {
        if (show) {
            parentWindow.visible = true;
        }
    }

    transform: Translate {
        id: translate
        x: root.show ? 0 : -root.width

        Behavior on x {
            SequentialAnimation {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                ScriptAction {
                    script: {
                        if (!root.show)
                            parentWindow.visible = false;
                    }
                }
            }
        }
    }

    Rectangle {
        id: inner
        color: root.sColor

        border.width: 0

        implicitHeight: inner.childrenRect.height
        implicitWidth: inner.childrenRect.width

        // anchors.verticalCenter: parent.verticalCenter

        bottomLeftRadius: root.pos == "bottom" || root.pos == "bottom-right" || root.pos == "left" ? 0 : root.cornerRadius
        bottomRightRadius: root.pos == "right" || root.pos == "top-right" || root.pos == "bottom" || root.pos == "bottom-right" ? 0 : root.cornerRadius
        topLeftRadius: root.pos == "top-right" || root.pos == "top" || root.pos == "left" ? 0 : root.cornerRadius
        topRightRadius: root.pos == "right" || root.pos == "top-right" || root.pos == "top" || root.pos == "bottom-right" ? 0 : root.cornerRadius

        anchors.left: root.pos == "left" ? leftCorner.left : bottomLeftCorner.right
        anchors.right: root.pos == "right" ? canvas2.right : root.pos == "top-right" ? canvas4.right : root.pos == "bottom-right" ? upRightCorner.right : root.pos == "bottom" || root.pos == "top" ? bottomRightCorner.left : undefined
        anchors.top: root.pos == "right" ? canvas1.bottom : root.pos == "bottom-right" ? upRightCorner.bottom : root.pos == "left" ? leftCorner.bottom : topRightCorner.top
        anchors.bottom: root.pos == "right" ? canvas2.top : root.pos == "top-right" ? canvas4.top : root.pos == "left" ? corner20.top : bottomLeftCorner.bottom
    }

    Canvas {
        id: topRightCorner
        visible: root.pos == "top" || root.pos == "top-right"
        anchors.top: parent.top
        anchors.left: parent.left
        width: root.cornerSize
        height: root.cornerSize

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
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: canvas1
        visible: root.pos == "right"
        anchors.top: parent.top
        anchors.right: parent.right
        width: root.cornerSize
        height: root.cornerSize

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width, height);
            ctx.arc(0, 0, width, Math.PI * 0.5, 0, true);
            ctx.closePath();
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {

        visible: root.pos == "top"
        anchors.top: parent.top
        anchors.right: parent.right
        width: root.cornerSize
        height: root.cornerSize

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
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: bottomLeftCorner
        visible: root.pos == "bottom" || root.pos == "bottom-right"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: root.cornerSize
        height: root.cornerSize
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width, height);
            ctx.arc(0, 0, width, Math.PI * 0.5, 0, true);
            ctx.closePath();
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: canvas2
        visible: root.pos == "right"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root.cornerSize
        height: root.cornerSize
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
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: upRightCorner
        visible: root.pos == "bottom-right"
        anchors.top: parent.top
        anchors.right: parent.right
        width: root.cornerSize
        height: root.cornerSize
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width, height);
            ctx.arc(0, 0, width, Math.PI * 0.5, 0, true);
            ctx.closePath();
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: canvas4
        visible: root.pos == "top-right"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root.cornerSize
        height: root.cornerSize

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
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: bottomRightCorner
        visible: root.pos == "bottom"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root.cornerSize
        height: root.cornerSize

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
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: leftCorner
        visible: root.pos == "left"
        anchors.top: parent.top
        anchors.left: parent.left
        width: root.cornerSize
        height: root.cornerSize

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
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }

    Canvas {
        id: corner20
        visible: root.pos == "left"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: root.cornerSize
        height: root.cornerSize

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
            ctx.fillStyle = root.sColor;
            ctx.fill();
        }
    }
}
