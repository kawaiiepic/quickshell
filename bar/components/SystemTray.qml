import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell

Rectangle {
    width: parent.width
    height: childrenRect.height
    color: "lightgray"
    radius: 10
    ColumnLayout {
        spacing: 4
        // iterate over all registered tray items
        Repeater {
            model: SystemTray.items

            Item {
                id: item
                required property SystemTrayItem modelData
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: childrenRect.height

                Image {
                    width: 15
                    height: 15
                    source: item.modelData.icon
                }

                QsMenuAnchor {
                    id: anchor
                    anchor.item: item.parent
                    menu: item.modelData.menu  // the tray item menu
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            model.activate();
                        } else if (mouse.button === Qt.RightButton && model.menu) {
                            anchor.open();  // show anchored menu
                        }
                    }
                }
            }
        }
    }
}
