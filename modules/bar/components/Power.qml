import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../../ui"
import "../../../theme"

Text {
    id: root
    text: "⏻"


    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
    color: popup.show ? Colors.palette().red : Colors.palette().text

    BasePopup {
        id: popup

        parentItem: root

        ColumnLayout {
            PopupButton {
                iconName: "lock"
                text: "Lock"
                clicked: {}
            }

            PopupButton {
                iconName: "exit"
                text: "Logout"
                clicked: {}
            }

            PopupButton {
                iconName: "exit"
                text: "Suspend"
                clicked: {}
            }

            PopupButton {
                iconName: "exit"
                text: "Reboot"
                clicked: {}
            }

            PopupButton {
                iconName: "exit"
                text: "Shutdown"
                clicked: {}
            }
        }
    }
}
