import Quickshell
import QtQuick
import Quickshell.Wayland

Scope {
    id: wallpaper

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            mask: Region {}

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Normal

            color: "transparent"

            Rectangle {
                id: border
                anchors.fill: parent
                color: "transparent"
                border.width: 9
                border.color: Colors.palette().base
                antialiasing: true
            }
        }
    }
}
