pragma Singleton

import QtCore
import QtQuick
import Quickshell

Singleton {
    id: root

    property Settings settings: Settings {
        id: settings
        category: "settings"
        location: Paths.settings

        property bool showDoneTasks: true
        property int maxTasks: 30
        property int fontSize: 18

        property bool detailedWorkspaces: true
    }

    property Settings apps: Settings {

        property var favouriteApps: []

        category: "favApps"
        location: Paths.settings
    }
}
