pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import "../../../ui"
import "../../../theme"

Text {
    id: root
    property ShellScreen screen

    text: {
        const p = PowerProfiles.profile;
        if (p === PowerProfile.PowerSaver)
            return "Saver";
        if (p === PowerProfile.Performance)
            return "Perf";
        return "Bal";
    }

    color: popup.show ? Colors.palette().pink : Colors.palette().text
    font.pixelSize: 11
    horizontalAlignment: Text.AlignHCenter

    BasePopup {
        id: popup
        parentItem: root
        screen: root.screen

        ColumnLayout {
            spacing: 6
            width: 200
            Text { text: "Power profile"; color: Colors.palette().text }
            PopupButton { text: "Power saver"; clicked: () => PowerProfiles.profile = PowerProfile.PowerSaver }
            PopupButton { text: "Balanced"; clicked: () => PowerProfiles.profile = PowerProfile.Balanced }
            PopupButton {
                visible: PowerProfiles.hasPerformanceProfile
                text: "Performance"
                clicked: () => PowerProfiles.profile = PowerProfile.Performance
            }
        }
    }
}
