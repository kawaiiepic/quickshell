// ~/.config/quickshell/modules/settings/settings-window.qml
// Floating "Wired"-style settings panel.
// Looks like a machine that knows too much.
// Which is apparently the ideal desktop vibe now.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import QtCore
import "../../services"
import "../../theme"

FloatingWindow {
    id: root
    implicitWidth: 720
    implicitHeight: 520
    visible: GlobalData.settingsWindow
    color: Colors.palette().base

    onVisibleChanged: {
        if (!visible)
            GlobalData.settingsWindow = false;
    }

    // ─── Inline Components ───────────────────────────────────────────────────

    // Section heading strip
    component SSection: Item {
        id: section
        required property string title
        Layout.fillWidth: true
        implicitHeight: childrenRect.height

        Text {
            id: text
            text: section.title
            font.pixelSize: 14
            font.weight: Font.Bold
            font.letterSpacing: 0
            color: Colors.palette().pink
            height: 50
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Settings row — label + optional description + right-aligned control
    // Usage: add exactly one control item as a direct child (Switch, ComboBox, etc.)
    component SRow: RowLayout {
        id: srow
        required property string label
        property string desc: ""

        Layout.fillWidth: true
        implicitHeight: desc.length > 0 ? 54 : 44
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Item {
                implicitHeight: 4
            }

            Text {
                text: srow.label
                font.pixelSize: 15
                color: Colors.palette().text
            }
            Text {
                visible: srow.desc.length > 0
                text: srow.desc
                font.pixelSize: 9
                color: Colors.palette().subtext0
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Item {
                implicitHeight: 4
            }
        }

        // Note: caller's children slots in here at layout level,
        // right-aligned by default via Layout.alignment on the child.
    }

    // ─── Root Layout ─────────────────────────────────────────────────────────

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Title bar ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 46
            color: Colors.palette().surface0

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 12
                }
                spacing: 0

                // Drag handle — lets the window move
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: Colors.palette().pink
                        }
                        Text {
                            text: "SETTINGS"
                            font.pixelSize: 10
                            font.family: "monospace"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            color: Colors.palette().text
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        property point origin
                        onPressed: origin = Qt.point(mouseX, mouseY)
                        onPositionChanged: {
                            if (pressed) {
                                root.x += mouseX - origin.x;
                                root.y += mouseY - origin.y;
                            }
                        }
                    }
                }

                Text {
                    text: Qt.application.version || "dev"
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: Colors.palette().text
                    rightPadding: 12
                }

                // Close button
                Rectangle {
                    width: 22
                    height: 22
                    radius: 3
                    color: closeMa.containsMouse ? Colors.palette().surface1 : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 80
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 10
                        color: closeMa.containsMouse ? Colors.palette().pink : Colors.palette().text
                    }
                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.visible = false
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Colors.palette().base
            }
        }

        // ── Body ─────────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // ── Sidebar ──────────────────────────────────────────────────────
            Rectangle {
                implicitWidth: 168
                Layout.fillHeight: true
                color: Colors.palette().surface0

                ListView {
                    id: nav
                    anchors {
                        fill: parent
                        topMargin: 10
                        bottomMargin: 10
                    }
                    clip: true
                    currentIndex: 0

                    // Using JS array model (Qt 6); icon strings use Unicode fallbacks
                    // (swap for Nerd Font codepoints if you have them)
                    model: [
                        {
                            label: "Appearance",
                            icon: "◈"
                        },
                        {
                            label: "Audio",
                            icon: "♪"
                        },
                        {
                            label: "Display",
                            icon: "◫"
                        },
                        {
                            label: "Network",
                            icon: "⌘"
                        },
                        {
                            label: "System",
                            icon: "⚙"
                        },
                    ]

                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        width: ListView.view.width
                        height: 44

                        color: nav.currentIndex === index ? Colors.palette().surface1 : navMa.containsMouse ? Colors.palette().surface1 : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: 80
                            }
                        }

                        // Active indicator strip
                        Rectangle {
                            visible: nav.currentIndex === index
                            width: 3
                            height: 18
                            radius: 1
                            anchors.verticalCenter: parent.verticalCenter
                            color: Colors.palette().pink
                        }

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 14
                                rightMargin: 8
                            }
                            spacing: 8

                            Text {
                                text: modelData.icon
                                font.pixelSize: 12
                                color: nav.currentIndex === index ? Colors.palette().pink : Colors.palette().flamingo
                            }
                            Text {
                                text: modelData.label
                                font.pixelSize: 13
                                font.family: "monospace"
                                color: nav.currentIndex === index ? Colors.palette().text : Colors.palette().subtext0
                                Layout.fillWidth: true
                            }
                        }

                        MouseArea {
                            id: navMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: nav.currentIndex = index
                        }
                    }
                }
            }

            // ── Content stack ─────────────────────────────────────────────────

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: nav.currentIndex

                // ─────────────────────────────────────────────────────────────
                // Page 0 — Appearance
                // ─────────────────────────────────────────────────────────────
                Flickable {
                    clip: true
                    contentHeight: p0.implicitHeight

                    ColumnLayout {
                        id: p0
                        width: parent.width
                        spacing: 0

                        SSection {
                            title: "Bar"
                        }

                        SRow {
                            label: "Detailed Workspace"
                            desc: "Whether the workspace should be simple or more detailed."
                            Switch {
                                checked: ShellSettings.detailedWorkspaces
                                onClicked: ShellSettings.detailedWorkspaces = checked

                            }

                            Item {
                                width: 2
                            }
                        }

                        // SRow {
                        //     label: "Color scheme"
                        //     desc: "Dark, light, or follow system"
                        //     ComboBox {
                        //         model: ["Dark", "Light", "System"]
                        //         font.pixelSize: 13
                        //         background: Rectangle {
                        //             implicitHeight: 30
                        //             radius: 20
                        //             color: Colors.palette().overlay2
                        //         }
                        //         implicitWidth: 100
                        //         Layout.alignment: Qt.AlignVCenter
                        //     }

                        //     Item {
                        //         width: 2
                        //     }
                        // }

                        // SRow {
                        //     label: "Accent color"
                        //     desc: "Primary highlight color"
                        //     // Swatch picker — swap for a proper ColorDialog if preferred
                        //     Row {
                        //         spacing: 5
                        //         Layout.alignment: Qt.AlignVCenter
                        //         Repeater {
                        //             model: ["#cba6f7", "#89b4fa", "#a6e3a1", "#f38ba8", "#fab387", "#f9e2af"]
                        //             delegate: Rectangle {
                        //                 width: 18
                        //                 height: 18
                        //                 radius: 9
                        //                 color: modelData
                        //                 border.width: swMa.containsMouse ? 2 : 0
                        //                 border.color: Colors.palette().text
                        //                 MouseArea {
                        //                     id: swMa
                        //                     anchors.fill: parent
                        //                     hoverEnabled: true
                        //                 }
                        //             }
                        //         }
                        //     }
                        // }
                    }
                }

                // ─────────────────────────────────────────────────────────────
                // Page 1 — Audio
                // ─────────────────────────────────────────────────────────────
                Flickable {
                    clip: true
                    contentHeight: p1.implicitHeight

                    ColumnLayout {
                        id: p1
                        width: parent.width
                        spacing: 0

                        SSection {
                            title: "OUTPUT"
                        }

                        SRow {
                            label: "Default sink"
                            desc: "Audio output device"
                            ComboBox {
                                model: ["Built-in Audio", "HDMI Audio", "USB Headset"]
                                font.family: "monospace"
                                font.pixelSize: 11
                                implicitWidth: 140
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Volume step"
                            desc: "Percent change per key press"
                            SpinBox {
                                from: 1
                                to: 20
                                value: 5
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Volume OSD"
                            desc: "On-screen overlay on volume change"
                            Switch {
                                checked: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Max volume"
                            desc: "Allow over-amplification (>100%)"
                            Switch {
                                checked: false
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SSection {
                            title: "INPUT"
                        }

                        SRow {
                            label: "Default source"
                            desc: "Microphone / capture device"
                            ComboBox {
                                model: ["Built-in Mic", "USB Mic", "HDMI Input"]
                                font.family: "monospace"
                                font.pixelSize: 11
                                implicitWidth: 130
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Mute on launch"
                            desc: "Start with microphone muted"
                            Switch {
                                checked: false
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SSection {
                            title: "MEDIA"
                        }

                        SRow {
                            label: "Media keys"
                            desc: "Global play/pause/skip bindings"
                            Switch {
                                checked: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Now-playing widget"
                            desc: "Show MPRIS player in bar"
                            Switch {
                                checked: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                // ─────────────────────────────────────────────────────────────
                // Page 2 — Display
                // ─────────────────────────────────────────────────────────────
                Flickable {
                    clip: true
                    contentHeight: p2.implicitHeight

                    ColumnLayout {
                        id: p2
                        width: parent.width
                        spacing: 0

                        SSection {
                            title: "SCREEN"
                        }

                        SRow {
                            label: "Scale"
                            desc: "HiDPI scaling factor"
                            ComboBox {
                                model: ["1×", "1.25×", "1.5×", "1.75×", "2×"]
                                font.family: "monospace"
                                font.pixelSize: 11
                                implicitWidth: 90
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Refresh rate"
                            desc: "Target frame rate"
                            ComboBox {
                                model: ["60 Hz", "120 Hz", "144 Hz", "165 Hz", "240 Hz"]
                                font.family: "monospace"
                                font.pixelSize: 11
                                implicitWidth: 100
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "VRR / Adaptive sync"
                            desc: "Variable refresh rate (G-Sync / FreeSync)"
                            Switch {
                                checked: false
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SSection {
                            title: "NIGHT LIGHT"
                        }

                        SRow {
                            label: "Enable"
                            desc: "Reduce blue light after sunset"
                            Switch {
                                checked: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Color temperature"
                            desc: "Kelvin value — lower is warmer"
                            Slider {
                                from: 2700
                                to: 6500
                                value: 4200
                                stepSize: 100
                                implicitWidth: 120
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Schedule"
                            desc: "Activate automatically at sunset"
                            Switch {
                                checked: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                // ─────────────────────────────────────────────────────────────
                // Page 3 — Network (placeholder — wire up to NetworkManager)
                // ─────────────────────────────────────────────────────────────
                Item {
                    Text {
                        anchors.centerIn: parent
                        text: "// network\n// not yet wired"
                        font.pixelSize: 12
                        font.family: "monospace"
                        color: Colors.palette().text
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.9
                    }
                }

                // ─────────────────────────────────────────────────────────────
                // Page 4 — System
                // ─────────────────────────────────────────────────────────────
                Flickable {
                    clip: true
                    contentHeight: p4.implicitHeight

                    ColumnLayout {
                        id: p4
                        width: parent.width
                        spacing: 0

                        SSection {
                            title: "STARTUP"
                        }

                        SRow {
                            label: "Startup delay"
                            desc: "Seconds before services initialize"
                            SpinBox {
                                from: 0
                                to: 10
                                value: 1
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Restore session"
                            desc: "Reload previous workspace layout"
                            Switch {
                                checked: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Idle timeout"
                            desc: "Minutes before screen locks (0 = never)"
                            SpinBox {
                                from: 0
                                to: 60
                                value: 10
                                stepSize: 5
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SSection {
                            title: "NOTIFICATIONS"
                        }

                        SRow {
                            label: "Enable"
                            desc: "Show desktop notifications"
                            Switch {
                                checked: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Timeout"
                            desc: "Auto-dismiss after (seconds)"
                            SpinBox {
                                from: 2
                                to: 30
                                value: 8
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Do not disturb"
                            desc: "Suppress all notifications"
                            Switch {
                                checked: false
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Notification position"
                            ComboBox {
                                model: ["Top right", "Top left", "Bottom right", "Bottom left"]
                                font.family: "monospace"
                                font.pixelSize: 11
                                implicitWidth: 120
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SSection {
                            title: "ABOUT"
                        }

                        SRow {
                            label: "Version"
                            Text {
                                text: Qt.application.version || "dev"
                                font.family: "monospace"
                                font.pixelSize: 10
                                color: Colors.palette().text
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        SRow {
                            label: "Reload config"
                            Button {
                                text: "Reload"
                                font.family: "monospace"
                                font.pixelSize: 10
                                implicitWidth: 80
                                Layout.alignment: Qt.AlignVCenter
                                onClicked: Quickshell.reload()
                            }
                        }
                    }
                }
            }
        }
    }
}
