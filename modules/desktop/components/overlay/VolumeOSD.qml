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

    property bool init: false

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            if (!root.init) {
                init = true;
            } else {
                root.shouldShowOsd = true;
                hideTimer.restart();
            }
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

            anchors {
                right: true
            }

            margins {
                right: 4
            }

            implicitHeight: 500
            implicitWidth: 120

            StyledRect {
                parentWindow: parent
                pos: "right"

                implicitHeight: 500
                implicitWidth: 120

                Rectangle {
                    implicitHeight: 200
                    implicitWidth: 10
                    radius: 20
                }

                // Rectangle {
                //     id: bar
                //     Layout.fillWidth: true

                //     implicitWidth: 10
                //     radius: 20

                //     property bool boost: Pipewire.defaultAudioSink?.audio.volume > 1.0
                //     color: boost ? Colors.palette().text : "#50ffffff"

                //     Rectangle {
                //         implicitHeight: parent.height * (bar.boost ? Pipewire.defaultAudioSink?.audio.volume - 1 ?? 0 : Pipewire.defaultAudioSink?.audio.volume ?? 0)
                //         radius: parent.radius
                //         color: bar.boost ? Colors.palette().pink : Colors.palette().text
                //     }
                // }
            }

            // implicitHeight: 200
            // implicitWidth: 200
        }

        // PanelWindow {

        //     anchors.bottom: true
        //     margins.bottom: screen.height / 9
        //     exclusiveZone: 0

        //     implicitWidth: 400
        //     implicitHeight: 50
        //     color: "transparent"

        //     WlrLayershell.layer: WlrLayer.Overlay
        //     mask: Region {}

        //     Rectangle {
        //         anchors.fill: parent
        //         radius: height / 2
        //         color: Colors.palette().surface0

        //         ColumnLayout {
        //             anchors {
        //                 fill: parent
        //                 leftMargin: 10
        //                 rightMargin: 15
        //             }

        //             Text {
        //                 text: Pipewire.defaultAudioSink?.nickname
        //                 color: Colors.palette().text
        //                 horizontalAlignment: Text.AlignHCenter
        //                 font.pixelSize: 14
        //                 Layout.fillWidth: true
        //                 Layout.preferredHeight: 1
        //             }

        //             RowLayout {

        //                 IconImage {
        //                     implicitSize: 30
        //                     source: {
        //                         var vol = Pipewire.defaultAudioSink?.audio.volume;
        //                         if (vol <= 0.30) {
        //                             return Quickshell.iconPath("audio-volume-low");
        //                         } else if (vol > 0.30 && vol <= 0.80) {
        //                             return Quickshell.iconPath("audio-volume-medium");
        //                         } else {
        //                             Quickshell.iconPath("audio-volume-high");
        //                         }
        //                     }
        //                 }

        //                 // ColumnLayout {

        //                 Rectangle {
        //                     id: bar
        //                     Layout.fillWidth: true

        //                     implicitHeight: 10
        //                     radius: 20

        //                     property bool boost: Pipewire.defaultAudioSink?.audio.volume > 1.1
        //                     color: boost ? Colors.palette().text : "#50ffffff"

        //                     Rectangle {
        //                         anchors {
        //                             left: parent.left
        //                             top: parent.top
        //                             bottom: parent.bottom
        //                         }

        //                         implicitWidth: parent.width * (bar.boost ? Pipewire.defaultAudioSink?.audio.volume - 1 ?? 0 : Pipewire.defaultAudioSink?.audio.volume ?? 0)
        //                         radius: parent.radius
        //                         color: bar.boost ? Colors.palette().pink : Colors.palette().text
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }
    }
}
