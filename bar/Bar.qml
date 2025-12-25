// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../colors"
import "./components"
import "../modules/niri"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData
            color: Color.palette().base

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 30

            ColumnLayout {
                anchors.right: parent.right
                width: 22
                height: parent.height
                spacing: 8

                Launcher {
                    Layout.topMargin: 5
                }

                Workspaces {}

                Item {
                    Layout.fillHeight: true
                }

                ActiveWindow {}

                Item {
                    Layout.fillHeight: true
                }

                SystemTray {}

                Clock {}

                Status {}

                Power {
                    Layout.bottomMargin: 5
                }

                //
            }
        }
    }
}
