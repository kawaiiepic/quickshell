pragma ComponentBehavior: Bound
import QtQuick.Controls
import QtQuick
import QtQuick.Layouts
import "../theme"

Menu {
    id: menu

    leftPadding: 5
    rightPadding: 5
    topPadding: 5
    bottomPadding: 5

    background: Rectangle {
        id: background
        implicitWidth: 300
        radius: 12
        color: Colors.palette().surface0
        border.width: 1
        border.color: Colors.palette().crust
    }

    delegate: MenuItem {
        id: menuItem
        implicitHeight: 40

        arrow: Canvas {
            x: parent.width - width
            implicitWidth: 40
            implicitHeight: 40
            visible: menuItem.subMenu
            onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = menuItem.highlighted ? Colors.palette().subtext0 : Colors.palette().text;
                ctx.moveTo(15, 15);
                ctx.lineTo(width - 15, height / 2);
                ctx.lineTo(15, height - 15);
                ctx.closePath();
                ctx.fill();
            }
        }

        indicator: Item {
            implicitWidth: 40
            implicitHeight: 40
            Rectangle {
                width: 26
                height: 26
                anchors.centerIn: parent
                visible: menuItem.checkable
                border.color: Colors.palette().surface0
                radius: 3
                Rectangle {
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                    visible: menuItem.checked
                    color: Colors.palette().surface0
                    radius: 2
                }
            }
        }

        contentItem: RowLayout {
            // IconImage {
            //     visible: menuItem.icon.name
            //     // implicitHeight: 30
            //     // implicitWidth: 30
            //     implicitSize: 20
            //     source: Quickshell.iconPath(menuItem.icon.name)
            // }

            Text {
                text: menuItem.icon.name
                color: menuItem.highlighted ? Colors.palette().subtext0 : Colors.palette().text
            }

            Text {
                text: menuItem.text
                font: menuItem.font
                opacity: enabled ? 1.0 : 0.3
                color: menuItem.highlighted ? Colors.palette().subtext0 : Colors.palette().text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true


            }
        }

        background: Rectangle {
            radius: 12
            opacity: enabled ? 1 : 0.3
            color: menuItem.highlighted ? Colors.palette().surface1 : "transparent"
        }
    }
}
