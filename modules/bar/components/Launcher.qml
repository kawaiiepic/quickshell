import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Quickshell.Io

Button {
    id: btn
    implicitWidth: 23
    implicitHeight: 23

    property string tooltipText

    Process {
        running: true
        command: ["uname", "-r"]
        stdout: StdioCollector {
            onStreamFinished: {
                btn.tooltipText = `NixOS ${this.text.trim()}`;
            }
        }
    }

    onClicked: {
        print("Clicked!");
    }

    HoverHandler {
        id: hover
    }

    ToolTip.visible: hover.hovered
    ToolTip.text: btn.tooltipText
    background: Rectangle {
        color: "transparent"
    }

    Image {
        id: imageInstance
        source: "/home/mia/.face"
        anchors.centerIn: parent

        property int radius: 20
        width: 23
        height: 23
        visible: true

        layer.enabled: true
        layer.effect: OpacityMask {
            id: opacityMaskInstance
            maskSource: Rectangle {
                id: maskedRect
                width: imageInstance.width
                height: imageInstance.height
                radius: imageInstance.radius
            }
        }
    }
}
