import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../../ui"
import "../../../theme"
import "../../../services"

Text {
    id: root
    text: "\u23FB"

    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
    color: popup.show ? Colors.palette().red : Colors.palette().text

    BasePopup {
        id: popup
        parentItem: root

        ColumnLayout {
            PopupButton {
                iconName: "system-lock-screen"
                text: "Lock"
                clicked: () => Compositor.lock()
            }

            PopupButton {
                iconName: "system-log-out"
                text: "Logout"
                clicked: () => Compositor.logout()
            }

            PopupButton {
                iconName: "system-suspend"
                text: "Suspend"
                clicked: () => Compositor.suspend()
            }

            PopupButton {
                iconName: "system-reboot"
                text: "Reboot"
                clicked: () => Compositor.reboot()
            }

            PopupButton {
                iconName: "system-shutdown"
                text: "Shutdown"
                clicked: () => Compositor.shutdown()
            }
        }
    }
}
