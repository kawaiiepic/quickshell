import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import "../../../ui"
import "../../../services"
import "../../../theme"

Rectangle {
    id: root

    property ShellScreen screen

    implicitWidth: parent.width
    implicitHeight: childrenRect.height

    color: "transparent"

    ColumnLayout {
        id: layout
        spacing: 8

        BasePopup {
            id: popup

            parentItem: root
            screen: root.screen

            ColumnLayout {

                IconImage {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: Niri.focusedWindow?.iconPath ? "file://" + Niri.focusedWindow.iconPath : "" ?? ""
                }

                Text {
                    text: Niri.focusedWindow ? Niri.focusedWindow.title : "Desktop"
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.palette().text
                    elide: Text.ElideRight
                }

                Text {
                    text: Niri.focusedWindow ? Niri.focusedWindow.appId : ''
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.palette().text
                    elide: Text.ElideRight
                }
            }
        }

        IconImage {
            implicitWidth: 16
            implicitHeight: 16
            Layout.alignment: Qt.AlignHCenter
            source: Niri.focusedWindow?.iconPath ? "file://" + Niri.focusedWindow.iconPath : Quickshell.iconPath("desktop")

            Layout.topMargin: 8
        }

        Item {
            id: boop
            Layout.bottomMargin: 8

            property int maxText: Math.min(Math.max(label.implicitWidth + 1, 50), 300)

            implicitHeight: maxText
            implicitWidth: label.implicitHeight

            Text {
                id: label
                anchors.centerIn: parent
                color: Colors.palette().text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Niri.focusedWindow ? Niri.focusedWindow.title : "Desktop"
                elide: Text.ElideRight
                width: boop.maxText
                rotation: 90
                transformOrigin: Item.Center
            }
        }
    }
}
