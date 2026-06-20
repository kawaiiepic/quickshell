pragma Singleton
import QtQml
import QtQuick
import Niri

Niri {
    id: niri
    Component.onCompleted: connect()

    onConnected: console.log("Connected to niri")

    onErrorOccurred: function (error) {
        console.error("Error:", error);
    }

    onRawEventReceived: function (event) {
        if(event.WorkspaceActivated){
            // NotificationManager.sendNotification("", "Worksapce changed", niri.workspaces.get(niri.workspaces.indexOfId(event.WorkspaceActivated.id)).name)
        }

    }
}
