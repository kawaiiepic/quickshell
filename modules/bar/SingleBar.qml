import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

import "./components"
import "../../theme"
import "../../services"

PanelWindow {

    Component.onCompleted: {
        Niri;
    }

    anchors {
        top: true
    }

    margins {
        top: 10
    }

    implicitWidth: 100
    implicitHeight: 30

    color: "transparent"

    Rectangle {
        id: bar
        width: parent.width
        height: parent.height
        color: Colors.transparent(Colors.palette().base, 0.9)
        radius: 18

        Row {
            anchors.centerIn: parent
            Clock {
                vertical: false
            }
        }
    }
}
