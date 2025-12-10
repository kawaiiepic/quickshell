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
    property string time

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
                // anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                width: 22
                spacing: 8

                Launcher {}

                Workspaces {}

                // Item {
                //     Layout.fillHeight: true
                // }

                ActiveWindow {}

                Clock {}

                Status {}

                Power {}

                // Item {
                //     Layout.fillHeight: true
                // } // flexible spacer

                // SystemTray {}
            }
        }
    }
}
