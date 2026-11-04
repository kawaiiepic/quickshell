pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
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
    height: layout.implicitHeight + 10
    color: Colors.palette().surface1
    radius: 10

    // ============================================================
    // HELPERS
    // ============================================================

    function dim(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    function fmtSeconds(secs) {
        if (!secs || secs <= 0)
            return "--"

        const h = Math.floor(secs / 3600)
        const m = Math.floor((secs % 3600) / 60)

        return h > 0 ? h + "h " + m + "m" : m + "m"
    }

    function volumeIcon(vol, muted) {
        if (muted || vol <= 0)
            return "󰖁"
        if (vol < 0.34)
            return "󰕿"
        if (vol < 0.67)
            return "󰖀"
        return "󰕾"
    }

    function btIcon(name) {
        switch (name) {
        case "audio-headset":
            return "󰋎"
        case "audio-headphones":
            return "󰋋"
        case "audio-card":
            return "󰓃"
        case "phone":
            return "\uf10b"
        case "input-gaming":
            return "󰊴"
        case "input-keyboard":
            return "󰌌"
        case "input-mouse":
            return "󰍽"
        default:
            return "󰂯"
        }
    }

    function profileIcon(p) {
        switch (p) {
        case PowerProfile.PowerSaver:
            return "󰌪"
        case PowerProfile.Performance:
            return "󱐋"
        default:
            return "󰗑"
        }
    }

    // Default audio devices (bound so volume/mute are readable and writable)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    // ============================================================
    // SMALL REUSABLE COMPONENTS
    // ============================================================

    component PopupText: Text {
        color: Colors.palette().text
        font.pixelSize: 12
    }

    component SwitchRow: RowLayout {
        id: sr

        property string text
        property bool checked: false

        signal toggled(bool value)

        spacing: 8

        Text {
            text: sr.text
            color: Colors.palette().text
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Switch {
            checked: sr.checked
            onToggled: sr.toggled(checked)
        }
    }

    component VolumeRow: RowLayout {
        id: vr

        required property var node
        property string icon: ""

        readonly property var audio: vr.node ? vr.node.audio : null
        readonly property real vol: vr.audio ? vr.audio.volume : 0
        readonly property bool muted: vr.audio ? vr.audio.muted : false

        spacing: 8

        Text {
            text: vr.icon
            color: vr.muted ? Colors.palette().subtext0 : Colors.palette().text
            font.pixelSize: 16
            Layout.preferredWidth: 20
            horizontalAlignment: Text.AlignHCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (vr.audio)
                        vr.audio.muted = !vr.audio.muted
                }
            }
        }

        Slider {
            Layout.fillWidth: true
            from: 0
            to: 1
            enabled: vr.audio !== null
            value: vr.vol

            onMoved: {
                if (vr.audio)
                    vr.audio.volume = value
            }
        }

        Text {
            text: Math.round(vr.vol * 100) + "%"
            color: Colors.palette().subtext0
            font.pixelSize: 11
            Layout.preferredWidth: 34
            horizontalAlignment: Text.AlignRight
        }
    }

    // ============================================================
    // ICON COLUMN
    // ============================================================

    ColumnLayout {
        id: layout

        y: 5
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        // ========================================================
        // WI-FI
        // ========================================================

        Text {
            id: wifi

            text: Networking.wifiEnabled ? "󰖩" : "󰖪"
            Layout.alignment: Qt.AlignHCenter
            color: popup.show ? Colors.palette().pink : Colors.palette().text
            font.pixelSize: 14

            BasePopup {
                id: popup

                parentItem: wifi
                screen: root.screen

                ColumnLayout {
                    spacing: 8
                    implicitWidth: 340

                    SwitchRow {
                        Layout.fillWidth: true
                        text: "Wi-Fi"
                        checked: Networking.wifiEnabled
                        onToggled: value => Networking.wifiEnabled = value
                    }

                    Repeater {
                        model: Networking.devices

                        delegate: Item {
                            id: item

                            required property NetworkDevice modelData

                            Layout.fillWidth: true
                            implicitHeight: loader.implicitHeight
                            implicitWidth: loader.implicitWidth

                            Loader {
                                id: loader
                                width: parent.width
                                sourceComponent: item.modelData.type === DeviceType.Wired ? wiredDevice : wirelessDevice
                            }

                            // ---------- Ethernet ----------
                            Component {
                                id: wiredDevice

                                RowLayout {
                                    spacing: 8

                                    Text {
                                        text: "󰈀"
                                        font.pixelSize: 16
                                        color: item.modelData.hasLink ? Colors.palette().pink : Colors.palette().subtext0
                                    }

                                    PopupText {
                                        text: "Ethernet"
                                        Layout.fillWidth: true
                                    }

                                    PopupText {
                                        color: Colors.palette().subtext0
                                        text: item.modelData.hasLink ? (item.modelData.linkSpeed > 0 ? item.modelData.linkSpeed + " Mbit/s" : "Connected") : "No cable"
                                    }
                                }
                            }

                            // ---------- Wi-Fi ----------
                            Component {
                                id: wirelessDevice

                                ColumnLayout {
                                    spacing: 8

                                    SwitchRow {
                                        Layout.fillWidth: true
                                        text: "Scan for networks"
                                        checked: item.modelData.scannerEnabled
                                        onToggled: value => item.modelData.scannerEnabled = value
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 220

                                        ScrollView {
                                            anchors.fill: parent
                                            clip: true
                                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                            ListView {
                                                id: netList

                                                model: item.modelData.networks
                                                spacing: 0

                                                delegate: ItemDelegate {
                                                    id: net

                                                    required property Network modelData
                                                    required property int index

                                                    width: ListView.view.width
                                                    height: 52

                                                    leftPadding: 12
                                                    rightPadding: 12
                                                    topPadding: 0
                                                    bottomPadding: 0

                                                    // left click: connect / disconnect
                                                    onClicked: {
                                                        if (net.modelData.connected)
                                                            net.modelData.disconnect()
                                                        else
                                                            net.modelData.connect()
                                                    }

                                                    // right click: forget saved network
                                                    TapHandler {
                                                        acceptedButtons: Qt.RightButton
                                                        onTapped: {
                                                            if (net.modelData.known)
                                                                net.modelData.forget()
                                                        }
                                                    }

                                                    background: Rectangle {
                                                        radius: 6
                                                        color: net.hovered ? root.dim(Colors.palette().text, 0.06) : "transparent"

                                                        Behavior on color {
                                                            ColorAnimation {
                                                                duration: 120
                                                            }
                                                        }
                                                    }

                                                    contentItem: RowLayout {
                                                        spacing: 12

                                                        // Signal bars
                                                        Row {
                                                            spacing: 2
                                                            Layout.alignment: Qt.AlignVCenter

                                                            Repeater {
                                                                model: 4

                                                                delegate: Item {
                                                                    id: bar

                                                                    required property int index

                                                                    width: 4
                                                                    height: 16

                                                                    Rectangle {
                                                                        anchors.bottom: parent.bottom
                                                                        width: parent.width
                                                                        height: 4 + bar.index * 4
                                                                        radius: 1

                                                                        color: net.modelData.signalStrength > bar.index * 0.25 + 0.05 ? Colors.palette().pink : root.dim(Colors.palette().text, 0.25)

                                                                        Behavior on color {
                                                                            ColorAnimation {
                                                                                duration: 180
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        // Name + status
                                                        ColumnLayout {
                                                            Layout.fillWidth: true
                                                            spacing: 2

                                                            Text {
                                                                text: net.modelData.name
                                                                font.pixelSize: 14
                                                                font.weight: net.modelData.connected ? Font.Medium : Font.Normal
                                                                color: Colors.palette().text
                                                                elide: Text.ElideRight
                                                                Layout.fillWidth: true
                                                            }

                                                            Text {
                                                                text: net.modelData.stateChanging ? ConnectionState.toString(net.modelData.state) + "…" : ConnectionState.toString(net.modelData.state)
                                                                font.pixelSize: 11
                                                                color: {
                                                                    if (net.modelData.stateChanging)
                                                                        return "#fbbf24"
                                                                    if (net.modelData.connected)
                                                                        return "#4ade80"
                                                                    return root.dim(Colors.palette().text, 0.45)
                                                                }
                                                            }
                                                        }

                                                        // Saved-network star
                                                        Text {
                                                            visible: net.modelData.known && !net.modelData.connected
                                                            text: "★"
                                                            font.pixelSize: 13
                                                            color: root.dim(Colors.palette().text, 0.3)
                                                            Layout.alignment: Qt.AlignVCenter
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: netList.count === 0
                                            text: "No networks found"
                                            color: Colors.palette().subtext0
                                            font.pixelSize: 12
                                        }
                                    }

                                    PopupText {
                                        text: "Click to connect · right-click to forget"
                                        color: Colors.palette().subtext0
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ========================================================
        // BLUETOOTH
        // ========================================================

        Text {
            id: bluetooth

            text: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? "󰂯" : "󰂲"
            Layout.alignment: Qt.AlignHCenter
            color: popup2.show ? Colors.palette().pink : Colors.palette().text
            font.pixelSize: 14

            BasePopup {
                id: popup2

                parentItem: bluetooth
                screen: root.screen

                ColumnLayout {
                    spacing: 8
                    implicitWidth: 340

                    SwitchRow {
                        Layout.fillWidth: true
                        text: "Bluetooth"
                        checked: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
                        onToggled: value => {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.enabled = value
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        visible: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
                        text: "Scan for devices"
                        checked: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.discovering : false
                        onToggled: value => {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.discovering = value
                        }
                    }

                    SwitchRow {
                        Layout.fillWidth: true
                        visible: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
                        text: "Pairable"
                        checked: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.pairable : false
                        onToggled: value => {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.pairable = value
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 220
                        visible: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false

                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            ListView {
                                id: btList

                                model: Bluetooth.devices
                                spacing: 0

                                delegate: Item {
                                    id: dev

                                    required property var modelData

                                    readonly property bool busy: dev.modelData.state === BluetoothDeviceState.Connecting || dev.modelData.pairing === true

                                    width: ListView.view.width
                                    height: dev.modelData.name ? 28 : 0
                                    visible: dev.modelData.name ? true : false

                                    HoverHandler {
                                        id: hover
                                    }

                                    // left click: pair / connect / disconnect
                                    TapHandler {
                                        acceptedButtons: Qt.LeftButton
                                        onTapped: {
                                            if (dev.modelData.paired) {
                                                if (dev.modelData.connected) {
                                                    dev.modelData.disconnect()
                                                } else {
                                                    dev.modelData.trusted = true
                                                    dev.modelData.connect()
                                                }
                                            } else {
                                                dev.modelData.pair()
                                                dev.modelData.trusted = true
                                            }
                                        }
                                    }

                                    // right click: forget
                                    TapHandler {
                                        acceptedButtons: Qt.RightButton
                                        onTapped: {
                                            if (dev.modelData.paired)
                                                dev.modelData.forget()
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 4
                                        anchors.rightMargin: 4
                                        spacing: 8
                                        opacity: dev.modelData.paired ? 1.0 : 0.6

                                        readonly property color fg: hover.hovered ? Colors.palette().maroon : dev.modelData.connected ? Colors.palette().pink : Colors.palette().text

                                        Text {
                                            text: root.btIcon(dev.modelData.icon)
                                            color: parent.fg
                                            font.pixelSize: 14
                                        }

                                        Text {
                                            text: dev.modelData.name
                                            color: parent.fg
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            visible: dev.modelData.connected && dev.modelData.batteryAvailable
                                            text: Math.round(dev.modelData.battery * 100) + "%"
                                            color: Colors.palette().subtext0
                                            font.pixelSize: 11
                                        }

                                        BusyIndicator {
                                            visible: dev.busy
                                            running: dev.busy
                                            implicitWidth: 22
                                            implicitHeight: 22

                                            layer.enabled: true
                                            layer.effect: ColorOverlay {
                                                antialiasing: true
                                                color: "#D8D8D8"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: btList.count === 0
                            text: "No devices"
                            color: Colors.palette().subtext0
                            font.pixelSize: 12
                        }
                    }

                    PopupText {
                        text: "Click to connect · right-click to forget"
                        color: Colors.palette().subtext0
                        font.pixelSize: 10
                    }
                }
            }
        }

        // ========================================================
        // VOLUME
        // ========================================================

        Text {
            id: volume

            text: root.volumeIcon(root.sink && root.sink.audio ? root.sink.audio.volume : 0, root.sink && root.sink.audio ? root.sink.audio.muted : false)
            Layout.alignment: Qt.AlignHCenter
            color: basePopup.show ? Colors.palette().pink : Colors.palette().text
            font.pixelSize: 14

            // scroll to change volume
            WheelHandler {
                onWheel: event => {
                    const a = root.sink ? root.sink.audio : null
                    if (!a)
                        return
                    const step = event.angleDelta.y > 0 ? 0.05 : -0.05
                    a.volume = Math.max(0, Math.min(1, a.volume + step))
                }
            }

            // middle click to mute
            TapHandler {
                acceptedButtons: Qt.MiddleButton
                onTapped: {
                    const a = root.sink ? root.sink.audio : null
                    if (a)
                        a.muted = !a.muted
                }
            }

            BasePopup {
                id: basePopup

                parentItem: volume
                screen: root.screen

                StackView {
                    id: stack

                    implicitWidth: currentItem ? currentItem.implicitWidth : 0
                    implicitHeight: currentItem ? currentItem.implicitHeight : 0
                    initialItem: volumeBase
                }

                // ---------- Main page ----------
                Component {
                    id: volumeBase

                    ColumnLayout {
                        spacing: 8
                        implicitWidth: 300

                        PopupText {
                            text: "Output"
                            font.bold: true
                        }

                        VolumeRow {
                            Layout.fillWidth: true
                            node: root.sink
                            icon: root.volumeIcon(root.sink && root.sink.audio ? root.sink.audio.volume : 0, root.sink && root.sink.audio ? root.sink.audio.muted : false)
                        }

                        PopupButton {
                            menu: true
                            text: root.sink && root.sink.description ? root.sink.description : "Select Output"

                            clicked: function () {
                                stack.push(devicePage, {
                                    isOutput: true
                                });
                                basePopup.hoverUpdate(1);
                            }
                        }

                        PopupText {
                            text: "Input"
                            font.bold: true
                        }

                        VolumeRow {
                            Layout.fillWidth: true
                            node: root.source
                            icon: root.source && root.source.audio && root.source.audio.muted ? "󰍭" : "󰍬"
                        }

                        PopupButton {
                            menu: true
                            text: root.source && root.source.description ? root.source.description : "Select Input"

                            clicked: function () {
                                stack.push(devicePage, {
                                    isOutput: false
                                });
                                basePopup.hoverUpdate(1);
                            }
                        }
                    }
                }

                // ---------- Device picker (output or input) ----------
                Component {
                    id: devicePage

                    ColumnLayout {
                        id: page

                        property bool isOutput: true

                        spacing: 10
                        implicitWidth: 300

                        ButtonGroup {
                            id: buttonGroup
                        }

                        PopupText {
                            text: page.isOutput ? "Select Output" : "Select Input"
                            font.bold: true
                        }

                        Repeater {
                            model: Pipewire.nodes

                            delegate: Item {
                                id: node

                                required property PwNode modelData

                                readonly property bool isMatch: node.modelData && !node.modelData.isStream && (page.isOutput ? node.modelData.isSink : (!node.modelData.isSink && node.modelData.audio !== null))

                                readonly property var current: page.isOutput ? root.sink : root.source

                                Layout.fillWidth: true
                                implicitHeight: 22
                                implicitWidth: 200

                                visible: isMatch

                                RadioButton {
                                    id: control

                                    anchors.fill: parent
                                    ButtonGroup.group: buttonGroup

                                    checked: node.isMatch && node.current !== null && node.current.name === node.modelData.name

                                    onHoveredChanged: {
                                        basePopup.hoverUpdate(hovered ? 1 : -1);
                                    }

                                    onClicked: {
                                        if (page.isOutput)
                                            Pipewire.preferredDefaultAudioSink = node.modelData;
                                        else
                                            Pipewire.preferredDefaultAudioSource = node.modelData;
                                    }

                                    contentItem: Text {
                                        rightPadding: control.indicator.width + control.spacing
                                        text: node.modelData.nickname || node.modelData.description || node.modelData.name
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
                                        border.color: Colors.palette().pink

                                        Rectangle {
                                            width: 11
                                            height: 11
                                            radius: 13
                                            x: 0.5
                                            y: 0.5
                                            color: Colors.palette().pink
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

        // ========================================================
        // NOTIFICATIONS
        // NOTE: the list below assumes the history model exposes
        // appName / summary / body. Adjust to your NotificationManager.
        // ========================================================

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

                ColumnLayout {
                    spacing: 8
                    implicitWidth: 320

                    PopupText {
                        text: "Notifications (" + NotificationManager.historyNotifications.count + ")"
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 220

                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            ListView {
                                id: notifList

                                model: NotificationManager.historyNotifications
                                spacing: 6

                                delegate: Rectangle {
                                    id: notif

                                    required property var model

                                    readonly property var n: notif.model.modelData !== undefined ? notif.model.modelData : notif.model

                                    width: ListView.view.width
                                    height: notifCol.implicitHeight + 12
                                    radius: 6
                                    color: root.dim(Colors.palette().text, 0.06)

                                    Column {
                                        id: notifCol

                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 8
                                        spacing: 2

                                        Text {
                                            width: parent.width
                                            text: notif.n.appName ? notif.n.appName : ""
                                            visible: text !== ""
                                            color: Colors.palette().subtext0
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            width: parent.width
                                            text: notif.n.summary ? notif.n.summary : ""
                                            color: Colors.palette().text
                                            font.pixelSize: 12
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            width: parent.width
                                            text: notif.n.body ? notif.n.body : ""
                                            visible: text !== ""
                                            color: Colors.palette().subtext0
                                            font.pixelSize: 11
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: notifList.count === 0
                            text: "No notifications"
                            color: Colors.palette().subtext0
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // ========================================================
        // POWER PROFILE
        // ========================================================

        Text {
            id: power_profile

            text: root.profileIcon(PowerProfiles.profile)
            color: powerPopup.show ? Colors.palette().pink : Colors.palette().text
            font.pixelSize: 14

            Layout.alignment: Qt.AlignHCenter

            BasePopup {
                id: powerPopup

                parentItem: power_profile
                screen: root.screen

                ColumnLayout {
                    spacing: 6
                    implicitWidth: 220

                    PopupText {
                        text: "Power Profile"
                        font.bold: true
                    }

                    Repeater {
                        model: [
                            {
                                label: "Power Saver",
                                icon: "󰌪",
                                profile: PowerProfile.PowerSaver
                            },
                            {
                                label: "Balanced",
                                icon: "󰗑",
                                profile: PowerProfile.Balanced
                            },
                            {
                                label: "Performance",
                                icon: "󱐋",
                                profile: PowerProfile.Performance
                            }
                        ]

                        delegate: Rectangle {
                            id: prof

                            required property var modelData

                            readonly property bool selected: PowerProfiles.profile === prof.modelData.profile

                            visible: prof.modelData.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile

                            Layout.fillWidth: true
                            Layout.preferredHeight: 32

                            radius: 6
                            color: prof.selected ? Colors.palette().surface0 : "transparent"
                            border.width: prof.selected ? 1 : 0
                            border.color: Colors.palette().pink

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: prof.modelData.icon
                                    font.pixelSize: 14
                                    color: prof.selected ? Colors.palette().pink : Colors.palette().text
                                }

                                Text {
                                    text: prof.modelData.label
                                    font.pixelSize: 12
                                    color: prof.selected ? Colors.palette().pink : Colors.palette().text
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PowerProfiles.profile = prof.modelData.profile
                            }
                        }
                    }
                }
            }
        }

        // ========================================================
        // BATTERY
        // ========================================================

        Row {
            id: battery

            property UPowerDevice power: UPower.displayDevice
            property int lastLevel: -1

            function notify(text) {
                NotificationManager.sendNotification("battery", "Battery Status", text);
            }

            // Fires once when a threshold is crossed, instead of
            // comparing a float to an exact number.
            function checkLevels() {
                const level = Math.round(power.percentage * 100);
                const prev = lastLevel;
                lastLevel = level;

                if (prev < 0)
                    return;

                const state = power.state;

                if (state === UPowerDeviceState.Discharging) {
                    if (prev > 5 && level <= 5)
                        notify("Shutting off soon " + level + "%");
                    else if (prev > 20 && level <= 20)
                        notify("Low battery " + level + "%");
                } else if (state === UPowerDeviceState.Charging) {
                    if (prev < 100 && level >= 100)
                        notify("Fully charged 100%");
                    else if (prev < 80 && level >= 80)
                        notify("Almost full " + level + "%");
                }
            }

            Connections {
                target: battery.power

                function onPercentageChanged() {
                    battery.checkLevels();
                }
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

                parentItem: battery
                screen: root.screen

                ColumnLayout {
                    spacing: 4
                    implicitWidth: 200

                    PopupText {
                        text: "Battery " + Math.round(battery.power.percentage * 100) + "%"
                        font.bold: true
                    }

                    PopupText {
                        text: UPowerDeviceState.toString(battery.power.state)
                        color: Colors.palette().subtext0
                    }

                    PopupText {
                        visible: battery.power.state === UPowerDeviceState.Discharging
                        text: root.fmtSeconds(battery.power.timeToEmpty) + " remaining"
                    }

                    PopupText {
                        visible: battery.power.state === UPowerDeviceState.Charging
                        text: root.fmtSeconds(battery.power.timeToFull) + " until full"
                    }

                    PopupText {
                        visible: Math.abs(battery.power.changeRate) > 0.1
                        text: (battery.power.state === UPowerDeviceState.Charging ? "Charging at " : "Drawing ") + Math.abs(battery.power.changeRate).toFixed(1) + " W"
                        color: Colors.palette().subtext0
                    }
                }
            }
        }
    }
}
