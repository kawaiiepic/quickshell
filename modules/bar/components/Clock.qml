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
    property string currentTab: "calendar"

    spacing: 2

    // ============================================================
    // CLOCK
    // ============================================================

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // ============================================================
    // TIMER STATE (timestamp based, so it never drifts)
    // ============================================================

    property real timerRemainingMs: 0
    property real timerEndMs: 0
    property bool timerRunning: false
    property bool timerFinished: false
    readonly property int timerRemaining: Math.ceil(timerRemainingMs / 1000)

    Timer {
        id: countdownTimer

        interval: 200
        repeat: true
        running: root.timerRunning

        onTriggered: {
            const left = root.timerEndMs - Date.now()

            if (left <= 0) {
                root.timerRemainingMs = 0
                root.timerRunning = false
                root.timerFinished = true
                Quickshell.execDetached([
                    "notify-send", "Timer finished", "Your timer is done."
                ])
            } else {
                root.timerRemainingMs = left
            }
        }
    }

    function toggleTimer() {
        if (timerRunning) {
            timerRemainingMs = Math.max(0, timerEndMs - Date.now())
            timerRunning = false
            return
        }

        if (timerRemainingMs <= 0)
            return

        timerFinished = false
        timerEndMs = Date.now() + timerRemainingMs
        timerRunning = true
    }

    function addTimer(seconds) {
        timerFinished = false

        if (timerRunning) {
            timerEndMs += seconds * 1000
            timerRemainingMs = Math.max(0, timerEndMs - Date.now())
        } else {
            timerRemainingMs += seconds * 1000
        }
    }

    function resetTimer() {
        timerRunning = false
        timerFinished = false
        timerRemainingMs = 0
        timerEndMs = 0
    }

    // ============================================================
    // STOPWATCH STATE
    // ============================================================

    property real stopwatchBaseMs: 0
    property real stopwatchStartMs: 0
    property real stopwatchElapsedMs: 0
    property bool stopwatchRunning: false
    readonly property int stopwatchElapsed: Math.floor(stopwatchElapsedMs / 1000)

    Timer {
        id: stopwatchTimer

        interval: 200
        repeat: true
        running: root.stopwatchRunning

        onTriggered: {
            root.stopwatchElapsedMs =
                root.stopwatchBaseMs + (Date.now() - root.stopwatchStartMs)
        }
    }

    function toggleStopwatch() {
        if (stopwatchRunning) {
            stopwatchElapsedMs =
                stopwatchBaseMs + (Date.now() - stopwatchStartMs)
            stopwatchBaseMs = stopwatchElapsedMs
            stopwatchRunning = false
        } else {
            stopwatchStartMs = Date.now()
            stopwatchRunning = true
        }
    }

    function resetStopwatch() {
        stopwatchRunning = false
        stopwatchBaseMs = 0
        stopwatchElapsedMs = 0
    }

    // ============================================================
    // HELPERS
    // ============================================================

    function formatTimer(seconds) {
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        const secs = seconds % 60

        if (hours > 0) {
            return (
                String(hours).padStart(2, "0") + ":" +
                String(minutes).padStart(2, "0") + ":" +
                String(secs).padStart(2, "0")
            )
        }

        return (
            String(minutes).padStart(2, "0") + ":" +
            String(secs).padStart(2, "0")
        )
    }

    // ============================================================
    // BAR DISPLAY
    // ============================================================

    Text {
        visible: !root.vertical

        text: {
            if (root.timerFinished)
                return "󱎫 Done"

            if (root.timerRunning)
                return "󱎫 " + root.formatTimer(root.timerRemaining)

            if (root.stopwatchRunning)
                return "󰔛 " + root.formatTimer(root.stopwatchElapsed)

            return "\uf017 " + Qt.formatDateTime(clock.date, "hh:mm")
        }

        color: (popup.show || root.timerFinished)
            ? Colors.palette().pink
            : Colors.palette().text

        font.family: "Share Tech Mono"
        font.pixelSize: 12
    }

    Text {
        visible: root.vertical

        text: root.timerFinished || root.timerRunning
            ? "󱎫"
            : root.stopwatchRunning
                ? "󰔛"
                : "\uf017"

        Layout.alignment: Qt.AlignHCenter

        color: (popup.show || root.timerFinished)
            ? Colors.palette().pink
            : Colors.palette().text

        font.pixelSize: 14
    }

    Text {
        visible: root.vertical

        text: {
            if (root.timerFinished)
                return "00:00"

            if (root.timerRunning)
                return root.formatTimer(root.timerRemaining)

            if (root.stopwatchRunning)
                return root.formatTimer(root.stopwatchElapsed)

            return Qt.formatDateTime(clock.date, "hh\nmm")
        }

        Layout.alignment: Qt.AlignHCenter

        color: (popup.show || root.timerFinished)
            ? Colors.palette().pink
            : Colors.palette().text

        font.family: "Share Tech Mono"
        font.pixelSize: 11

        horizontalAlignment: Text.AlignHCenter
    }

    // ============================================================
    // POPUP
    // ============================================================

    BasePopup {
        id: popup

        parentItem: root
        screen: root.screen

        ColumnLayout {
            id: popupContent

            spacing: 12

            // ====================================================
            // TABS
            // ====================================================

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: [
                        {
                            name: "Calendar",
                            icon: "\uf073",
                            value: "calendar"
                        },
                        {
                            name: "Timer",
                            icon: "󱎫",
                            value: "timer"
                        },
                        {
                            name: "Stopwatch",
                            icon: "󰔛",
                            value: "stopwatch"
                        }
                    ]

                    delegate: Rectangle {
                        id: tab

                        required property var modelData

                        readonly property bool selected:
                            root.currentTab === tab.modelData.value

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34

                        radius: 6

                        color: tab.selected
                            ? Colors.palette().surface0
                            : "transparent"

                        border.width: tab.selected ? 1 : 0
                        border.color: Colors.palette().pink

                        Text {
                            anchors.centerIn: parent

                            text: tab.modelData.icon + " " + tab.modelData.name

                            color: tab.selected
                                ? Colors.palette().pink
                                : Colors.palette().subtext0

                            font.family: "Share Tech Mono"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.currentTab = tab.modelData.value
                        }
                    }
                }
            }

            // ====================================================
            // CONTENT
            // ====================================================

            Loader {
                id: tabLoader

                Layout.preferredWidth: 420
                Layout.preferredHeight: 390

                sourceComponent: {
                    if (root.currentTab === "timer")
                        return timerPage

                    if (root.currentTab === "stopwatch")
                        return stopwatchPage

                    return calendarPage
                }
            }
        }
    }

    // ============================================================
    // CALENDAR PAGE
    // ============================================================

    Component {
        id: calendarPage

        Rectangle {
            width: 420
            height: 390

            color: "transparent"

            Column {
                anchors.fill: parent

                spacing: 10

                Rectangle {
                    width: parent.width
                    height: 320

                    color: Colors.palette().base

                    radius: 8

                    border.width: 1
                    border.color: Colors.palette().crust

                    ListView {
                        id: monthList

                        anchors.fill: parent
                        anchors.margins: 18

                        orientation: ListView.Horizontal

                        snapMode: ListView.SnapOneItem
                        highlightRangeMode: ListView.StrictlyEnforceRange

                        boundsBehavior: Flickable.StopAtBounds

                        clip: true

                        model: CalendarModel {
                            from: new Date(clock.date.getFullYear(), 0, 1)
                            to: new Date(clock.date.getFullYear(), 11, 31)
                        }

                        Component.onCompleted:
                            monthList.currentIndex = clock.date.getMonth()

                        delegate: Item {
                            id: monthItem

                            required property int month
                            required property int year

                            width: monthList.width
                            height: monthList.height

                            Column {
                                anchors.fill: parent

                                spacing: 10

                                Text {
                                    width: parent.width
                                    height: 24

                                    text: Qt.locale("en_US").monthName(
                                        monthItem.month,
                                        Locale.LongFormat
                                    )

                                    color: monthItem.month ===
                                            clock.date.getMonth()
                                        ? Colors.palette().pink
                                        : Colors.palette().text

                                    font.family: "Share Tech Mono"
                                    font.pixelSize: 16
                                    font.bold: true

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Row {
                                    id: weekdayRow

                                    width: parent.width
                                    height: 22

                                    Repeater {
                                        model: [
                                            "SUN", "MON", "TUE", "WED",
                                            "THU", "FRI", "SAT"
                                        ]

                                        delegate: Text {
                                            required property string modelData

                                            width: weekdayRow.width / 7
                                            height: weekdayRow.height

                                            text: modelData

                                            color: Colors.palette().subtext0

                                            font.family: "Share Tech Mono"
                                            font.pixelSize: 9
                                            font.bold: true

                                            horizontalAlignment:
                                                Text.AlignHCenter
                                            verticalAlignment:
                                                Text.AlignVCenter
                                        }
                                    }
                                }

                                MonthGrid {
                                    id: grid

                                    width: parent.width
                                    height: 210

                                    month: monthItem.month
                                    year: monthItem.year

                                    locale: Qt.locale("en_US")

                                    spacing: 4

                                    // MonthGrid sizes its own cells,
                                    // so the delegate must not set width/height.
                                    delegate: Item {
                                        id: cell

                                        required property var model

                                        readonly property bool isToday:
                                            cell.model.day ===
                                                clock.date.getDate() &&
                                            cell.model.month ===
                                                clock.date.getMonth() &&
                                            cell.model.year ===
                                                clock.date.getFullYear()

                                        Rectangle {
                                            visible: cell.isToday

                                            anchors.centerIn: parent

                                            width: 30
                                            height: 30

                                            radius: 6

                                            color: "transparent"

                                            border.width: 1
                                            border.color: Colors.palette().pink
                                        }

                                        Text {
                                            anchors.centerIn: parent

                                            text: cell.model.day

                                            color: cell.model.month !==
                                                    grid.month
                                                ? Colors.palette().surface1
                                                : cell.isToday
                                                    ? Colors.palette().pink
                                                    : Colors.palette().text

                                            font.family: "Share Tech Mono"
                                            font.pixelSize: 13
                                            font.bold: cell.isToday
                                        }
                                    }
                                }
                            }
                        }

                        ScrollIndicator.horizontal: ScrollIndicator {
                            active: true
                        }
                    }
                }

                Text {
                    width: parent.width

                    text: Qt.formatDate(clock.date, "dddd, MMMM d, yyyy")

                    color: Colors.palette().subtext0

                    font.family: "Share Tech Mono"
                    font.pixelSize: 10

                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    // ============================================================
    // TIMER PAGE
    // ============================================================

    Component {
        id: timerPage

        Rectangle {
            width: 420
            height: 390

            color: Colors.palette().base
            radius: 8

            border.width: 1
            border.color: Colors.palette().crust

            Column {
                anchors.fill: parent
                anchors.margins: 22

                spacing: 18

                Text {
                    width: parent.width

                    text: root.timerFinished
                        ? "Timer finished!"
                        : root.timerRunning
                            ? "Timer"
                            : "Set Timer"

                    color: root.timerFinished
                        ? Colors.palette().pink
                        : Colors.palette().text

                    font.family: "Share Tech Mono"
                    font.pixelSize: 16
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    width: parent.width

                    text: root.formatTimer(root.timerRemaining)

                    color: root.timerFinished
                        ? Colors.palette().pink
                        : Colors.palette().text

                    font.family: "Share Tech Mono"
                    font.pixelSize: 48
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    id: presetRow

                    width: parent.width
                    height: 38

                    spacing: 6

                    Repeater {
                        model: [
                            { label: "+10s", seconds: 10 },
                            { label: "+30s", seconds: 30 },
                            { label: "+1m", seconds: 60 },
                            { label: "+5m", seconds: 300 },
                            { label: "+10m", seconds: 600 }
                        ]

                        delegate: Rectangle {
                            id: preset

                            required property var modelData

                            width: (presetRow.width - 24) / 5
                            height: 38

                            radius: 6

                            color: Colors.palette().surface0

                            Text {
                                anchors.centerIn: parent

                                text: preset.modelData.label

                                color: Colors.palette().text

                                font.family: "Share Tech Mono"
                                font.pixelSize: 10
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor

                                onClicked: root.addTimer(preset.modelData.seconds)
                            }
                        }
                    }
                }

                Row {
                    id: timerButtons

                    width: parent.width
                    height: 42

                    spacing: 8

                    Rectangle {
                        width: (timerButtons.width - 8) / 2
                        height: 42

                        radius: 6

                        color: Colors.palette().pink
                        opacity: (root.timerRunning || root.timerRemainingMs > 0)
                            ? 1.0
                            : 0.4

                        Text {
                            anchors.centerIn: parent

                            text: root.timerRunning ? "Pause" : "Start"

                            color: Colors.palette().base

                            font.family: "Share Tech Mono"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.toggleTimer()
                        }
                    }

                    Rectangle {
                        width: (timerButtons.width - 8) / 2
                        height: 42

                        radius: 6

                        color: Colors.palette().surface0

                        Text {
                            anchors.centerIn: parent

                            text: "Reset"

                            color: Colors.palette().text

                            font.family: "Share Tech Mono"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.resetTimer()
                        }
                    }
                }

                Text {
                    width: parent.width

                    text: "Tap a preset to add time"

                    color: Colors.palette().subtext0

                    font.family: "Share Tech Mono"
                    font.pixelSize: 10

                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    // ============================================================
    // STOPWATCH PAGE
    // ============================================================

    Component {
        id: stopwatchPage

        Rectangle {
            width: 420
            height: 390

            color: Colors.palette().base
            radius: 8

            border.width: 1
            border.color: Colors.palette().crust

            Column {
                anchors.fill: parent
                anchors.margins: 22

                spacing: 22

                Text {
                    width: parent.width

                    text: "Stopwatch"

                    color: Colors.palette().text

                    font.family: "Share Tech Mono"
                    font.pixelSize: 16
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    width: parent.width

                    text: root.formatTimer(root.stopwatchElapsed)

                    color: Colors.palette().text

                    font.family: "Share Tech Mono"
                    font.pixelSize: 48
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    id: swButtons

                    width: parent.width
                    height: 44

                    spacing: 8

                    Rectangle {
                        width: (swButtons.width - 8) / 2
                        height: 44

                        radius: 6

                        color: Colors.palette().pink

                        Text {
                            anchors.centerIn: parent

                            text: root.stopwatchRunning ? "Pause" : "Start"

                            color: Colors.palette().base

                            font.family: "Share Tech Mono"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.toggleStopwatch()
                        }
                    }

                    Rectangle {
                        width: (swButtons.width - 8) / 2
                        height: 44

                        radius: 6

                        color: Colors.palette().surface0

                        Text {
                            anchors.centerIn: parent

                            text: "Reset"

                            color: Colors.palette().text

                            font.family: "Share Tech Mono"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: root.resetStopwatch()
                        }
                    }
                }

                Text {
                    width: parent.width

                    text: root.stopwatchRunning
                        ? "Running"
                        : root.stopwatchElapsed > 0
                            ? "Paused"
                            : "Ready"

                    color: Colors.palette().subtext0

                    font.family: "Share Tech Mono"
                    font.pixelSize: 10

                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
