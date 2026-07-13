import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "../../../../services"
import "../../../../theme"

Scope {
    id: wallpaper

    reloadableId: "wallpapers"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: WallpaperManager.settings.wallpaperType == "static"
            mask: Region {}

            WlrLayershell.namespace: "quickshell-wallpaper"
            WlrLayershell.layer: WlrLayer.Background
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            aboveWindows: false

            Image {
                id: image3
                anchors.fill: parent
                source: WallpaperManager.settings.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                visible: true
            }
        }
    }
}
