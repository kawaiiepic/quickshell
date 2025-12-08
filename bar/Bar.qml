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
            required property var modelData
            screen: modelData
            color: Color.palette().base

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 30

            Column {
                anchors.horizontalCenter: parent.horizontalCenter

                Launcher {}

                Workspaces {}
            }
        }
    }
}
