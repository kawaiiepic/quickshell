pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import QtQml.Models
import Quickshell.Hyprland

import "../../ui"
import "../../theme"
import "../../services"

import "../../windows"

BaseOverlay {
    id: root

    implicitWidth: 500
    implicitHeight: 500

    color: Colors.transparent("#000000", 0.7)

    anchors {
        bottom: true
        left: true
        right: true
        top: true
    }

    Rectangle {
        id: container
        anchors.fill: parent
        anchors.margins: 5
        color: "transparent"

        FlexboxLayout {
            id: flexLayout
            anchors.fill: parent
            wrap: FlexboxLayout.Wrap
            direction: FlexboxLayout.Row
            justifyContent: FlexboxLayout.JustifyStart
            gap: 12

            Network {
                Layout.fillWidth: true
                implicitWidth: 500
                implicitHeight: 500
            }
            PlayerCard {
                Layout.fillWidth: true
                implicitWidth: 1000
                implicitHeight: 500
            }
            AIChat {
                overlayRef: root
                Layout.fillWidth: true
                implicitWidth: 500
                implicitHeight: 500
            }
            Monitor {
                Layout.fillWidth: true
                implicitWidth: 500
                implicitHeight: 500
            }
            Notifications {
                Layout.fillWidth: true
                implicitWidth: 500
                implicitHeight: 500
            }
            NowPlaying {
                Layout.fillWidth: true
                implicitWidth: 400
                implicitHeight: 500
            }
        }
    }
}
