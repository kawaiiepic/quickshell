pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property var process: Process {}

    function playSound(name, volume=1.0) {
        process.command = ["canberra-gtk-play", "-i", name, "-V", volume];
        process.running = true;
    }
}
