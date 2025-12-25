import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import "../colors"
import "./components"
import "../components/effects"
import "../components"
import "../services" as Services

Scope {
    id: controlCenter

    Variants {
        model: Quickshell.screens

        Item {

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    panel.visible = true;
                }
            }
        }

        PanelWindow {
            id: root
            required property var modelData

            property var hoverBarRegion: Region {
                item: hoverBar
            }

            property var bothRegions: Region {
                item: hoverBar
                Region {
                    item: panelContent
                }
            }

            screen: modelData
            visible: true
            mask: Region {
                item: hoverBar
            }
            // mask: panelContent.visible ? (Region { item: hoverBar; Region {
            //      item: panelContent
            // }}) : Region { item: hoverBar }
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Normal
            anchors {
                top: true
            }

            implicitWidth: screen.width / 2.5
            implicitHeight: Math.min(400, screen.height - 40)

            Rectangle {
                id: hoverBar
                color: "transparent"
                height: 1
                width: 500
                anchors.horizontalCenter: parent.horizontalCenter

                Timer {
                    id: hideTimer
                    interval: 5000
                    onTriggered: () => {
                        root.mask = root.hoverBarRegion;
                        panelContent.show = false;
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        panelContent.show = true;
                        root.mask = root.bothRegions;

                        if (panelContent.visible == false)
                            panelContent.visible = true;
                        hideTimer.restart();
                    }
                }
            }

            FocusScope {
                id: panelContent
                anchors.fill: parent
                transformOrigin: Item.Top
                property bool show: false
                visible: false

                // Show Animation - Material 3 emphasized decelerate
                SequentialAnimation {
                    running: panelContent.show
                    ParallelAnimation {
                        NumberAnimation {
                            target: panelContent
                            property: "scale"
                            from: 0.94
                            to: 1.0
                            duration: Material3Anim.medium2

                            easing.bezierCurve: Material3Anim.emphasizedDecelerate
                        }
                        NumberAnimation {
                            target: panelContent
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: Material3Anim.medium1
                            easing.bezierCurve: Material3Anim.standard
                        }
                    }
                }

                SequentialAnimation {
                    running: !panelContent.show
                    ParallelAnimation {
                        NumberAnimation {
                            target: panelContent
                            property: "scale"
                            from: 1.0
                            to: 0.94
                            duration: Material3Anim.medium2

                            easing.bezierCurve: Material3Anim.emphasizedDecelerate
                        }
                        NumberAnimation {
                            target: panelContent
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: Material3Anim.medium1
                            easing.bezierCurve: Material3Anim.standard
                        }
                    }
                }

                StyledRect {
                    topLeftRadius: 0
                    topRightRadius: 0
                    radius: 24
                    anchors.fill: parent

                    color: "red"

                    ColumnLayout {
                        id: panelContentWrapper
                        anchors.fill: parent
                        anchors.margins: 12
                        width: parent.width / 2
                        height: parent.height
                        visible: true
                        spacing: 16

                        // Header Section
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 56
                            spacing: 12

                            // Time & Date
                            ColumnLayout {
                                spacing: 2

                                Text {
                                    id: timeText
                                    text: Qt.formatTime(new Date(), "hh:mm")
                                    font.family: "Inter"
                                    font.pixelSize: 32
                                    font.weight: Font.Bold
                                    color: Color.palette().text
                                }

                                Text {
                                    text: Qt.formatDate(new Date(), "dddd, MMMM d")
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: Color.palette().text
                                }

                                Timer {
                                    interval: 1000
                                    running: true
                                    repeat: true
                                    onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            // Header Actions
                            RowLayout {
                                spacing: 6

                                HeaderButton {
                                    icon: "󰒓"
                                    tooltip: "Network Settings"
                                }
                                HeaderButton {
                                    icon: "󰍜"
                                    tooltip: "Lock Screen"
                                }
                                HeaderButton {
                                    icon: "󰐥"
                                    tooltip: "Power Menu"
                                }
                            }
                        }

                        // Scrollable Content
                        Flickable {
                            id: contentFlick
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            contentHeight: contentColumn.height
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            flickDeceleration: 3000
                            maximumFlickVelocity: 2000

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                width: 4

                                contentItem: Rectangle {
                                    radius: 2
                                }
                            }

                            ColumnLayout {
                                id: contentColumn
                                width: contentFlick.width
                                spacing: 14

                                // Quick Toggles
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 10
                                    rowSpacing: 10

                                    QuickToggle {
                                        Layout.fillWidth: true
                                        icon: "󰖩"
                                        label: "Wi-Fi"
                                        // subLabel: root.network.connected ? root.network.ssid : "Disconnected"
                                        // active: root.network.wifiEnabled
                                        // activeColor: root.cPrimary
                                        // surfaceColor: root.cSurfaceContainerHigh
                                        // textColor: root.cOnSurface
                                        // onClicked: root.network.toggleWifi()
                                    }
                                    QuickToggle {
                                        Layout.fillWidth: true
                                        icon: "󰂯"
                                        label: "Bluetooth"
                                        // subLabel: root.bluetooth.powered ? "On" : "Off"
                                        // active: root.bluetooth.powered
                                        // activeColor: root.cPrimary
                                        // surfaceColor: root.cSurfaceContainerHigh
                                        // textColor: root.cOnSurface
                                        // onClicked: root.bluetooth.togglePower()
                                    }
                                    QuickToggle {
                                        Layout.fillWidth: true
                                        icon: "󰔎"
                                        label: "Do Not Disturb"
                                        // subLabel: root.notifs.dnd ? "On" : "Off"
                                        // active: root.notifs.dnd
                                        // activeColor: pywal.warning
                                        // surfaceColor: root.cSurfaceContainerHigh
                                        // textColor: root.cOnSurface
                                        // onClicked: root.notifs.toggleDnd()
                                    }
                                    QuickToggle {
                                        Layout.fillWidth: true
                                        icon: "󰅶"
                                        label: "Caffeine"
                                        // subLabel: root.idleInhibitor.inhibited ? "Active" : "Off"
                                        // active: root.idleInhibitor.inhibited
                                        // activeColor: pywal.info
                                        // surfaceColor: root.cSurfaceContainerHigh
                                        // textColor: root.cOnSurface
                                        // onClicked: root.idleInhibitor.inhibited = !root.idleInhibitor.inhibited
                                    }
                                    QuickToggle {
                                        Layout.fillWidth: true
                                        Layout.columnSpan: 2
                                        icon: "󰹑"
                                        label: "Screenshot"
                                        subLabel: "Capture Screen"
                                        active: false
                                        // activeColor: root.cSecondary
                                        // surfaceColor: root.cSurfaceContainerHigh
                                        // textColor: root.cOnSurface
                                        // onClicked: root.screenshot.takeScreenshot("screen")
                                    }
                                }

                                // Divider
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: Color.palette().crust
                                }

                                // Sliders Section
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    VolumeSlider {
                                        Layout.fillWidth: true
                                    }
                                }

                                // Divider
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 1
                                    color: Color.palette().crust
                                }

                                // Media Card
                                MediaCard {
                                    Layout.fillWidth: true
                                    mpris: Services.Players
                                    // pywal: root.pywal
                                }

                                // Bottom padding
                                Item {
                                    Layout.preferredHeight: 4
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Header Button Component
    component HeaderButton: Rectangle {
        id: headerBtn
        property string icon
        property string tooltip: ""
        signal clicked

        width: 40
        height: 40
        radius: 20
        // color: headerBtnMouse.containsMouse
        //     ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.1)
        //     : root.cSurfaceContainer

        Behavior on color {
            ColorAnimation {
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.standard
            }
        }

        scale: headerBtnMouse.pressed ? 0.92 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: Material3Anim.short2
                easing.bezierCurve: Material3Anim.standard
            }
        }

        Text {
            anchors.centerIn: parent
            text: headerBtn.icon
            font.family: "Material Design Icons"
            font.pixelSize: 18
            // color: root.cOnSurface
        }

        MouseArea {
            id: headerBtnMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: headerBtn.clicked()
        }

        ToolTip.visible: headerBtnMouse.containsMouse && headerBtn.tooltip !== ""
        ToolTip.text: headerBtn.tooltip
        ToolTip.delay: 500
    }
}
