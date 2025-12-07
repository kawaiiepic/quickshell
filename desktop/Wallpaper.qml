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
                source: "/home/mia/Downloads/wallhaven-gpgyw3.jpg"
                fillMode: Image.PreserveAspectCrop
            }
        }
    }
}