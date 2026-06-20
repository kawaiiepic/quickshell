import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 300
    height: 380
    color: "transparent"

    QtObject {
        id: sys
        property real cpu:  16
        property real ram:  27
        property real disk: 72
        property real temp: 55

        property var processes: [
            { name: "Hyprland",    cpu: 2.1 },
            { name: "quickshell", cpu: 1.7 },
            { name: "firefox",    cpu: 1.3 },
            { name: "Discord",    cpu: 0.8 },
            { name: "spotify",    cpu: 0.6 },
        ]
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            sys.cpu  = Math.round(12 + Math.random() * 10)
            sys.temp = Math.round(52 + Math.random() * 6)
        }
    }

    ListModel {
        id: gaugeModel
        ListElement { label: "CPU";  unit: "%";  arcColor: "#a855f7" }
        ListElement { label: "RAM";  unit: "%";  arcColor: "#7c3aed" }
        ListElement { label: "DISK"; unit: "%";  arcColor: "#ec4899" }
        ListElement { label: "TEMP"; unit: "°C"; arcColor: "#c084fc" }
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

            Text {
                text: "SYSTEM MONITOR"
                font.family: "JetBrains Mono"
                font.pixelSize: 9
                font.letterSpacing: 3
                font.weight: Font.Medium
                color: "#4a3570"
            }

            Item { Layout.preferredHeight: 16 }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: gaugeModel

                    delegate: Item {
                        Layout.fillWidth: true
                        height: 72

                        property real gaugeValue: {
                            if (label === "CPU")  return sys.cpu
                            if (label === "RAM")  return sys.ram
                            if (label === "DISK") return sys.disk
                            if (label === "TEMP") return sys.temp
                            return 0
                        }

                        Canvas {
                            id: arc
                            anchors.centerIn: parent
                            width: 56; height: 56

                            property real animatedValue: parent.gaugeValue

                            Behavior on animatedValue {
                                NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
                            }

                            onAnimatedValueChanged: requestPaint()
                            Component.onCompleted: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)

                                var cx    = width / 2
                                var cy    = height / 2
                                var r     = 22
                                var lw    = 4
                                var start = Math.PI * 0.75
                                var end   = Math.PI * 2.25

                                ctx.beginPath()
                                ctx.arc(cx, cy, r, start, end)
                                ctx.strokeStyle = "#1c1030"
                                ctx.lineWidth   = lw
                                ctx.lineCap     = "round"
                                ctx.stroke()

                                var filled = start + (end - start) * (animatedValue / 100)
                                ctx.beginPath()
                                ctx.arc(cx, cy, r, start, filled)
                                ctx.strokeStyle = arcColor
                                ctx.lineWidth   = lw
                                ctx.lineCap     = "round"
                                ctx.stroke()
                            }

                            Text {
                                anchors.centerIn: parent
                                text: Math.round(arc.animatedValue)
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: arcColor
                            }
                        }

                        Text {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                            }
                            text: label
                            font.family: "JetBrains Mono"
                            font.pixelSize: 9
                            font.letterSpacing: 1.5
                            color: "#4a3570"
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 18 }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2d1f4e"
                opacity: 0.6
            }

            Item { Layout.preferredHeight: 14 }

            Text {
                text: "PROCESSES"
                font.family: "JetBrains Mono"
                font.pixelSize: 9
                font.letterSpacing: 3
                font.weight: Font.Medium
                color: "#4a3570"
            }

            Item { Layout.preferredHeight: 10 }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: sys.processes

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            width: 4; height: 4; radius: 2
                            color: index === 0 ? "#a855f7" :
                                   index === 1 ? "#7c3aed" :
                                   index === 2 ? "#ec4899" :
                                   index === 3 ? "#c084fc" : "#3d2a5e"
                        }

                        Text {
                            text: modelData.name
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            color: "#c4b5d4"
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 60; height: 2; radius: 1
                            color: "#1c1030"

                            Rectangle {
                                width: parent.width * (modelData.cpu / 3.0)
                                height: parent.height; radius: 1
                                color: index === 0 ? "#a855f7" :
                                       index === 1 ? "#7c3aed" :
                                       index === 2 ? "#ec4899" :
                                       index === 3 ? "#c084fc" : "#3d2a5e"
                            }
                        }

                        Text {
                            text: modelData.cpu.toFixed(1) + "%"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            color: "#4a3570"
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}