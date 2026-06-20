import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 300
    height: 300
    color: "transparent"

    property real uploadSpeed: 3.4
    property real downloadSpeed: 34.7
    property string localIp: "192.168.1.102"

    property var uploadHistory:   [0.5, 1.2, 0.8, 2.1, 1.4, 3.0, 2.2, 3.4]
    property var downloadHistory: [12.0, 18.5, 22.0, 15.3, 28.0, 31.2, 26.8, 34.7]

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        command: ["bash", "-c",
            "cat /proc/net/dev | awk '/^\\s*(eth0|wlan0|enp|wlp)/ {print $2, $10}' | head -1"
        ]
        property real lastRx: 0
        property real lastTx: 0
        property bool firstRun: true

        // onRunningChanged: {
        //     if (!running) {
        //         var parts = stdout.trim().split(" ")
        //         if (parts.length >= 2) {
        //             var rx = parseFloat(parts[0])
        //             var tx = parseFloat(parts[1])
        //             if (!firstRun) {
        //                 var dlKb = (rx - lastRx) / 2 / 1024
        //                 var ulKb = (tx - lastTx) / 2 / 1024
        //                 root.downloadSpeed = Math.max(0, dlKb)
        //                 root.uploadSpeed   = Math.max(0, ulKb)

        //                 var dh = root.downloadHistory.slice()
        //                 dh.push(root.downloadSpeed)
        //                 if (dh.length > 12) dh.shift()
        //                 root.downloadHistory = dh

        //                 var uh = root.uploadHistory.slice()
        //                 uh.push(root.uploadSpeed)
        //                 if (uh.length > 12) uh.shift()
        //                 root.uploadHistory = uh
        //             }
        //             lastRx = rx
        //             lastTx = tx
        //             firstRun = false
        //         }
        //     }
        // }
    }

    Process {
        id: ipProc
        command: ["bash", "-c", "hostname -I | awk '{print $1}'"]
        running: true
        onRunningChanged: {
            if (!running && exitCode === 0) {
                var ip = stdout.trim()
                if (ip.length > 0) root.localIp = ip
            }
        }
    }

    component Sparkline: Canvas {
        id: spark
        property var data: []
        property color lineColor: "#a855f7"

        onDataChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (data.length < 2) return

            var maxVal = Math.max.apply(null, data)
            if (maxVal === 0) maxVal = 1

            ctx.beginPath()
            ctx.strokeStyle = lineColor
            ctx.lineWidth = 1.2
            ctx.lineJoin = "round"
            ctx.lineCap  = "round"

            for (var i = 0; i < data.length; i++) {
                var x = (i / (data.length - 1)) * width
                var y = height - (data[i] / maxVal) * (height - 2) - 1
                if (i === 0) ctx.moveTo(x, y)
                else         ctx.lineTo(x, y)
            }
            ctx.stroke()

            ctx.lineTo((data.length - 1) / (data.length - 1) * width, height)
            ctx.lineTo(0, height)
            ctx.closePath()
            var grad = ctx.createLinearGradient(0, 0, 0, height)
            grad.addColorStop(0, lineColor.toString().replace(")", ", 0.25)").replace("rgb", "rgba"))
            grad.addColorStop(1, lineColor.toString().replace(")", ", 0.0)").replace("rgb", "rgba"))
            ctx.fillStyle = grad
            ctx.fill()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#09080f"
        radius: 10
        border.color: "#2d1f4e"
        border.width: 1
        clip: true

        Rectangle { anchors.fill: parent; color: "#1a0533"; opacity: 0.35; radius: 10 }

        Repeater {
            model: Math.ceil(root.height / 4)
            delegate: Rectangle {
                x: 0; y: index * 4; width: root.width; height: 2
                color: "#000000"; opacity: 0.07; z: 2
            }
        }

        // Corner brackets
        Rectangle { x: 8; y: 8; width: 10; height: 1; color: "#a855f7"; opacity: 0.8; z: 3 }
        Rectangle { x: 8; y: 8; width: 1; height: 10; color: "#a855f7"; opacity: 0.8; z: 3 }
        Rectangle { x: parent.width - 18; y: 8; width: 10; height: 1; color: "#a855f7"; opacity: 0.8; z: 3 }
        Rectangle { x: parent.width - 9;  y: 8; width: 1;  height: 10; color: "#a855f7"; opacity: 0.8; z: 3 }
        Rectangle { x: 8; y: parent.height - 9;  width: 10; height: 1; color: "#ec4899"; opacity: 0.8; z: 3 }
        Rectangle { x: 8; y: parent.height - 18; width: 1;  height: 10; color: "#ec4899"; opacity: 0.8; z: 3 }
        Rectangle { x: parent.width - 18; y: parent.height - 9;  width: 10; height: 1; color: "#ec4899"; opacity: 0.8; z: 3 }
        Rectangle { x: parent.width - 9;  y: parent.height - 18; width: 1;  height: 10; color: "#ec4899"; opacity: 0.8; z: 3 }

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: "#a855f7" }
                GradientStop { position: 0.7; color: "#ec4899" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0
            z: 4

            Text {
                text: "NETWORK"
                font.family: "JetBrains Mono"
                font.pixelSize: 8
                font.letterSpacing: 2
                color: "#3d2a5e"
                Layout.bottomMargin: 12
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 10
                spacing: 8

                ColumnLayout {
                    spacing: 3
                    Layout.preferredWidth: 60

                    Text {
                        text: "UP"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 8
                        font.letterSpacing: 1.5
                        color: "#3d2a5e"
                    }

                    Text {
                        text: root.uploadSpeed.toFixed(1) + " KB/s"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        color: "#c4b5d4"
                    }
                }

                Sparkline {
                    Layout.fillWidth: true
                    height: 28
                    data: root.uploadHistory
                    lineColor: "#a855f7"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2d1f4e"
                opacity: 0.5
                Layout.bottomMargin: 10
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 10
                spacing: 8

                ColumnLayout {
                    spacing: 3
                    Layout.preferredWidth: 60

                    Text {
                        text: "DOWN"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 8
                        font.letterSpacing: 1.5
                        color: "#3d2a5e"
                    }

                    Text {
                        text: root.downloadSpeed.toFixed(1) + " KB/s"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        color: "#c4b5d4"
                    }
                }

                Sparkline {
                    Layout.fillWidth: true
                    height: 28
                    data: root.downloadHistory
                    lineColor: "#ec4899"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2d1f4e"
                opacity: 0.5
                Layout.bottomMargin: 10
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "LOCAL IP"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 8
                    font.letterSpacing: 1.5
                    color: "#3d2a5e"
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.localIp
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    color: "#c4b5d4"
                }
            }
        }
    }
}