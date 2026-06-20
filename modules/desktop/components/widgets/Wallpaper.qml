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
            mask: Region {}

            WlrLayershell.namespace: "wallpaper-overview"
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
                id: image2
                anchors.fill: parent
                source: WallpaperManager.settings.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                visible: true
            }

            MultiEffect {
                source: image2
                anchors.fill: image2
                saturation: -0.3
                blur: 0.5
                blurMax: 64
                blurEnabled: true
            }

            Rectangle {
                anchors.topMargin: 240
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                radius: 8

                width: row2.width + 20
                height: 40

                color: Colors.palette().base
                Row {
                    id: row2
                    spacing: 24

                    width: childrenRect.width
                    height: parent.height

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Column {
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 2

                        Text {
                            text: "CPU"
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Colors.palette().subtext0
                        }

                        Rectangle {
                            width: 200
                            height: 8
                            color: Colors.palette().surface0
                            radius: 8

                            Rectangle {
                                width: 100
                                height: parent.height
                                radius: parent.radius
                                color: Colors.palette().pink
                            }
                        }
                    }

                    Column {
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 2

                        Text {
                            text: "RAM"
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Colors.palette().subtext0
                        }

                        Rectangle {
                            width: 200
                            height: 8
                            color: Colors.palette().surface0
                            radius: 8

                            Rectangle {
                                width: 156
                                height: parent.height
                                radius: parent.radius
                                color: Colors.palette().pink
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottomMargin: 240
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                radius: 8

                width: row.width + 20
                height: 40

                color: Colors.palette().base
                Row {
                    id: row
                    spacing: 24

                    height: parent.height

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        color: Colors.palette().subtext0
                        text: "Time 05:14pm"
                    }

                    Text {
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        color: Colors.palette().subtext0
                        text: "Uptime 2hrs 14m"
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            mask: Region {} 

            WlrLayershell.namespace: "wallpaper"
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
