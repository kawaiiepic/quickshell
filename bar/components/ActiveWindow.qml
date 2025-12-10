import QtQuick
import QtQuick.Layouts
import "../../colors"

Rectangle {
    width: parent.width
    height: childrenRect.height
    color: Color.palette().surface0
    border.width: 0.5
    border.color: Color.palette().mantle
    radius: 10

    ColumnLayout {
        spacing: 5 // Spacing between the rotated text items
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: ""
            color: Color.palette().text
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 8

            implicitWidth: label.implicitHeight
            implicitHeight: label.implicitWidth

            Text {
                id: label
                anchors.fill: parent
                color: Color.palette().text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Desktop"
                rotation: 90 // Rotate 90 degrees clockwise
                transformOrigin: Item.Center
            }
        }
    }
}
