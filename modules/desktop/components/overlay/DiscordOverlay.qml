pragma ComponentBehavior: Bound
import Quickshell
import QtQuick.Layouts

import QtQuick
import Quickshell.Wayland
import QtWebSockets
import Quickshell.Widgets
import QtQuick.Controls

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData
            mask: Region {}

            anchors {
                left: true
                top: true
            }

            margins {
                left: 10
                top: 5
            }

            implicitWidth: 500
            implicitHeight: 500

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay

            ListModel {
                id: users
            }

            property bool streamerMode: false

            WebSocketServer {
                id: server
                listen: true
                port: 6888

                onClientConnected: webSocket => {
                    console.log("Client connected");

                    // Connect to message signals for the new client
                    webSocket.onTextMessageReceived.connect(message => {
                        console.log("Server received:", message);
                        var ping = JSON.parse(message);

                        switch (ping.cmd) {
                        case "CHANNEL_JOINED":
                            {
                                for (var i = 0; i < ping.states.length; i++) {
                                    var state = ping.states[i];
                                    users.append({
                                        "userId": state.userId,
                                        "username": state.username,
                                        "avatarUrl": state.avatarUrl,
                                        "channelId": state.channelId,
                                        "deaf": state.deaf,
                                        "mute": state.mute,
                                        "streaming": state.streaming,
                                        "speaking": state.speaking
                                    });
                                }
                                break;
                            }
                        case "CHANNEL_LEFT":
                            {
                                users.clear();
                                break;
                            }
                        case "STREAMER_MODE":
                            {
                                root.streamerMode = ping.enabled;
                                break;
                            }
                        case "VOICE_STATE_UPDATE":
                            {
                                for (var i = 0; i < users.count; i++) {
                                    var state = ping.state;
                                    var user = users.get(i);

                                    if (users.get(i).userId === state.userId) {
                                        users.set(i, {
                                            userId: state.userId,
                                            username: state.username ?? user.username,
                                            avatarUrl: state.avatarUrl ?? user.avatarUrl,
                                            channelId: state.channelId ?? user.channelId,
                                            deaf: state.deaf ?? user.deaf,
                                            mute: state.mute ?? user.mute,
                                            streaming: state.streaming ?? user.streaming,
                                            speaking: state.speaking ?? user.speaking
                                        });
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                        // Echo the message back to the client
                        webSocket.sendTextMessage("Echo: " + message);
                    });

                    webSocket.onStatusChanged.connect(status => {
                        if (status === WebSocket.Closed) {
                            console.log("Client disconnected");
                        }
                    });
                }

                onErrorStringChanged: {
                    console.log("Server error:", errorString);
                }

                Component.onCompleted: {
                    console.log("Server started at:", server.url);
                }

                Component.onDestruction: {
                    console.log("Closing WebSocket server");
                    server.listen = false;
                }
            }

            ColumnLayout {
                spacing: 5

                Repeater {
                    model: users

                    Item {
                        id: user

                        required property string userId
                        required property string username
                        required property string avatarUrl
                        required property string channelId
                        required property bool deaf
                        required property bool mute
                        required property bool streaming
                        required property bool speaking

                        property double a: 0.5

                        height: childrenRect.height
                        width: childrenRect.width

                        RowLayout {
                            opacity: user.speaking ? 0.8 : 0.4

                            ClippingRectangle {
                                implicitHeight: 30
                                implicitWidth: 30
                                radius: 24
                                border.width: user.speaking ? 2 : 0
                                border.color: Color.palette().red

                                AnimatedImage {
                                    anchors.fill: parent
                                    source: `https://cdn.discordapp.com/avatars/${user.userId}/${user.avatarUrl}.png`
                                }
                            }

                            Rectangle {
                                visible: !root.streamerMode
                                color: Color.palette().surface0
                                implicitWidth: childrenRect.width
                                implicitHeight: childrenRect.height
                                radius: 8

                                Control {
                                    id: control
                                    padding: 2
                                    leftPadding: 5
                                    rightPadding: 5

                                    contentItem: RowLayout {
                                        spacing: 8
                                        Text {
                                            text: user.username
                                            font.pixelSize: 15
                                            color: Color.palette().subtext1
                                        }

                                        IconImage {
                                            visible: user.deaf
                                            implicitSize: 15
                                            source: "file:" + Quickshell.shellPath("assets/icons/deafened.svg")
                                        }

                                        IconImage {
                                            visible: user.mute
                                            implicitSize: 15
                                            source: "file:" + Quickshell.shellPath("assets/icons/muted.svg")
                                        }

                                        IconImage {
                                            visible: user.streaming
                                            implicitSize: 15
                                            source: "file:" + Quickshell.shellPath("assets/icons/streaming.svg")
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
