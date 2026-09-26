pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../../theme"

Rectangle {
    id: root
    property ShellScreen screen

    width: parent.width
    height: childrenRect.height
    color: Colors.palette().surface1
    radius: 10

    ColumnLayout {
        width: parent.width
        spacing: 6

        Item { Layout.preferredHeight: 4; Layout.fillWidth: true }

        NetworkStatus { screen: root.screen; Layout.alignment: Qt.AlignHCenter }
        BluetoothStatus { screen: root.screen; Layout.alignment: Qt.AlignHCenter }
        AudioStatus { screen: root.screen; Layout.alignment: Qt.AlignHCenter }
        BrightnessStatus { screen: root.screen; Layout.alignment: Qt.AlignHCenter }
        NotifyStatus { screen: root.screen; Layout.alignment: Qt.AlignHCenter }
        PowerProfileStatus { screen: root.screen; Layout.alignment: Qt.AlignHCenter }
        BatteryStatus { screen: root.screen; Layout.alignment: Qt.AlignHCenter }

        Item { Layout.preferredHeight: 4; Layout.fillWidth: true }
    }
}
