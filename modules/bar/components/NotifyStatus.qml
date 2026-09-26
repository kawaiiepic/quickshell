pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../../ui"
import "../../../theme"
import "../../../services"

Text {
    id: root
    property ShellScreen screen

    text: NotificationManager.doNotDisturb ? "dnd" : (NotificationManager.historyNotifications.count > 0 ? "ntf" : "off")
    color: popup.show ? Colors.palette().pink : Colors.palette().text
    font.pixelSize: 11
    horizontalAlignment: Text.AlignHCenter

    BasePopup {
        id: popup
        parentItem: root
        screen: root.screen

        ColumnLayout {
            width: 280
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Notifications"; color: Colors.palette().text; Layout.fillWidth: true }
                Text {
                    text: NotificationManager.doNotDisturb ? "DND" : "On"
                    color: NotificationManager.doNotDisturb ? Colors.palette().red : Colors.palette().green
                    font.pixelSize: 11
                }
            }

            RowLayout {
                Layout.fillWidth: true
                PopupButton {
                    text: NotificationManager.doNotDisturb ? "Disable DND" : "Do not disturb"
                    clicked: () => NotificationManager.doNotDisturb = !NotificationManager.doNotDisturb
                }
                PopupButton {
                    text: "Clear"
                    clicked: () => NotificationManager.clearHistory()
                }
            }

            Repeater {
                model: NotificationManager.historyNotifications
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: col.implicitHeight + 10
                    radius: 8
                    color: Colors.palette().surface0

                    ColumnLayout {
                        id: col
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        spacing: 2
                        Text { text: row.modelData.appName || "App"; color: Colors.palette().subtext0; font.pixelSize: 10 }
                        Text { text: row.modelData.summary || ""; color: Colors.palette().text; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        Text {
                            visible: !!(row.modelData.body)
                            text: row.modelData.body || ""
                            color: Colors.palette().subtext1
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Text {
                visible: NotificationManager.historyNotifications.count === 0
                text: "No notifications"
                color: Colors.palette().subtext0
            }
        }
    }
}
