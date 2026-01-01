//@ pragma UseQApplication
//@ pragma IconTheme Papirus

import Quickshell // for PanelWindow
import QtQuick // for Text
import "./desktop"
import "./bar"
import "./notifications"
import "./controlcenter"

Scope {
    id: shell
    property ShellScreen mainMonitor: {
        return Quickshell.screens.find(screen => screen.x == 0);
    }
    // Shell
    Bar {
        screen: shell.mainMonitor
    }
    Desktop {}
    Notifications {
        screen: shell.mainMonitor
    }
    ControlCenter {}
}
