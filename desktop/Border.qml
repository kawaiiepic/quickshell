// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import "../colors"

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
                border.color: Color.palette().base
                antialiasing: true
            }

            Rectangle {
                id: bg
                anchors.fill: parent
                radius: 30
                color: "transparent"
                clip: true
                border.width: 9
                border.color: Color.palette().base
                layer.enabled: true
                layer.smooth: true
                // layer.effect: DropShadow {
                // color: Color.palette().base
                // radius: 1
                // samples: 32
                // spread: 1
            }
        }
    }
}