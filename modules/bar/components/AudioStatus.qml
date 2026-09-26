pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

import "../../../ui"
import "../../../theme"

Text {
    id: root
    property ShellScreen screen

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var audio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    readonly property bool muted: audio ? audio.muted : false
    readonly property real vol: audio ? audio.volume : 0

    text: {
        if (!audio || muted || vol <= 0.001)
            return "mute";
        return Math.round(vol * 100) + "%";
    }

    color: popup.show ? Colors.palette().pink : Colors.palette().text
    font.pixelSize: 11
    horizontalAlignment: Text.AlignHCenter

    WheelHandler {
        onWheel: event => {
            if (!root.audio)
                return;
            const delta = event.angleDelta.y > 0 ? 0.05 : -0.05;
            root.audio.volume = Math.max(0, Math.min(1.5, root.vol + delta));
        }
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: {
            if (root.audio)
                root.audio.muted = !root.audio.muted;
        }
    }

    BasePopup {
        id: popup
        parentItem: root
        screen: root.screen

        ColumnLayout {
            spacing: 10
            width: 260

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.muted ? "Muted" : Math.round(root.vol * 100) + "%"
                    color: Colors.palette().text
                    Layout.fillWidth: true
                }
                Switch {
                    checked: root.muted
                    onToggled: {
                        if (root.audio)
                            root.audio.muted = checked;
                    }
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0
                to: 1.5
                value: root.vol
                onMoved: {
                    if (root.audio)
                        root.audio.volume = value;
                }
            }

            Text { text: "Output"; color: Colors.palette().subtext0; font.pixelSize: 11 }

            Repeater {
                model: Pipewire.nodes
                delegate: RadioButton {
                    id: sinkBtn
                    required property var modelData
                    visible: modelData && modelData.isSink && !modelData.isStream
                    checked: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.name === modelData.name
                    text: modelData.nickname || modelData.description || modelData.name
                    contentItem: Text {
                        text: sinkBtn.text
                        color: Colors.palette().text
                        font.pixelSize: 12
                        leftPadding: sinkBtn.indicator.width + 8
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }
    }
}
