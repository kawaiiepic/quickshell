pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import QtQuick.Controls
import Quickshell.Hyprland

import "../../../theme"
import "../../../services"

Rectangle {
    id: root
    property ShellScreen screen
    property int workspaceCount: 10

    implicitWidth: parent.width
    implicitHeight: loader.item ? loader.item.implicitHeight + 8 : 20
    color: Colors.palette().surface0
    border.width: 0.5
    border.color: Colors.palette().mantle
    radius: 10

    function workspaceById(id) {
        const list = Hyprland.workspaces.values || [];
        for (let i = 0; i < list.length; i++) {
            if (list[i].id === id)
                return list[i];
        }
        return null;
    }

    function activateId(id) {
        const ws = root.workspaceById(id);
        if (ws && typeof ws.activate === "function")
            ws.activate();
        else
            Hyprland.dispatch("workspace " + id);
    }

    Loader {
        id: loader
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 4
        width: parent.width - 4
        sourceComponent: ASettings.settings.detailedWorkspaces ? detailed : simple
    }

    Component {
        id: detailed
        ColumnLayout {
            spacing: 5
            width: loader.width
            Repeater {
                model: root.workspaceCount
                delegate: Item {
                    id: item
                    required property int index
                    readonly property int wsId: index + 1
                    readonly property var ws: root.workspaceById(wsId)
                    readonly property bool focused: !!(ws && ws.focused)
                    readonly property var tops: ws && ws.toplevels ? ws.toplevels.values : []
                    readonly property int windowCount: tops ? tops.length : 0
                    readonly property bool occupied: windowCount > 0 || !!(ws && ws.active)

                    Layout.preferredWidth: 20
                    Layout.preferredHeight: focused ? Math.max(bg.implicitHeight, 20) : 20
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        id: bg
                        visible: item.focused
                        anchors.fill: parent
                        anchors.margins: 2
                        implicitHeight: windowsLayout.implicitHeight + 16
                        implicitWidth: 20
                        radius: 6
                        color: Colors.palette().surface1
                        ColumnLayout {
                            id: windowsLayout
                            anchors.centerIn: parent
                            spacing: 2
                            IconImage {
                                visible: item.windowCount === 0
                                source: Quickshell.iconPath("desktop")
                                implicitHeight: 16
                                implicitWidth: 16
                            }
                            Repeater {
                                model: item.ws ? item.ws.toplevels : []
                                delegate: Item {
                                    id: windowItem
                                    required property var modelData
                                    implicitHeight: 16
                                    implicitWidth: 16
                                    ToolTip.visible: hover.hovered
                                    ToolTip.delay: 400
                                    ToolTip.text: modelData.title || ""
                                    HoverHandler { id: hover }
                                    IconImage {
                                        anchors.fill: parent
                                        source: Compositor.iconForToplevel(windowItem.modelData)
                                    }
                                    TapHandler { onTapped: Compositor.focusWindow(windowItem.modelData) }
                                }
                            }
                        }
                    }
                    Text {
                        visible: !item.focused
                        anchors.centerIn: parent
                        font.pixelSize: 12
                        color: (item.ws && item.ws.urgent) ? Colors.palette().red : (item.occupied ? Colors.palette().text : Colors.palette().surface2)
                        text: String(item.wsId)
                        TapHandler { onTapped: root.activateId(item.wsId) }
                    }
                }
            }
        }
    }

    Component {
        id: simple
        ColumnLayout {
            spacing: 6
            width: loader.width
            Repeater {
                model: root.workspaceCount
                delegate: Item {
                    id: pill
                    required property int index
                    readonly property int wsId: index + 1
                    readonly property var ws: root.workspaceById(wsId)
                    readonly property bool focused: !!(ws && ws.focused)
                    readonly property bool occupied: !!(ws && ((ws.toplevels && ws.toplevels.values.length > 0) || ws.active))
                    implicitHeight: 18
                    implicitWidth: 18
                    Layout.alignment: Qt.AlignHCenter
                    Rectangle {
                        anchors.centerIn: parent
                        implicitHeight: pill.focused ? 16 : (pill.occupied ? 10 : 8)
                        implicitWidth: 8
                        radius: 8
                        color: (pill.ws && pill.ws.urgent) ? Colors.palette().red : (pill.focused ? Colors.palette().pink : (pill.occupied ? Colors.palette().text : Colors.palette().surface2))
                    }
                    TapHandler { onTapped: root.activateId(pill.wsId) }
                    ToolTip.visible: hover.hovered
                    ToolTip.delay: 400
                    ToolTip.text: "Workspace " + pill.wsId
                    HoverHandler { id: hover }
                }
            }
        }
    }
}
