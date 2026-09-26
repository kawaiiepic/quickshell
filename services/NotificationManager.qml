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

        onNotification: n => {
            n.tracked = true;

            var item = {
                id: n.id,
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                appIcon: n.appIcon,
                image: n.image,
                actions: n.actions,
                expireTimeout: n.expireTimeout,
                hints: n.hints
            };

            if (!root.doNotDisturb) {
                if (!n.lastGeneration)
                    root.popupNotifications.append(item);
                root.historyNotifications.append(item);
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
        if (popupNotifications.count > 0)
            popupNotifications.remove(0);
    }

    function clearHistory() {
        historyNotifications.clear();
        popupNotifications.clear();
        urgent = false;
    }

    function invokeAction(id, actionIdentifier) {
        var notification = root.notifications[id];
        if (!notification)
            return;
        for (const action of notification.actions) {
            if (action.identifier == actionIdentifier)
                action.invoke();
        }
    }
}
