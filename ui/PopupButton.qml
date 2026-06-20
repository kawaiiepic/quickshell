import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell

import "../theme"

Rectangle {
    id: root

    implicitWidth: row.implicitWidth + 16
    implicitHeight: row.implicitHeight + 10

    required property string text
    required property var clicked
    property string iconName
    property bool menu: false

    color: hover.hovered ? Colors.palette().surface0 : Colors.palette().base
    radius: 8

    RowLayout {
        id: row
        spacing: 8

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.centerIn: parent

        IconImage {
            visible: root.iconName
            implicitHeight: 25
            implicitWidth: 25
            source: Quickshell.iconPath(root.iconName, "unknown")
        }

        Text {
            text: root.text ?? "Missing"
            color: hover.hovered ? Colors.palette().text : Colors.palette().subtext0
        }

        Text {
            visible: root.menu
            text: ""
            color: hover.hovered ? Colors.palette().pink : Colors.palette().subtext0
        }

        HoverHandler {
            id: hover
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            print("Clicked");
            root.clicked?.();
        }
    }
}
