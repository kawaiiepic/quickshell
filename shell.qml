//@ pragma UseQApplication
//@ pragma IconTheme Papirus

import "./modules/bar"
import "./modules/desktop"
import "./modules/controlcenter"
import "./modules/notifications"
import "./modules/ai"
import "./modules/lockscreen"
import "./modules/settings"

import Quickshell
import QtQuick

Scope {
    // Bar {}
    SingleBar {}
    Corners {}
    BottomBar {}
    BottomControl {}
    Desktop {}
    ControlCenter {}

    Lockscreen {}
    NotificationsPopup {}
    Settings {}
}
