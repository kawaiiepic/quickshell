pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    property var bars: []

    Process {
        id: cava
        command: ["cava", "-p", "/home/mia/cava"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (!line || !line.trim().length)
                    return;
                root.bars = line.trim().split(";").map(Number);
            }
        }
    }
}
