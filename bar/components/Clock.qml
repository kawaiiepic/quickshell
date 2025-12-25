import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../colors"

Item {
    // anchors.horizontalCenter: parent.horizontalCenter
    height: childrenRect.height

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            text: ""
            Layout.alignment: Qt.AlignHCenter
            color: Color.palette().text
        }

        Text {
            text: Qt.formatDateTime(clock.date, "hh\nmm")
            Layout.alignment: Qt.AlignHCenter
            color: Color.palette().text
        }
    }
}
