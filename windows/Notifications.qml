import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 300
    height: 220
    color: "transparent"

    ListModel {
        id: notifModel
        ListElement {
            app:     "Discord"
            body:    "new message from @kouhai"
            ago:     "1m ago"
            icon:    "󰙯"
        }
        ListElement {
            app:     "System Update"
            body:    "updates available"
            ago:     "12m ago"
            icon:    "󰣇"
        }
        ListElement {
            app:     "Weather"
            body:    "light rain later today"
            ago:     "32m ago"
            icon:    "󰖔"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#09080f"
        radius: 10
        border.color: "#2d1f4e"
        border.width: 1
        clip: true

        Rectangle {
            anchors.fill: parent
            color: "#1a0533"
            opacity: 0.4
            radius: 10
        }

        Rectangle { x: 8; y: 8; width: 10; height: 1; color: "#a855f7"; opacity: 0.7 }
        Rectangle { x: 8; y: 8; width: 1; height: 10; color: "#a855f7"; opacity: 0.7 }
        Rectangle { x: parent.width - 18; y: parent.height - 9;  width: 10; height: 1; color: "#ec4899"; opacity: 0.7 }
        Rectangle { x: parent.width - 9;  y: parent.height - 18; width: 1;  height: 10; color: "#ec4899"; opacity: 0.7 }

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "transparent" }
                GradientStop { position: 0.35; color: "#a855f7" }
                GradientStop { position: 0.65; color: "#ec4899" }
                GradientStop { position: 1.0;  color: "transparent" }
            }
        }

        Repeater {
            model: Math.ceil(root.height / 4)
            delegate: Rectangle {
                x: 0; y: index * 4
                width: root.width; height: 2
                color: "#000000"; opacity: 0.1
            }
        }

        ColumnLayout {
            anchors { fill: parent; margins: 18 }
            spacing: 0

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "NOTIFICATIONS"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.letterSpacing: 3
                    font.weight: Font.Medium
                    color: "#4a3570"
                }

                Item { Layout.fillWidth: true }

                // Clear all
                Text {
                    text: "clear"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.letterSpacing: 1
                    color: clearHover.containsMouse ? "#ec4899" : "#3d2a5e"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notifModel.clear()
                    }
                }
            }

            Item { Layout.preferredHeight: 14 }

            // ── Empty state ───────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: notifModel.count === 0

                Text {
                    anchors.centerIn: parent
                    text: "no notifications"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.letterSpacing: 1
                    color: "#2d1f4e"
                }
            }

            // ── Notification list ─────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                visible: notifModel.count > 0

                Repeater {
                    model: notifModel

                    delegate: Item {
                        Layout.fillWidth: true
                        height: 52

                        // Hover bg
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -4
                            radius: 5
                            color: rowHover.containsMouse ? "#1c1030" : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        // Left accent bar
                        Rectangle {
                            x: -4
                            anchors.verticalCenter: parent.verticalCenter
                            width: 2
                            height: rowHover.containsMouse ? 36 : 0
                            radius: 1
                            color: "#a855f7"
                            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10

                            // Icon bubble
                            Rectangle {
                                width: 32; height: 32; radius: 8
                                color: "#1c1030"
                                border.color: "#2d1f4e"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: icon
                                    font.pixelSize: 15
                                    color: "#a855f7"
                                }
                            }

                            // Text
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Text {
                                        text: app
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: "#c4b5d4"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: ago
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 9
                                        color: "#3d2a5e"
                                        font.letterSpacing: 0.5
                                    }
                                }

                                Text {
                                    text: body
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                    color: "#4a3570"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            // Dismiss
                            Text {
                                text: "×"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 14
                                color: dimissHover.containsMouse ? "#ec4899" : "#2d1f4e"
                                visible: rowHover.containsMouse || dimissHover.containsMouse
                                Behavior on color { ColorAnimation { duration: 120 } }

                                MouseArea {
                                    id: dimissHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notifModel.remove(index)
                                }
                            }
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onClicked: (m) => m.accepted = false
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}