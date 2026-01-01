pragma ComponentBehavior: Bound

import Quickshell.Services.Notifications
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import Quickshell.Widgets
import QtQuick.Effects
import "../colors"

PanelWindow {
    id: notifications
    required property var modelData

    property ListModel popupNotificationModel: ListModel {}

    property NotificationServer notificationServer: NotificationServer {
        bodyHyperlinksSupported: true
        imageSupported: true
        actionsSupported: true
        bodyImagesSupported: true
        inlineReplySupported: true
        actionIconsSupported: true
        bodyMarkupSupported: true
        persistenceSupported: true

        onNotification: notification => {

            // Convert the incoming notification to a ListElement
            notifications.popupNotificationModel.append({
                appName: notification.appName,
                summary: notification.summary,
                body: notification.body || "No message",
                appIcon: notification.appIcon,
                image: notification.image,
                timestamp: notification.time || new Date().toLocaleString(),
                expire: notification.expireTimeout > 0 ? notification.expireTimeout : 5
            });

            console.log(notification.image); // Check how many notifications are in the model
        }
    }

    screen: modelData
    // mask: Region {}
    visible: repeater.count > 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Normal
    anchors {
        top: true
        // bottom: true
        right: true
    }

    implicitWidth: control.width
    implicitHeight: control.height
    Rectangle {
        width: control.implicitWidth
        height: control.implicitHeight

        color: Color.palette().base
        radius: 20

        Control {
            id: control
            padding: 10

            contentItem: ColumnLayout {
                id: column
                spacing: 5
                width: 500
                height: 20

                Repeater {
                    id: repeater
                    model: notifications.popupNotificationModel
                    delegate: Rectangle {
                        id: noti
                        required property var modelData
                        required property int index

                        property bool paused: false
                        property real elapsed: 0        // milliseconds
                        property real duration: noti.modelData.expire * 1000

                        width: 260
                        implicitHeight: content.implicitHeight + 16

                        radius: 14
                        color: Color.palette().surface0
                        border.color: Color.palette().crust
                        border.width: 1

                        opacity: 0

                        function removeSelf() {
                            for (var i = 0; i < notifications.popupNotificationModel.count; i++) {
                                var item = notifications.popupNotificationModel.get(i);
                                if (item.timestamp === noti.modelData.timestamp) { // unique identifier
                                    notifications.popupNotificationModel.remove(i, 1);  // stop after removing one item
                                    break;
                                }
                            }
                        }

                        MouseArea {
                            id: hoverMouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: noti.paused = true
                            onExited: noti.paused = false
                        }

                        // Entrance animation
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 180
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }

                        Component.onCompleted: {
                            opacity = 1;
                            y = 0;
                        }

                        Timer {
                            interval: 16    // ~60fps
                            running: true
                            repeat: true

                            onTriggered: {
                                if (!noti.paused) {
                                    noti.elapsed += interval;
                                    progressBar.value = noti.elapsed / noti.duration;

                                    if (progressBar.value >= 1.0) {
                                        fadeOut.start();
                                    }
                                }
                            }
                        }

                        SequentialAnimation {
                            id: fadeOut
                            PropertyAnimation {
                                target: noti
                                property: "opacity"
                                to: 0
                                duration: 160
                            }
                            ScriptAction {
                                script: noti.removeSelf()
                            }
                        }

                        ColumnLayout {
                            id: content
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 2

                            RowLayout {
                                spacing: 10
                                Layout.fillWidth: true

                                // App icon
                                Rectangle {
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    radius: 8
                                    color: Color.palette().surface1

                                    IconImage {
                                        id: sourceImage
                                        anchors.centerIn: parent
                                        width: 24
                                        height: 24
                                        source: Quickshell.iconPath(noti.modelData.appIcon)
                                    }

                                    MultiEffect {
                                        source: sourceImage
                                        anchors.fill: sourceImage
                                        colorization: 1
                                        brightness: 1
                                        colorizationColor: "white"
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: noti.modelData.summary
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: Color.palette().text
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: noti.modelData.body
                                        font.pixelSize: 12
                                        color: Color.palette().subtext0
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Image {
                                Layout.fillWidth: true
                                source: noti.modelData.image

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        Qt.openUrlExternally(noti.modelData.image.replace("image://icon/", ""));
                                    }
                                }
                            }

                            ProgressBar {
                                id: progressBar
                                Layout.fillWidth: true

                                implicitHeight: 3
                                value: 0
                            }
                        }
                    }
                }
            }
        }
    }
}
