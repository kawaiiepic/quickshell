import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Hyprland

import "../../../ui"
import "../../../services"
import "../../../theme"

Rectangle {
    id: root

    property ShellScreen screen
    property bool vertical: true

    property var focusedWindow: {
        const ws = Hyprland.focusedWorkspace;
        const active = Hyprland.activeToplevel;

        if (!ws || !active)
            return null;

        for (const window of ws.toplevels.values) {
            if (window === active)
                return active;
        }

        return null;
    }

    implicitWidth: root.vertical ? parent.width : 200
    implicitHeight: root.vertical ? childrenRect.height : parent.height

    color: "transparent"

    Row {
        visible: !root.vertical

        IconImage {
            implicitWidth: 16
            implicitHeight: 16
            Layout.alignment: Qt.AlignHCenter

            source: root.focusedWindow?.wayland?.appId
                ? Quickshell.iconPath(
                    root.focusedWindow.wayland.appId,
                    "desktop"
                )
                : Quickshell.iconPath("desktop")

            Layout.topMargin: 8
        }

        Text {
            id: label

            color: Colors.palette().text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: root.focusedWindow?.title ?? "Desktop"
            elide: Text.ElideRight
        }
    }

    ColumnLayout {
        id: layout

        visible: root.vertical
        spacing: 8

//         BasePopup {
//             id: popup
//
//             parentItem: root
//             screen: root.screen
//
//             ColumnLayout {
//
//                 IconImage {
//                     Layout.preferredWidth: 24
//                     Layout.preferredHeight: 24
//
//                     source: root.focusedWindow?.wayland?.appId
//                         ? Quickshell.iconPath(
//                             root.focusedWindow.wayland.appId,
//                             "desktop"
//                         )
//                         : Quickshell.iconPath("desktop")
//                 }
//
//                 Text {
//                     text: root.focusedWindow?.title ?? "Desktop"
//
//                     horizontalAlignment: Text.AlignHCenter
//                     color: Colors.palette().text
//                     elide: Text.ElideRight
//                 }
//
//                 Text {
//                     text: root.focusedWindow?.wayland?.appId ?? ""
//
//                     horizontalAlignment: Text.AlignHCenter
//                     color: Colors.palette().text
//                     elide: Text.ElideRight
//                 }
//             }
//         }

        IconImage {
            implicitWidth: 16
            implicitHeight: 16
            Layout.alignment: Qt.AlignHCenter

            source: root.focusedWindow?.wayland?.appId
                ? Quickshell.iconPath(
                    root.focusedWindow.wayland.appId,
                    "desktop"
                )
                : Quickshell.iconPath("desktop")

            Layout.topMargin: 8
        }

        Item {
            id: boop

            Layout.bottomMargin: 8

            property int maxText:
                Math.min(
                    Math.max(label2.implicitWidth + 1, 50),
                    300
                )

            implicitHeight: maxText
            implicitWidth: label2.implicitHeight

            Text {
                id: label2

                anchors.centerIn: parent

                color: Colors.palette().text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: root.focusedWindow?.title ?? "Desktop"

                elide: Text.ElideRight
                width: boop.maxText

                rotation: 90
                transformOrigin: Item.Center
            }
        }
    }
}
