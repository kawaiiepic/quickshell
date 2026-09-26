pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../../ui"
import "../../../theme"

ColumnLayout {
    id: root
    property ShellScreen screen
    property bool vertical: true
    property int viewYear: clock.date.getFullYear()
    property int viewMonth: clock.date.getMonth()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        visible: !root.vertical
        text: Qt.formatDateTime(clock.date, "ddd dd   hh:mm")
        color: popup.show ? Colors.palette().pink : Colors.palette().text
    }
    Text {
        visible: root.vertical
        text: "cal"
        Layout.alignment: Qt.AlignHCenter
        color: popup.show ? Colors.palette().pink : Colors.palette().text
        font.pixelSize: 11
    }
    Text {
        visible: root.vertical
        text: Qt.formatDateTime(clock.date, "hh\nmm")
        Layout.alignment: Qt.AlignHCenter
        color: popup.show ? Colors.palette().pink : Colors.palette().text
    }

    BasePopup {
        id: popup
        parentItem: root
        screen: root.screen
        ColumnLayout {
            spacing: 8
            width: 240
            Text {
                text: Qt.formatDateTime(clock.date, "dddd, MMM d")
                color: Colors.palette().text
                font.pixelSize: 14
            }
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "<"
                    onClicked: {
                        if (root.viewMonth === 0) { root.viewMonth = 11; root.viewYear -= 1; }
                        else root.viewMonth -= 1;
                    }
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: Colors.palette().text }
                }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale("en_US").monthName(root.viewMonth) + " " + root.viewYear
                    color: Colors.palette().text
                }
                Button {
                    text: ">"
                    onClicked: {
                        if (root.viewMonth === 11) { root.viewMonth = 0; root.viewYear += 1; }
                        else root.viewMonth += 1;
                    }
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: Colors.palette().text }
                }
            }
            DayOfWeekRow {
                locale: Qt.locale("en_US")
                Layout.fillWidth: true
                delegate: Text {
                    required property string shortName
                    text: shortName
                    color: Colors.palette().subtext0
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 10
                }
            }
            MonthGrid {
                id: grid
                Layout.fillWidth: true
                month: root.viewMonth
                year: root.viewYear
                locale: Qt.locale("en_US")
                delegate: Text {
                    required property var model
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: grid.locale.toString(model.date, "d")
                    opacity: model.month === grid.month ? 1 : 0.35
                    color: {
                        const today = clock.date;
                        const isToday = model.day === today.getDate() && model.month === today.getMonth() && model.year === today.getFullYear();
                        return isToday ? Colors.palette().pink : Colors.palette().text;
                    }
                    font.pixelSize: 12
                }
            }
        }
    }
}
