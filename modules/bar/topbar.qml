import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 42
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#0a0b12"
                opacity: 0.82

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#7c3aed"
                    opacity: 0.4
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 16

                // Left section
                RowLayout {
                    spacing: 14

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 999
                        color: "#ec4899"

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: true

                            NumberAnimation {
                                to: 0.3
                                duration: 1200
                            }

                            NumberAnimation {
                                to: 1.0
                                duration: 1200
                            }
                        }
                    }

                    Text {
                        text: ">_ quickshell"
                        color: "#f5d0fe"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: Font.Medium
                    }

                    Rectangle {
                        width: 1
                        height: 18
                        color: "#312e81"
                    }

                    Repeater {
                        model: ["term", "web", "code", "media"]

                        delegate: Rectangle {
                            required property string modelData

                            radius: 8
                            color: mouse.containsMouse
                                ? "#1e1b4b"
                                : "transparent"

                            implicitWidth: label.width + 18
                            implicitHeight: 28

                            border.width: 1
                            border.color: mouse.containsMouse
                                ? "#8b5cf6"
                                : "transparent"

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: modelData
                                color: mouse.containsMouse
                                    ? "#f5d0fe"
                                    : "#c4b5fd"
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Center pulse line
                RowLayout {
                    spacing: 3

                    Repeater {
                        model: 18

                        delegate: Rectangle {
                            width: 3
                            height: Math.random() * 10 + 4
                            radius: 999
                            color: index % 2 === 0
                                ? "#a855f7"
                                : "#ec4899"
                            opacity: 0.6
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Right section
                RowLayout {
                    spacing: 18

                    Text {
                        text: "󰖩"
                        color: "#c4b5fd"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                    }

                    Text {
                        text: "󰕾"
                        color: "#c4b5fd"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                    }

                    Text {
                        text: "󰤨"
                        color: "#c4b5fd"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                    }

                    Rectangle {
                        width: 1
                        height: 18
                        color: "#312e81"
                    }

                    Text {
                        id: clock
                        color: "#f5d0fe"
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"

                        property string currentTime: ""
                        text: currentTime

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true

                            onTriggered: {
                                const now = new Date()
                                clock.currentTime = Qt.formatDateTime(
                                    now,
                                    "MMM dd   hh:mm AP"
                                )
                            }
                        }

                        Component.onCompleted: {
                            const now = new Date()
                            currentTime = Qt.formatDateTime(
                                now,
                                "MMM dd   hh:mm AP"
                            )
                        }
                    }
                }
            }
        }
    }
}