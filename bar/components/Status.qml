import QtQuick
import QtQuick.Layouts

Rectangle {
    width: parent.width
    height: childrenRect.height
    color: "lightgray"
    radius: 10

    ColumnLayout {
        spacing: 0 // Spacing between the rotated text items
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: "󰤥"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "󰂯"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "󰕾"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "󰂚"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: ""
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
