import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

import "./components"
import "../../theme"
import "../../services"

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: window

        required property var modelData

        WlrLayershell.namespace: "quickshell-bar"

        visible: !ToplevelManager.activeToplevel.maximized

        Component.onCompleted: {
            Niri;
        }

        anchors {
            top: true
        }

        margins {
            top: 10
        }

        implicitWidth: bar.width
        implicitHeight: 30

        color: "transparent"

        Rectangle {
            id: bar
            width: row.width + 20
            height: parent.height
            color: Colors.transparent(Colors.palette().base, 0.9)
            radius: 18

            HoverHandler {
                id: hover
            }

            Row {
                id: row
                spacing: 8
                anchors.centerIn: parent

                Launcher {
                    visible: hover.hovered
                }

                ActiveWindow {
                    visible: hover.hovered
                    vertical: false
                    screen: window.modelData
                }

                Clock {
                    vertical: false
                }
            }
        }
    }
}
