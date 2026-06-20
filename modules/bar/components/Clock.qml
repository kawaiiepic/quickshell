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

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // anchors.horizontalCenter: parent.horizontalCenter

    Text {
        visible: !root.vertical
        text: "" + " " + Qt.formatDateTime(clock.date, "hh:mm")
        color: popup.show ? Colors.palette().pink : Colors.palette().text
    }
    Text {
        visible: root.vertical
        text: ""
        Layout.alignment: Qt.AlignHCenter
        color: popup.show ? Colors.palette().pink : Colors.palette().text
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

            Text {
                text: "Calendar"
                color: Colors.palette().text
            }

            Rectangle {
                id: calendar
                width: 200
                height: 200

                ListView {
                    id: listview

                    width: calendar.width
                    height: calendar.height
                    // property int padding: 5
                    snapMode: ListView.SnapOneItem
                    orientation: ListView.Horizontal
                    highlightRangeMode: ListView.StrictlyEnforceRange

                    model: CalendarModel {
                        from: new Date(clock.date.getFullYear(), 0, 1)
                        to: new Date(clock.date.getFullYear(), 11, 31)
                    }

                    currentIndex: clock.date.getMonth()

                    delegate: ColumnLayout {
                        id: month
                        required property var month
                        required property var year

                        implicitWidth: 100
                        Layout.preferredWidth: 200

                        Text {
                            id: title
                            text: grid.title
                            color: month.month == clock.date.getMonth() ? Colors.palette().pink : Colors.palette().text
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            // anchors.centerIn: month
                        }

                        GridLayout {

                            columns: 2

                            DayOfWeekRow {
                                locale: grid.locale

                                Layout.preferredWidth: listview.width - listview.padding

                                Layout.column: 1
                                Layout.fillWidth: true

                                delegate: Text {
                                    text: shortName
                                    color: Colors.palette().subtext0
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                    required property string shortName
                                }
                            }

                            WeekNumberColumn {
                                month: grid.month
                                year: grid.year
                                locale: grid.locale

                                Layout.preferredHeight: listview.height - listview.padding - title.implicitHeight - 10

                                delegate: Text {
                                    text: weekNumber
                                    color: Colors.palette().subtext0
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                    required property int weekNumber
                                }
                            }

                            MonthGrid {
                                id: grid

                                Layout.preferredWidth: listview.width
                                Layout.preferredHeight: listview.height - title.implicitHeight

                                month: month.month
                                year: month.year
                                locale: Qt.locale("en_US")
                                delegate: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    opacity: month.month === model.month ? 1 : 0.8
                                    text: grid.locale.toString(model.date, "d")
                                    color: month.month === model.month ? (clock.date.getDate() == grid.locale.toString(model.date, "d") && clock.date.getMonth() == model.month) ? Colors.palette().pink : Colors.palette().text : Colors.palette().surface0
                                    font: grid.font

                                    required property var model
                                }
                            }
                        }
                    }

                    ScrollIndicator.horizontal: ScrollIndicator {}
                }
            }
        }
    }
}
