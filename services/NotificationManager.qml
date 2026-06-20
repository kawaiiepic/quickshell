pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property Process process: Process {}

    property ListModel popupNotifications: ListModel {}
    property ListModel historyNotifications: ListModel {}
    property var notifications: ({})

    property bool doNotDisturb: false
    property int maxVisible: 5
    property int maxHistory: 100

    property bool urgent: false

    property var server: NotificationServer {
        keepOnReload: true
        bodyHyperlinksSupported: true
        imageSupported: true
        actionsSupported: true
        bodyImagesSupported: true
        inlineReplySupported: true
        bodyMarkupSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;

            print("Notification:", notification.id);
            print("Notifcation title:", notification.summary)

            // root.notifications[notification.id] = notification;

            if (!root.doNotDisturb) {

                if (!notification.lastGeneration) {
                    root.popupNotifications.append(notification);
                }

                root.historyNotifications.append(notification);

                root.playNotificationSound();
            }
        }
    }

    function sendNotification(icon, title, message) {
        process.command = ["notify-send", "-i", icon, title, message];
        process.running = true;
    }

    function playNotificationSound() {
        Sound.playSound("message", -5);
    }

    function dismissNotification() {
    }

    function invokeAction(id, actionIdentifier) {
        var notification = root.notifications[id];
        for (const action of notification.actions) {
            if (action.identifier == actionIdentifier) {
                action.invoke();
            }
        }
    }
}
