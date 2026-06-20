pragma Singleton

import QtCore

Settings {
    id: settings
    category: "settings"
    location: Paths.settings

    property bool showDoneTasks: true
    property int maxTasks: 30
    property int fontSize: 18

    property bool detailedWorkspaces: true
}
