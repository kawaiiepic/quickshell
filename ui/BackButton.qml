import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control
    required property var clicked

    background: Rectangle {
        implicitWidth: 70
        implicitHeight: 30
        opacity: enabled ? 1 : 0.3
        color: Color.palette().surface0
        radius: 12
    }

    RowLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: ""
            color: control.down ? Color.palette().pink : Color.palette().text
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: "Back"
            font.pixelSize: 14
            color: control.down ? Color.palette().pink : Color.palette().text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }
    }

    onClicked: {
        clicked?.();
    }
}
