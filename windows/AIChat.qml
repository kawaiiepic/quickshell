import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../services"

Rectangle {
    id: root
    width: 300
    height: 380
    color: "transparent"

    property var overlayRef: null

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

        Rectangle {
            x: 8
            y: 8
            width: 10
            height: 1
            color: "#a855f7"
            opacity: 0.7
        }
        Rectangle {
            x: 8
            y: 8
            width: 1
            height: 10
            color: "#a855f7"
            opacity: 0.7
        }
        Rectangle {
            x: parent.width - 18
            y: parent.height - 9
            width: 10
            height: 1
            color: "#ec4899"
            opacity: 0.7
        }
        Rectangle {
            x: parent.width - 9
            y: parent.height - 18
            width: 1
            height: 10
            color: "#ec4899"
            opacity: 0.7
        }

        Rectangle {
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
                    position: 0.35
                    color: "#a855f7"
                }
                GradientStop {
                    position: 0.65
                    color: "#ec4899"
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        Repeater {
            model: Math.ceil(root.height / 4)
            delegate: Rectangle {
                x: 0
                y: index * 4
                width: root.width
                height: 2
                color: "#000000"
                opacity: 0.1
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 18
                Layout.bottomMargin: 0

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "lain.exe"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#c4b5d4"
                    }

                    RowLayout {
                        spacing: 5

                        Rectangle {
                            width: 5
                            height: 5
                            radius: 3
                            color: "#a855f7"

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 0.3
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

                Item {
                    Layout.fillWidth: true
                }

                // Clear button
                Text {
                    text: "clear"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.letterSpacing: 1
                    color: clearHover.containsMouse ? "#ec4899" : "#3d2a5e"
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: chatModel.clear()
                    }
                }
            }

            Item {
                height: 12
            }

            // ── Divider ───────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                height: 1
                color: "#2d1f4e"
                opacity: 0.6
            }

            Item {
                height: 8
            }

            // ── Messages ──────────────────────────────────────────────────────
            ListView {
                id: chatList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                clip: true
                spacing: 10
                model: AI.chatModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }

                onCountChanged: Qt.callLater(() => chatList.positionViewAtEnd())

                delegate: ColumnLayout {
                    width: chatList.width
                    spacing: 4

                    // Sender + time
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: sender
                            font.family: "JetBrains Mono"
                            font.pixelSize: 9
                            font.letterSpacing: 1
                            font.weight: Font.Bold
                            color: isUser ? "#ec4899" : "#a855f7"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: time
                            font.family: "JetBrains Mono"
                            font.pixelSize: 9
                            color: "#2d1f4e"
                        }
                    }

                    // Bubble
                    Rectangle {
                        Layout.fillWidth: !isUser
                        Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft
                        implicitWidth: isUser ? bubbleText.implicitWidth + 20 : parent.width
                        implicitHeight: bubbleText.implicitHeight + 16
                        radius: 6
                        color: isUser ? "#1c1030" : "#120a24"
                        border.color: isUser ? "#3d2270" : "#2d1f4e"
                        border.width: 1

                        // Accent left bar for ai messages
                        Rectangle {
                            visible: !isUser
                            x: 0
                            anchors.verticalCenter: parent.verticalCenter
                            width: 2
                            height: parent.height * 0.5
                            radius: 1
                            color: "#7c3aed"
                        }

                        Text {
                            id: bubbleText

                            property bool isThinking: body.length == 0

                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: isUser ? 10 : 14
                                rightMargin: 10
                            }

                            text: isThinking ? thinking : body
                            font.family: "JetBrains Mono"
                            font.pixelSize: isThinking ? 10 : 11
                            font.italic: isThinking
                            color: isThinking ? '#937fa7' : isUser ? "#c4b5d4" : "#b09cc4"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }
                }
            }

            Item {
                height: 8
            }

            // ── Divider ───────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                height: 1
                color: "#2d1f4e"
                opacity: 0.6
            }

            Item {
                height: 10
            }

            // ── Input ─────────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.bottomMargin: 18
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: "#120a24"
                    border.color: input.activeFocus ? "#7c3aed" : "#2d1f4e"
                    border.width: 1
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    TextInput {
                        id: input
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 10
                            rightMargin: 10
                        }
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        color: "#c4b5d4"
                        selectionColor: "#7c3aed"
                        clip: true

                        Keys.onEscapePressed: {
                            root.overlayRef.focusAnchor.forceActiveFocus();
                        }

                        Keys.onReturnPressed: sendMessage()

                        // Placeholder
                        Text {
                            anchors.fill: parent
                            text: ">> "
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            color: "#2d1f4e"
                            visible: input.text.length === 0 && !input.activeFocus
                        }
                    }
                }

                // Send button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 6
                    color: sendHover.containsMouse ? "#6d28d9" : "#7c3aed"
                    border.color: "#a855f7"
                    border.width: 1
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "↵"
                        font.pixelSize: 14
                        color: "#f0e6ff"
                    }

                    MouseArea {
                        id: sendHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sendMessage()
                    }
                }
            }
        }
    }

    function sendMessage() {
        let text = input.text.trim();

        if (!text)
            return;

        AI.chatModel.append({
            sender: "you",
            body: text,
            isUser: true,
            time: new Date().toLocaleDateString(Qt.locale("en_US"))
        });

        AI.chatModel.append({
            sender: "ai",
            body: "",
            thinking: "",
            isUser: false,
            time: new Date().toLocaleDateString(Qt.locale("en_US"))
        });

        let aiIndex = AI.chatModel.count - 1;

        AI.callAI(aiIndex, text);

        input.text = "";
    }

    Connections {
        target: AI

        function onChunkReceived(index, chunk, thinkingChunk) {
            let current = AI.chatModel.get(index).body;
            let currentThinking = AI.chatModel.get(index).thinking;

            AI.chatModel.setProperty(index, "body", current + chunk);
            AI.chatModel.setProperty(index, "thinking", currentThinking + thinkingChunk);
            AI.chatModel.setProperty(index, "time", new Date().toLocaleDateString(Qt.locale("en_US")))

            Qt.callLater(() => {
                chatList.positionViewAtEnd();
            });
        }
    }
}
