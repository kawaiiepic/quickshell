pragma Singleton

import Quickshell
import QtQml
import Quickshell.Io

QtObject {
    property var workspaces : []

    property Process workspaceProcess: Process {
        running: true
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                var data = JSON.parse(this.text);
                // get the active workspace
                print(JSON.stringify(data))
                workspaces = data
            }
        }
    }

    Component.onCompleted: {}
}
