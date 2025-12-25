import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell

ColumnLayout {
    // iterate over all registered tray items
    Repeater {
        model: SystemTray.items.values

        Item {
            id: item
            required property SystemTrayItem modelData
            // anchors.horizontalCenter: parent.horizontalCenter
            Layout.fillWidth: true
            implicitHeight: icon.height
            enabled: true

            Image {
                id: icon
                width: 15
                height: 15
                source: item.modelData.icon
                anchors.centerIn: parent
            }

            QsMenuAnchor {
                id: anchor
                anchor.item: item.parent
                menu: item.modelData.menu  // the tray item menu
            }

            MouseArea {
                width: icon.width
                height: icon.height
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onEntered: print("hover")

                onClicked: mouse => {
                    print("Clicked!");
                    if (mouse.button === Qt.LeftButton) {
                        item.modelData.activate();
                    } else if (mouse.button === Qt.RightButton && item.modelData.menu) {
                        anchor.open();  // show anchored menu
                    }
                }
            }
        }
    }
}
