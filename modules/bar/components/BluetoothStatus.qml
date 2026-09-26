pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth

import "../../../ui"
import "../../../theme"

Text {
    id: root
    property ShellScreen screen

    text: {
        const adapter = Bluetooth.defaultAdapter;
        if (!adapter || !adapter.enabled)
            return "bt off";
        const devices = Bluetooth.devices.values || [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return "bt";
        }
        return "bt";
    }
    color: popup.show ? Colors.palette().pink : Colors.palette().text
    font.pixelSize: 11
    horizontalAlignment: Text.AlignHCenter

    BasePopup {
        id: popup
        parentItem: root
        screen: root.screen
        ColumnLayout {
            spacing: 8
            width: 280
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Bluetooth"; color: Colors.palette().text; Layout.fillWidth: true }
                Switch {
                    checked: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
                    onToggled: { if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = checked; }
                }
            }
            RowLayout {
                visible: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
                Layout.fillWidth: true
                Text { text: "Scan"; color: Colors.palette().subtext1; font.pixelSize: 12; Layout.fillWidth: true }
                Switch {
                    checked: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.discovering : false
                    onToggled: { if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.discovering = checked; }
                }
            }
            Repeater {
                model: Bluetooth.devices
                delegate: Rectangle {
                    id: dev
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 8
                    color: hover.hovered ? Colors.palette().surface0 : "transparent"
                    HoverHandler { id: hover }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text { text: dev.modelData.name || dev.modelData.deviceName || "Unknown"; color: Colors.palette().text; elide: Text.ElideRight; Layout.fillWidth: true; font.pixelSize: 12 }
                            Text {
                                text: dev.modelData.connected ? "Connected" : (dev.modelData.paired ? "Paired" : "Available")
                                color: dev.modelData.connected ? Colors.palette().green : Colors.palette().subtext0
                                font.pixelSize: 10
                            }
                        }
                    }
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            const d = dev.modelData;
                            if (d.connected) d.disconnect();
                            else if (d.paired) d.connect();
                            else { d.trusted = true; d.pair(); }
                        }
                    }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: dev.modelData.forget()
                    }
                }
            }
            Text {
                visible: !Bluetooth.defaultAdapter
                text: "No adapter"
                color: Colors.palette().subtext0
            }
        }
    }
}
