import QtQuick
import QtQuick.Layouts
import "../../colors"

Rectangle {
    id: root
    width: parent.width
    height: childrenRect.height
    color: Color.palette().surface0
    radius: 10

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Code to execute when clicked
            console.log("Rectangle clicked!");
            
        }
    }

    ColumnLayout {
        spacing: 0 // Spacing between the rotated text items
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: "󰤥"
            Layout.alignment: Qt.AlignHCenter
            color: Color.palette().text
        }

        Text {
            text: "󰂯"
            Layout.alignment: Qt.AlignHCenter
            color: Color.palette().text
        }

        Text {
            text: "󰕾"
            Layout.alignment: Qt.AlignHCenter
            color: Color.palette().text
        }

        Text {
            text: "󰂚"
            Layout.alignment: Qt.AlignHCenter
            color: Color.palette().text
        }

        Text {
            text: ""
            Layout.alignment: Qt.AlignHCenter
            color: Color.palette().text
        }
    }
}
