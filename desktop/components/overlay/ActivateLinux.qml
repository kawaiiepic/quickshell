import QtQuick.Layouts
import QtQuick

import Quickshell
import Quickshell.Io
import QtQuick.Layouts

import QtQuick
import Quickshell.Wayland
import "../../../colors"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            mask: Region {}

            anchors {
                right: true
                bottom: true
            }

            margins {
                right: 50
                bottom: 50
            }

            implicitWidth: content.width
            implicitHeight: content.height

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay

            ColumnLayout {
                id: content

                Text {
                    text: "Activate Linux"
                    color: "#50ffffff"
                    font.pointSize: 22
                }

                Text {
                    text: "Go to Settings to activate Linux"
                    color: "#50ffffff"
                    font.pointSize: 14
                }
            }
        }
    }
}
