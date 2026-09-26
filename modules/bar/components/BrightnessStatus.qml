pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import "../../../ui"
import "../../../theme"

Text {
    id: root
    property ShellScreen screen
    property int percent: -1

    visible: percent >= 0
    text: percent >= 70 ? "\uDB80\uDCE0" : (percent >= 30 ? "\uDB80\uDCDF" : "\uDB80\uDCDE")
    color: popup.show ? Colors.palette().pink : Colors.palette().text
    font.pixelSize: 14
    horizontalAlignment: Text.AlignHCenter

    Process {
        id: readBright
        command: ["sh", "-c", "brightnessctl -m g >/dev/null 2>&1 && brightnessctl -m | awk -F, '{gsub(/%/,\"\",$4); print $4}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const n = parseInt(text.trim(), 10);
                if (!isNaN(n))
                    root.percent = n;
            }
        }
    }

    function bump(delta) {
        const sign = delta > 0 ? "+" : "-";
        Quickshell.execDetached(["brightnessctl", "set", Math.abs(delta) + "%" + sign]);
        readBright.running = false;
        readBright.running = true;
    }

    WheelHandler {
        onWheel: event => root.bump(event.angleDelta.y > 0 ? 5 : -5)
    }

    BasePopup {
        id: popup
        parentItem: root
        screen: root.screen

        ColumnLayout {
            width: 220
            spacing: 8
            Text {
                text: "Brightness  " + Math.max(root.percent, 0) + "%"
                color: Colors.palette().text
            }
            Slider {
                Layout.fillWidth: true
                from: 1
                to: 100
                value: Math.max(root.percent, 1)
                onMoved: {
                    Quickshell.execDetached(["brightnessctl", "set", Math.round(value) + "%"]);
                    root.percent = Math.round(value);
                }
            }
        }
    }
}
