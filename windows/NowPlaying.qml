import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 300
    height: 290
    color: "transparent"

    QtObject {
        id: player
        property string title: "Rain on Tokyo"
        property string artist: "NIGHT TEMPO"
        property string album: "Neo Tokyo"
        property int elapsed: 84
        property int total: 267
        property bool playing: true

        function elapsedStr() {
            return fmt(elapsed);
        }
        function totalStr() {
            return fmt(total);
        }
        function fmt(s) {
            var m = Math.floor(s / 60);
            var sec = s % 60;
            return m + ":" + (sec < 10 ? "0" : "") + sec;
        }
    }

    Timer {
        interval: 1000
        running: player.playing
        repeat: true
        onTriggered: {
            if (player.elapsed < player.total)
                player.elapsed++;
            else {
                player.elapsed = 0;
                player.playing = false;
            }
        }
    }

    // ── Root card ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#09080f"
        radius: 10
        border.color: "#2d1f4e"
        border.width: 1

        // Top neon line accent
        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 1
            radius: 1
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

        // Corner bracket TL
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
        // Corner bracket BR
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

        ColumnLayout {
            anchors {
                fill: parent
                margins: 18
            }
            spacing: 0

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "NOW PLAYING"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.letterSpacing: 3
                    font.weight: Font.Medium
                    color: "#4a3570"
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    width: 18
                    height: 16

                    Row {
                        anchors.bottom: parent.bottom
                        spacing: 2

                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                width: 3
                                radius: 1
                                color: "#a855f7"
                                property real base: [10, 16, 8, 13][index]
                                height: base
                                anchors.bottom: parent?.bottom

                                SequentialAnimation on height {
                                    running: player.playing
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        to: base * 0.35
                                        duration: 260 + index * 70
                                        easing.type: Easing.InOutSine
                                    }
                                    NumberAnimation {
                                        to: base
                                        duration: 260 + index * 70
                                        easing.type: Easing.InOutSine
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.preferredHeight: 16
            }

            // ── Art + meta ────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 58
                    height: 58
                    radius: 6
                    color: "#120a24"
                    border.color: "#3d2270"
                    border.width: 1
                    clip: true

                    // Purple glow from bottom
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 1.2
                        height: parent.height * 0.6
                        radius: width / 2
                        color: "#7c3aed"
                        opacity: 0.2
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        font.pixelSize: 24
                        color: "#c084fc"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: player.title
                        font.family: "JetBrains Mono"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#f0e6ff"
                        elide: Text.ElideRight
                        // letterSpacing: 0.3
                    }

                    Text {
                        text: player.artist
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        color: "#ec4899"
                        font.letterSpacing: 2
                        font.weight: Font.Medium
                    }

                    Text {
                        text: player.album
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        color: "#3d2a5e"
                        font.letterSpacing: 1
                    }
                }
            }

            Item {
                Layout.preferredHeight: 18
            }

            // ── Progress ──────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 7

                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    radius: 1
                    color: "#1c1030"
                    border.color: "#2d1f4e"
                    border.width: 0.5

                    // Filled portion — purple→pink gradient via two rects
                    Rectangle {
                        id: fillBar
                        width: parent.width * (player.elapsed / Math.max(player.total, 1))
                        height: parent.height
                        radius: 1
                        color: "#a855f7"   // single color; gradient needs ShaderEffect or layer

                        Behavior on width {
                            NumberAnimation {
                                duration: 900
                                easing.type: Easing.Linear
                            }
                        }

                        // Glowing dot
                        Rectangle {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: -5
                            }
                            width: 10
                            height: 10
                            radius: 5
                            color: "#ec4899"

                            layer.enabled: true
                            layer.effect: null  // swap for a real glow layer if Quickshell supports it
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        onClicked: m => {
                            player.elapsed = Math.round((m.x / parent.width) * player.total);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: player.elapsedStr()
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        color: "#3d2a5e"
                        font.letterSpacing: 1
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        text: player.totalStr()
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        color: "#3d2a5e"
                        font.letterSpacing: 1
                    }
                }
            }

            Item {
                Layout.preferredHeight: 14
            }

            // ── Controls ──────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 34
                    height: 34
                    radius: 17
                    color: prevM.containsMouse ? "#1c1030" : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "⏮"
                        font.pixelSize: 13
                        color: prevM.containsMouse ? "#c084fc" : "#5b3a8a"
                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }
                    MouseArea {
                        id: prevM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: player.elapsed = 0
                    }
                }

                Item {
                    Layout.preferredWidth: 10
                }

                Rectangle {
                    width: 46
                    height: 46
                    radius: 23
                    color: playM.containsMouse ? "#6d28d9" : "#7c3aed"
                    border.color: "#a855f7"
                    border.width: 1
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: player.playing ? "⏸" : "▶"
                        font.pixelSize: 15
                        color: "#f0e6ff"
                    }
                    MouseArea {
                        id: playM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: player.playing = !player.playing
                    }
                }

                Item {
                    Layout.preferredWidth: 10
                }

                Rectangle {
                    width: 34
                    height: 34
                    radius: 17
                    color: nextM.containsMouse ? "#1c1030" : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "⏭"
                        font.pixelSize: 13
                        color: nextM.containsMouse ? "#c084fc" : "#5b3a8a"
                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }
                    MouseArea {
                        id: nextM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            player.elapsed = 0;
                            player.playing = true;
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }

    // ── Scanline overlay ─────────────────────────────────────────────────────
    ShaderEffect {
        anchors.fill: parent
        fragmentShader: "../assets/shaders/scanlines.frag.qsb"
        enabled: true
    }
}
