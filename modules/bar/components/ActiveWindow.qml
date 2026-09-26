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
    property bool vertical: true

    implicitWidth: root.vertical ? parent.width : 200
    implicitHeight: root.vertical ? childrenRect.height : parent.height

    color: "transparent"

    readonly property var win: Compositor.focusedWindow
    readonly property string iconSource: win && win.iconSource ? win.iconSource : Quickshell.iconPath("desktop")
    readonly property string titleText: win ? (win.title || "Desktop") : "Desktop"
    readonly property string appText: win ? (win.appId || "") : ""

    Row {
        visible: !root.vertical
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        IconImage {
            implicitWidth: 16
            implicitHeight: 16
            source: root.iconSource
        }

        Text {
            color: Colors.palette().text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: root.titleText
            elide: Text.ElideRight
            width: 160
        }
    }

    ColumnLayout {
        visible: root.vertical
        spacing: 8
        width: parent.width

        BasePopup {
            id: popup
            parentItem: root
            screen: root.screen

            ColumnLayout {
                IconImage {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: root.iconSource
                }

                Text {
                    text: root.titleText
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.palette().text
                    elide: Text.ElideRight
                    Layout.preferredWidth: 180
                }

                Text {
                    text: root.appText
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.palette().subtext0
                    elide: Text.ElideRight
                    Layout.preferredWidth: 180
                }
            }
        }

        IconImage {
            implicitWidth: 16
            implicitHeight: 16
            Layout.alignment: Qt.AlignHCenter
            source: root.iconSource
            Layout.topMargin: 8
        }

        Item {
            id: boop
            Layout.bottomMargin: 8
            Layout.alignment: Qt.AlignHCenter

            property int maxText: Math.min(Math.max(rotated.implicitWidth + 1, 50), 220)

            implicitHeight: maxText
            implicitWidth: rotated.implicitHeight

            Text {
                id: rotated
                anchors.centerIn: parent
                color: Colors.palette().text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: root.titleText
                elide: Text.ElideRight
                width: boop.maxText
                rotation: 90
                transformOrigin: Item.Center
            }
        }
    }
}
