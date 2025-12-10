import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    anchors.horizontalCenter: parent.horizontalCenter
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
        }

        Text {
            text: Qt.formatDateTime(clock.date, "hh\nmm")
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
