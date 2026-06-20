import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 1000
    height: 800
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#09080f"
        radius: 10
        border.color: "#2d1f4e"
        border.width: 1
        clip: false

        // ── Background image ──────────────────────────────────────────────
        ClippingRectangle {
            anchors.fill: parent
            opacity: 0.45
            radius: 10
            Image {
                anchors.fill: parent
                source: "file:" + Quickshell.shellPath("assets/icons/girl.png")
                fillMode: Image.PreserveAspectCrop
            }
        }

        // Dark gradient overlay — heavier at bottom so text is readable
        Rectangle {
            anchors.fill: parent
            radius: 10
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#aa09080f" }
                GradientStop { position: 0.6; color: "#cc09080f" }
                GradientStop { position: 1.0; color: "#f009080f" }
            }
        }

        // Scanlines
        Repeater {
            model: Math.ceil(root.height / 4)
            delegate: Rectangle {
                x: 0
                y: index * 4
                width: root.width
                height: 2
                color: "#000000"
                opacity: 0.06
                z: 2
            }
        }

        // Corner brackets
        Rectangle {
            x: 8
            y: 8
            width: 12
            height: 1
            color: "#a855f7"
            opacity: 0.8
            z: 3
        }
        Rectangle {
            x: 8
            y: 8
            width: 1
            height: 12
            color: "#a855f7"
            opacity: 0.8
            z: 3
        }
        Rectangle {
            x: parent.width - 20
            y: 8
            width: 12
            height: 1
            color: "#a855f7"
            opacity: 0.8
            z: 3
        }
        Rectangle {
            x: parent.width - 9
            y: 8
            width: 1
            height: 12
            color: "#a855f7"
            opacity: 0.8
            z: 3
        }
        Rectangle {
            x: 8
            y: parent.height - 9
            width: 12
            height: 1
            color: "#ec4899"
            opacity: 0.8
            z: 3
        }
        Rectangle {
            x: 8
            y: parent.height - 20
            width: 1
            height: 12
            color: "#ec4899"
            opacity: 0.8
            z: 3
        }
        Rectangle {
            x: parent.width - 20
            y: parent.height - 9
            width: 12
            height: 1
            color: "#ec4899"
            opacity: 0.8
            z: 3
        }
        Rectangle {
            x: parent.width - 9
            y: parent.height - 20
            width: 1
            height: 12
            color: "#ec4899"
            opacity: 0.8
            z: 3
        }

        // Top gradient line
        Rectangle {
            z: 3
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.3
                    color: "#a855f7"
                }
                GradientStop {
                    position: 0.7
                    color: "#ec4899"
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        // ── Content ───────────────────────────────────────────────────────
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 0
            z: 4

            Item {
                Layout.fillHeight: true
            }

            // Name block
            Text {
                text: "Lain Iwakura"
                font.family: "JetBrains Mono"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: "#e2d4f0"
            }

            Item {
                height: 4
            }

            // Japanese subtitle
            Text {
                text: "接続されました"
                font.family: "JetBrains Mono"
                font.pixelSize: 13
                color: "#ec4899"
                Layout.bottomMargin: 16
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2d1f4e"
                opacity: 0.8
                Layout.bottomMargin: 12
            }

            // Info rows
            Repeater {
                model: [
                    {
                        label: "SESSION ID:",
                        value: "0x7F8A2C1E"
                    },
                    {
                        label: "USER:",
                        value: "lain"
                    },
                    {
                        label: "SHELL:",
                        value: "zsh"
                    },
                ]

                delegate: RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 6

                    Text {
                        text: modelData.label
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        font.letterSpacing: 0.5
                        color: "#6b4f8a"
                        Layout.preferredWidth: 80
                    }

                    Text {
                        text: modelData.value
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        color: "#c4b5d4"
                    }
                }
            }

            Item {
                height: 14
            }

            // Status badge
            RowLayout {
                spacing: 6

                Rectangle {
                    width: 5
                    height: 5
                    radius: 3
                    color: "#a855f7"

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 0.2
                            duration: 900
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: 900
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                Text {
                    text: "ONLINE"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 8
                    font.letterSpacing: 2
                    color: "#a855f7"
                }
            }
        }
    }
}
