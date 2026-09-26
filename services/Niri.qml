pragma Singleton
import QtQuick
import Quickshell

// Compatibility shim. The shell used to talk to niri through qml-niri.
// On Hyprland, Compositor exposes the same helpers the bar already calls.
Singleton {
    readonly property var workspaces: Compositor.workspaces
    readonly property var windows: Compositor.toplevels
    readonly property var focusedWindow: Compositor.focusedWindow

    function focusWorkspace(id) {
        Compositor.focusWorkspace(id);
    }

    function focusWindow(win) {
        Compositor.focusWindow(win);
    }

    function windowFromName(name) {
        return Compositor.windowFromName(name);
    }
}
