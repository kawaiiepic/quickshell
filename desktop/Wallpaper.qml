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

            aboveWindows: false

            Image {
                anchors.fill: parent
                source: "/home/mia/Downloads/8d00848209764be51803e8bad3677503.jpg"
                fillMode: Image.PreserveAspectCrop
            }
        }
    }
}