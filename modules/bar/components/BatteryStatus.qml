pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import "../../../ui"
import "../../../theme"

Column {
    id: root
    property ShellScreen screen
    property UPowerDevice power: UPower.displayDevice

    visible: !!(power && power.isLaptopBattery)
    spacing: 2

    readonly property int pct: power ? Math.round(power.percentage * 100) : 0
    readonly property bool charging: !!(power && power.timeToFull > 0)

    function formatSeconds(secs) {
        if (!secs || secs <= 0)
            return "-";
        const hours = Math.floor(secs / 3600);
        const minutes = Math.floor((secs % 3600) / 60);
        return hours + "h " + minutes + "m";
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.charging ? "chg" : "bat"
        color: popup.show ? Colors.palette().pink : (root.pct < 15 && !root.charging ? Colors.palette().red : Colors.palette().text)
        font.pixelSize: 11
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.pct + "%"
        color: Colors.palette().text
        font.pixelSize: 9
    }

    BasePopup {
        id: popup
        parentItem: root
        screen: root.screen
        ColumnLayout {
            spacing: 4
            width: 220
            Text { text: root.charging ? "Charging" : "On battery"; color: Colors.palette().text }
            Text { text: root.pct + "%"; color: Colors.palette().text }
            Text {
                visible: !root.charging
                text: "Empty in " + root.formatSeconds(root.power.timeToEmpty)
                color: Colors.palette().subtext0
                font.pixelSize: 12
            }
            Text {
                visible: root.charging
                text: "Full in " + root.formatSeconds(root.power.timeToFull)
                color: Colors.palette().subtext0
                font.pixelSize: 12
            }
        }
    }
}
