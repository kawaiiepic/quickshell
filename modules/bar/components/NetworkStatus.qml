pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Networking

import "../../../ui"
import "../../../theme"

Text {
    id: root
    property ShellScreen screen
    property string pendingSsid: ""
    property bool needPsk: false

    text: {
        if (!Networking.wifiEnabled)
            return "wifi off";
        const devices = Networking.devices.values || [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return "net";
        }
        return "net?";
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
                Text { text: "Wi-Fi"; color: Colors.palette().text; Layout.fillWidth: true }
                Switch { checked: Networking.wifiEnabled; onToggled: Networking.wifiEnabled = checked }
            }
            Repeater {
                model: Networking.devices
                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 6
                    visible: modelData.type === DeviceType.Wifi || modelData.type === DeviceType.Wired
                    Text {
                        text: modelData.type === DeviceType.Wired ? ("Ethernet " + (modelData.connected ? "up" : "down")) : (modelData.name || "wlan")
                        color: Colors.palette().subtext0
                        font.pixelSize: 11
                    }
                    RowLayout {
                        visible: modelData.type === DeviceType.Wifi
                        Text { text: "Scan"; color: Colors.palette().subtext1; font.pixelSize: 12 }
                        Switch {
                            checked: modelData.scannerEnabled === true
                            onToggled: modelData.scannerEnabled = checked
                        }
                    }
                    Repeater {
                        model: modelData.networks
                        delegate: Rectangle {
                            id: netRow
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 36
                            radius: 8
                            color: hover.hovered ? Colors.palette().surface0 : "transparent"
                            HoverHandler { id: hover }
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                Text {
                                    text: netRow.modelData.connected ? "*" : "o"
                                    color: netRow.modelData.connected ? Colors.palette().green : Colors.palette().overlay0
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text { text: netRow.modelData.name || "Hidden"; color: Colors.palette().text; elide: Text.ElideRight; Layout.fillWidth: true; font.pixelSize: 12 }
                                    Text {
                                        text: netRow.modelData.connected ? "Connected" : (netRow.modelData.known ? "Saved" : "Available")
                                        color: netRow.modelData.connected ? Colors.palette().green : Colors.palette().subtext0
                                        font.pixelSize: 10
                                    }
                                }
                            }
                            TapHandler {
                                onTapped: {
                                    const net = netRow.modelData;
                                    if (net.connected) { net.disconnect(); return; }
                                    root.pendingSsid = net.name;
                                    root.needPsk = false;
                                    net.connect();
                                }
                            }
                            Connections {
                                target: netRow.modelData
                                function onConnectionFailed(reason) {
                                    root.pendingSsid = netRow.modelData.name;
                                    root.needPsk = true;
                                }
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                visible: root.needPsk
                Layout.fillWidth: true
                Text { text: "Password for " + root.pendingSsid; color: Colors.palette().text; font.pixelSize: 12 }
                TextField {
                    id: pskField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    color: Colors.palette().text
                    placeholderText: "PSK"
                    onAccepted: {
                        const devices = Networking.devices.values || [];
                        for (let i = 0; i < devices.length; i++) {
                            const nets = devices[i].networks.values || [];
                            for (let j = 0; j < nets.length; j++) {
                                if (nets[j].name === root.pendingSsid && nets[j].connectWithPsk) {
                                    nets[j].connectWithPsk(pskField.text);
                                    root.needPsk = false;
                                    pskField.text = "";
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
