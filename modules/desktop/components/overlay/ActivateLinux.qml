import Quickshell
import QtQuick.Layouts

import QtQuick
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            WlrLayershell.namespace: "quickshell-activatelinux"
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

            WlrLayershell.layer: WlrLayer.Bottom

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
