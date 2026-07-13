pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import QtQuick.Controls
import Quickshell.Services.Pipewire
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking
import Quickshell.Bluetooth
import Qt5Compat.GraphicalEffects

import "../../../services"
import "../../../ui"
import "../../../theme"

Rectangle {
    id: root

    property ShellScreen screen

    width: parent.width
    height: childrenRect.height
    color: Colors.palette().surface1
    radius: 10

    Column {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Item {
            height: 5
            width: 1
        }

        ColumnLayout {
            id: layout
            spacing: 5
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: wifi

                text: ""
                Layout.alignment: Qt.AlignHCenter
                color: popup.show ? Colors.palette().pink : Colors.palette().text
                font.pixelSize: 14

                BasePopup {
                    id: popup

                    parentItem: wifi
                    screen: root.screen

                    Repeater {
                        model: Networking.devices

                        delegate: Item {
                            id: item
                            required property NetworkDevice modelData

                            height: childrenRect.height
                            width: childrenRect.width

                            Loader {
                                sourceComponent: item.modelData.type === DeviceType.Wired ? wiredDevice : wirelessDevice
                            }

                            Component {
                                id: wiredDevice

                                Row {
                                    Text {
                                        text: "ethernet"
                                        color: Colors.palette().text
                                    }

                                    Text {
                                        text: "hasLink: " + item.modelData.hasLink
                                        color: Colors.palette().text
                                    }

                                    Text {
                                        text: "linkSpeed: " + item.modelData.linkSpeed
                                        color: Colors.palette().text
                                    }
                                }
                            }

                            Component {
                                id: wirelessDevice

                                Column {
                                    spacing: 8

                                    // Text {
                                    //     text: item.modelData.connected ? item.modelData.networks.values[0].name : "Not Connected"
                                    //     color: Colors.palette().text
                                    // }

                                    Switch {
                                        checked: item.modelData.scannerEnabled
                                        onToggled: item.modelData.scannerEnabled = checked
                                    }

                                    Text {
                                        text: WifiDeviceMode.toString(item.modelData.mode)
                                        color: Colors.palette().text
                                    }

                                    ScrollView {
                                        height: 200
                                        width: 500
                                        clip: true
                                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                        ListView {
                                            model: item.modelData.networks
                                            spacing: 0

                                            delegate: ItemDelegate {
                                                required property Network modelData
                                                required property int index

                                                width: ListView.view.width
                                                height: 56
                                                padding: 0

                                                // ── Background + divider ───────────────────────────────────────
                                                background: Rectangle {
                                                    color: parent.hovered ? Qt.rgba(255, 255, 255, 0.05) : "transparent"
                                                    Behavior on color {
                                                        ColorAnimation {
                                                            duration: 120
                                                        }
                                                    }
                                                }

                                                // ── Content row ────────────────────────────────────────────────
                                                contentItem: RowLayout {
                                                    anchors {
                                                        fill: parent
                                                        leftMargin: 16
                                                        rightMargin: 16
                                                    }
                                                    spacing: 12

                                                    // Signal strength bars
                                                    Row {
                                                        spacing: 3
                                                        Layout.alignment: Qt.AlignVCenter

                                                        Repeater {
                                                            model: 4
                                                            Rectangle {

                                                                required property int index

                                                                width: 4
                                                                height: 4 * index + 1
                                                                anchors.bottom: parent?.bottom
                                                                radius: 2

                                                                color: (modelData.signalStrength / index) > 0.25 ? "blue" : "grey"

                                                                Behavior on color {
                                                                    ColorAnimation {
                                                                        duration: 180
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                    // Network name + status label
                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 2

                                                        Text {
                                                            text: modelData.name
                                                            font.pixelSize: 14
                                                            font.weight: modelData.connected ? Font.Medium : Font.Normal
                                                            color: Colors.palette().text
                                                            elide: Text.ElideRight
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: modelData.stateChanging ? ConnectionState.toString(modelData.state) + "…" : ConnectionState.toString(modelData.state)
                                                            font.pixelSize: 11
                                                            color: {
                                                                if (modelData.stateChanging)
                                                                    return "#fbbf24";  // amber — in progress
                                                                if (modelData.connected)
                                                                    return "#4ade80";  // green  — connected
                                                                return Qt.rgba(Colors.palette().text.r, Colors.palette().text.g, Colors.palette().text.b, 0.45);
                                                            }
                                                            Behavior on color {
                                                                ColorAnimation {
                                                                    duration: 180
                                                                }
                                                            }
                                                        }
                                                    }

                                                    // "Connected" pill badge
                                                    Rectangle {
                                                        visible: modelData.connected
                                                        width: badge.implicitWidth + 16
                                                        height: 20
                                                        radius: 10
                                                        color: Qt.rgba(74, 222, 128, 0.12)
                                                        border {
                                                            color: Qt.rgba(74, 222, 128, 0.35)
                                                            width: 1
                                                        }

                                                        Text {
                                                            id: badge
                                                            anchors.centerIn: parent
                                                            text: "Connected"
                                                            font.pixelSize: 10
                                                            font.weight: Font.Medium
                                                            color: "#4ade80"
                                                        }
                                                    }

                                                    // Saved-network star (only when not connected)
                                                    Text {
                                                        visible: modelData.known && !modelData.connected
                                                        text: "★"
                                                        font.pixelSize: 13
                                                        color: Qt.rgba(Colors.palette().text.r, Colors.palette().text.g, Colors.palette().text.b, 0.3)
                                                        Layout.alignment: Qt.AlignVCenter
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                id: bluetooth
                text: "󰂯"
                Layout.alignment: Qt.AlignHCenter
                color: popup2.show ? Colors.palette().pink : Colors.palette().text
                font.pixelSize: 14

                BasePopup {
                    id: popup2

                    parentItem: bluetooth
                    screen: root.screen

                    Column {

                        Switch {
                            checked: Bluetooth.defaultAdapter.discovering
                            onToggled: Bluetooth.defaultAdapter.discovering = checked
                        }

                        Switch {
                            checked: Bluetooth.defaultAdapter.pairable
                            onToggled: Bluetooth.defaultAdapter.pairable = checked
                        }

                        ScrollView {
                            height: 200
                            width: 500
                            clip: true

                            ListView {
                                model: Bluetooth.devices
                                spacing: 0

                                delegate: Item {

                                    required property var modelData

                                    height: 25
                                    width: childrenRect.width

                                    MouseArea {
                                        id: mouse
                                        anchors.fill: parent

                                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                                        onClicked: mouse => {
                                            if (mouse.button & Qt.LeftButton) {
                                                if (modelData.paired) {
                                                    if (modelData.connected) {
                                                        modelData.disconnect();
                                                    } else {
                                                        modelData.trusted = true;
                                                        modelData.connect();
                                                    }
                                                } else {
                                                    modelData.pair();
                                                    modelData.trusted = true;
                                                }
                                            } else {
                                                modelData.forget();
                                            }
                                        }
                                    }

                                    HoverHandler {
                                        id: hover
                                    }

                                    Row {
                                        spacing: 8

                                        Text {
                                            visible: modelData.paired
                                            text: {
                                                if (modelData.icon == "audio-headset")
                                                    "󰋎";
                                                else if (modelData.icon == "audio-headphones")
                                                    "󰋋";
                                                else if (modelData.icon == "phone")
                                                    "";
                                                else if (modelData.icon == "input-gaming")
                                                    "󰊴";
                                                else
                                                    modelData.icon;
                                            }
                                            color: hover.hovered ? Colors.palette().maroon : modelData.connected ? Colors.palette().pink : Colors.palette().text
                                        }

                                        Text {
                                            text: modelData.name
                                            color: hover.hovered ? Colors.palette().maroon : modelData.connected ? Colors.palette().pink : Colors.palette().text
                                        }

                                        Text {
                                            visible: modelData.paired
                                            text: ""
                                            color: hover.hovered ? Colors.palette().maroon : modelData.connected ? Colors.palette().pink : Colors.palette().text
                                            font.pixelSize: 10
                                        }

                                        BusyIndicator {
                                            visible: modelData.state == 3
                                            implicitWidth: 25
                                            implicitHeight: 25

                                            y: -5

                                            layer.enabled: true
                                            layer.effect: ColorOverlay {
                                                antialiasing: true
                                                color: "#D8D8D8" //change it to your prefer color
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                id: volume
                text: "󰕾"
                Layout.alignment: Qt.AlignHCenter
                color: basePopup.show ? Colors.palette().pink : Colors.palette().text
                font.pixelSize: 14

                BasePopup {
                    id: basePopup
                    parentItem: volume
                    screen: root.screen

                    property int selectedIndex: 0

                    StackView {
                        id: stack
                        implicitWidth: currentItem ? currentItem.implicitWidth : 0
                        implicitHeight: currentItem ? currentItem.implicitHeight : 0
                        initialItem: base
                    }

                    Component {
                        id: base

                        ColumnLayout {
                            spacing: 8

                            Layout.fillHeight: true

                            Text {
                                text: "Audio Profile"
                                color: Colors.palette().text
                            }

                            Text {
                                text: "Select Audio Output"
                                color: Colors.palette().text
                            }

                            PopupButton {
                                menu: true
                                text: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.description ? Pipewire.defaultAudioSink.description : "Select Output"

                                clicked: function () {
                                    stack.push(audioInDepth);
                                    basePopup.hoverUpdate(1);
                                }
                            }
                        }
                    }

                    Component {
                        id: audioInDepth

                        ColumnLayout {
                            spacing: 10

                            ButtonGroup {
                                id: buttonGroup
                            }

                            Repeater {
                                id: nodesRepeater
                                model: Pipewire.nodes

                                delegate: Item {
                                    id: node

                                    required property PwNode modelData
                                    property bool isAudio: !modelData.isStream && modelData.isSink

                                    implicitHeight: 20
                                    implicitWidth: 200

                                    visible: isAudio

                                    RadioButton {
                                        id: control
                                        ButtonGroup.group: buttonGroup

                                        checked: (Pipewire.defaultAudioSink.name === node.modelData.name) && node.isAudio

                                        onHoveredChanged: {
                                            basePopup.hoverUpdate(hovered ? 1 : -1);
                                        }

                                        onClicked: {
                                            Pipewire.preferredDefaultAudioSink = node.modelData;
                                        }

                                        contentItem: Text {
                                            rightPadding: control.indicator.width + control.spacing
                                            text: node.modelData.nickname
                                            opacity: enabled ? 1.0 : 0.3
                                            color: control.down ? Colors.palette().pink : Colors.palette().text
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        indicator: Rectangle {
                                            implicitWidth: 12
                                            implicitHeight: 12
                                            x: control.width - width - control.rightPadding
                                            y: parent.height / 2 - height / 2
                                            radius: 13
                                            color: "transparent"
                                            border.color: control.down ? Colors.palette().pink : Colors.palette().pink

                                            Rectangle {
                                                width: 11
                                                height: 11
                                                radius: 13
                                                x: 0.5
                                                y: 0.5
                                                color: control.down ? Colors.palette().pink : Colors.palette().pink
                                                visible: control.checked
                                            }
                                        }
                                    }
                                }
                            }

                            BackButton {
                                clicked: function () {
                                    stack.popCurrentItem();
                                }
                            }
                        }
                    }
                }
            }

            Text {
                id: notification
                text: NotificationManager.urgent ? "󰵙" : NotificationManager.historyNotifications.count > 0 ? "󱅫" : "󰂚"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                color: notificationPopup.show ? Colors.palette().pink : Colors.palette().text

                BasePopup {
                    id: notificationPopup
                    parentItem: notification
                    screen: root.screen

                    Text {
                        text: `Number of notifications ${NotificationManager.historyNotifications.count}`
                        color: Colors.palette().text
                    }
                }
            }

            Text {
                id: power_profile

                text: ""
                color: powerPopup.show ? Colors.palette().pink : Colors.palette().text
                font.pixelSize: 14

                Layout.alignment: Qt.AlignHCenter

                BasePopup {
                    id: powerPopup
                    parentItem: power_profile
                    screen: root.screen

                    Text {
                        text: PowerProfiles.hasPerformanceProfile
                        color: Colors.palette().text
                    }

                    Text {
                        text: PowerProfile.toString(PowerProfiles.profile)
                        color: Colors.palette().text
                    }

                    Text {
                        text: PowerProfiles.holds.length
                        color: Colors.palette().text
                    }
                }
            }

            Row {
                id: battery

                property UPowerDevice power: UPower.displayDevice

                function updateP() {
                    console.log(`Percentage changed ${power.percentage}`);
                    switch (power.percentage * 100) {
                    case 5:
                        {
                            NotificationManager.sendNotification("battery", "Battery Status", "Shutting off soon 5%");
                            break;
                        }
                    case 20:
                        {
                            NotificationManager.sendNotification("battery", "Battery Status", "Low Battery 20%");
                            break;
                        }
                    case 80:
                        {
                            NotificationManager.sendNotification("battery", "Battery Status", "Almost Full 80%");
                            break;
                        }
                    case 100:
                        {
                            NotificationManager.sendNotification("battery", "Battery Status", "Fully charged 100%");
                            break;
                        }
                    }
                }

                Component.onCompleted: {
                    power.onPercentageChanged.connect(updateP);
                }

                visible: power.isLaptopBattery ?? false
                Layout.alignment: Qt.AlignHCenter

                Item {
                    width: 18
                    height: 18

                    IconImage {
                        anchors.fill: parent
                        source: Quickshell.iconPath(battery.power.iconName, "unknown")
                        mipmap: true
                        rotation: 90
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Math.round(battery.power.percentage * 100)
                        font.pixelSize: 11
                        color: "black"
                    }
                }

                BasePopup {
                    id: batteryPopup

                    function formatSeconds(secs) {
                        var hours = Math.floor(secs / 3600); // 1 hour = 3600 seconds
                        var minutes = Math.floor((secs % 3600) / 60);
                        var seconds = secs % 60;
                        // Pad with leading zeros if needed
                        var hoursStr = hours < 10 ? "0" + hours : hours;
                        var minutesStr = minutes < 10 ? "0" + minutes : minutes;
                        var secondsStr = seconds < 10 ? "0" + seconds : seconds;
                        return hoursStr + ":" + minutesStr + ":" + secondsStr;
                    }

                    parentItem: battery
                    screen: root.screen

                    Text {
                        text: "Battery Percentage " + battery.power.percentage * 100 + "%"
                        color: Colors.palette().text
                    }

                    Text {
                        text: "Time till dead " + batteryPopup.formatSeconds(battery.power.timeToEmpty)
                        color: Colors.palette().text
                    }

                    Text {
                        text: "Time till charged " + batteryPopup.formatSeconds(battery.power.timeToFull)
                        color: Colors.palette().text
                    }
                }
            }
        }

        Item {
            height: 5
            width: 1
        }
    }
}
