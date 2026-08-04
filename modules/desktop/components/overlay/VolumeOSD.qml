import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Wayland

import "../../../../theme"
import "../../../../ui"

Scope {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            root.shouldShowOsd = true;
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        BaseOverlay {
            color: "transparent"

            onRequestClose: {}

            visible: root.shouldShowOsd

            dismissable: false

            anchorRight: true
            verticalCenter: true

            StyledRect {
                parentWindow: parent
                pos: "right"

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                implicitHeight: 350
                implicitWidth: 80

                Column {
                    id: column
                    anchors.centerIn: parent
                    width: 10
                    spacing: 8

                    IconImage {
                        anchors.horizontalCenter: parent.horizontalCenter

                        implicitSize: 30
                        source: {
                            var vol = Pipewire.defaultAudioSink?.audio.volume;
                            if (vol <= 0.30) {
                                return Quickshell.iconPath("audio-volume-low");
                            } else if (vol > 0.30 && vol <= 0.80) {
                                return Quickshell.iconPath("audio-volume-medium");
                            } else {
                                Quickshell.iconPath("audio-volume-high");
                            }
                        }
                    }

                    Rectangle {
                        id: bar
                        implicitHeight: 200
                        implicitWidth: parent.width
                        radius: 20

                        property bool boost: Pipewire.defaultAudioSink?.audio.volume > 1.0
                        color: boost ? Colors.palette().text : "#50ffffff"

                        Rectangle {
                            implicitHeight: parent.height * (bar.boost ? Pipewire.defaultAudioSink?.audio.volume - 1 ?? 0 : Pipewire.defaultAudioSink?.audio.volume ?? 0)
                            implicitWidth: parent.width
                            anchors.bottom: parent.bottom
                            radius: parent.radius
                            color: bar.boost ? Colors.palette().pink : Colors.palette().text
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100) + "%"
                        color: Colors.palette().text
                    }
                }
            }
        }
    }
}
