import QtQuick
import Qt5Compat.GraphicalEffects
import "../../modules/niri"

Column {
    spacing: 5
    anchors.horizontalCenter: parent.horizontalCenter
    Repeater {
        id: repeater
        model: Niri.workspaces

        Rectangle {
            id: capsule
            height: 18
            width: Math.max(18, textItem.implicitWidth + 12)
            radius: 10

            color: Niri.workspaces[index].is_active ? '#ff0f4b' : '#f0f0f0'
            border.width: Niri.workspaces[index].is_active ? 1.5 : 1
            border.color: Niri.workspaces[index].is_active ? "#ffffff33" : "#ffffff15"

            layer.enabled: true
            layer.samples: 4
            layer.effect: OpacityMask {
                maskSource: capsule
            }

            Text {
                id: textItem
                anchors.centerIn: parent
                text: Niri.workspaces[index].name
                font.pixelSize: 13
                color: Niri.workspaces[index].is_active ? "#fff" : "#cccccc"
            }

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
            Behavior on border.width {
                NumberAnimation {
                    duration: 120
                }
            }
        }
    }
}
