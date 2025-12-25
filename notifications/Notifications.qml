pragma ComponentBehavior: Bound

import Quickshell.Services.Notifications
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import "../colors"

Scope {
    id: notifications

    property ListModel popupNotificationModel: ListModel {}

    property NotificationServer notificationServer: NotificationServer {
        onNotification: notification => {
            console.log(notification.expireTimeout);  // Log the app name for debugging

            // Convert the incoming notification to a ListElement
            notifications.popupNotificationModel.append({
                appName: notification.appName,
                message: notification.body || "No message",
                timestamp: notification.time || new Date().toLocaleString(),
                expire: notification.expireTimeout > 0 ? notification.expireTimeout : 5
            });

            console.log(notifications.popupNotificationModel.count); // Check how many notifications are in the model
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: rootNotification
            required property var modelData

            screen: modelData
            mask: Region {}
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Normal
            anchors {
                top: true
                bottom: true
                right: true
            }

            implicitWidth: 300

            ColumnLayout {
                spacing: 5
                width: 200
                height: 20

                Repeater {
                    id: repeater
                    model: notifications.popupNotificationModel
                    delegate: Rectangle {
                        id: noti
                        width: parent.width
                        height: 50
                        color: "pink"
                        border.color: "blue"
                        radius: 10
                        required property var modelData

                        Timer {
                            // 1000 milliseconds is 1 second
                            interval: 1000

                            // start the timer immediately
                            running: true

                            // run the timer again when it ends
                            repeat: true

                            // when the timer is triggered, set the running property of the
                            // process to true, which reruns it if stopped.
                            onTriggered: {
                                progressBar.value = barTimer.elapsed() / noti.modelData.expire;
                            }
                        }

                        ElapsedTimer {
                            id: barTimer
                        }

                        ColumnLayout {

                            Text {
                                text: noti.modelData.message  // Display the message from the notification object
                                color: "black"
                                font.pixelSize: 14
                            }

                            ProgressBar {
                                id: progressBar
                                value: barTimer.elapsed()
                                onValueChanged: {
                                    if (value >= 1.0) {
                                        notifications.popupNotificationModel.remove(noti.modelData);
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
