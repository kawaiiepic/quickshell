import QtQuick
import QtQuick.Layouts
import "../../modules/niri"
import "../../colors"

Rectangle {
    width: parent.width
    height: childrenRect.height
    color: Color.palette().surface0
    border.width: 0.5
    border.color: Color.palette().mantle
    radius: 10

    ColumnLayout {
        spacing: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width: 20
        Layout.topMargin: 5
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Repeater {
            id: repeater
            model: 5
            Layout.topMargin: 8
            delegate: Text {
                id: myText

                property int winCount: (Niri.workspaceFromIndex(index + 1) ? (Niri.windowsInWorkspace(Niri.workspaceFromIndex(index + 1)) || []).length : 0)
                required property int index

                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                font.pixelSize: winCount > 0 ? 16 : 10
                color: Niri.workspaceFromIndex(index + 1)?.is_focused ? Color.palette().pink : winCount > 0 ? Color.palette().text : Color.palette().surface2
                text: Niri.workspaceFromIndex(index + 1) ? (winCount > 0 ? ({
                            1: "",
                            2: "",
                            3: "󰙯",
                            4: "",
                            5: ""
                        }[Niri.workspaceFromIndex(index + 1).name] || ".") : "") : "?"
            }
        }
    }
}
