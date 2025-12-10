pragma Singleton

import Quickshell
import QtQml
import Quickshell.Io

QtObject {
    property var workspaces: []
    property var windows: []

    property Process workspaceProcess: Process {
        running: true
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                // print(this.text);
                var data = JSON.parse(this.text);
                Niri.workspaces = data;
            }
        }
    }

    property Process windowProcess: Process {
        running: true
        command: ["niri", "msg", "--json", "windows"]
        stdout: StdioCollector {
            onStreamFinished: {
                var data = JSON.parse(this.text);
                // print(JSON.stringify(data))
                Niri.windows = data;
            }
        }
    }

    property Process eventStreamProcess: Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: message => {
                var data = JSON.parse(message);
                if (data.WorkspaceActivated) {
                    const id = data.WorkspaceActivated.id;
                    workspaces.forEach(ws => {
                        if (ws.id === id) {
                            ws.is_focused = true;
                        } else {
                            if (ws.is_focused) {
                                ws.is_focused = false;
                            }
                        }

                    });

                    workspaces = workspaces.slice();
                }
            }
        }
    }
    // Functions

    function workspaceFromIndex(index, output = "DP-2") {
        const match = workspaces.find(ws => ws.idx === index && ws.output === output);
        if (match !== undefined) {
            return match;
        }
    }

    function windowsInWorkspace(workspace) {
        const match = windows.filter(w => w.workspace_id === workspace.id);
        if (match !== undefined) {
            return match;
        }
    // print(match)
    }
}
