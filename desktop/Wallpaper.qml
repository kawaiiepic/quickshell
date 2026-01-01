// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import "../colors"
import "../services"

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
                id: image
                anchors.fill: parent
                source: WallpaperManager.currentWallpaper.path
                fillMode: Image.PreserveAspectCrop
            }
        }
    }
}
