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

    implicitWidth: parent.width
    implicitHeight: loader.item ? loader.item.implicitHeight + 8 : 20
    color: Colors.palette().surface0
    border.width: 0.5
    border.color: Colors.palette().mantle
    radius: 10

    readonly property var workspaceIcons: ({
        "1": "\uE658",
        "2": "\uE795",
        "3": "\uDB2F",
        "4": "\uF372",
        "5": "\uF1B6"
    })

    function labelFor(ws) {
        const key = String(ws.name || ws.id);
        return root.workspaceIcons[key] || String(ws.id > 0 ? ws.id : key);
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
                model: Hyprland.workspaces

                delegate: Item {
                    id: item
                    required property var modelData

                    visible: Compositor.workspaceOnScreen(modelData, root.screen)
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: visible ? (modelData.focused ? Math.max(bg.implicitHeight, 20) : 20) : 0
                    Layout.alignment: Qt.AlignHCenter

                    readonly property int windowCount: modelData.toplevels ? modelData.toplevels.values.length : 0
                    readonly property bool occupied: windowCount > 0 || modelData.focused || modelData.active

                    Rectangle {
                        id: bg
                        visible: item.visible && item.modelData.focused
                        anchors.fill: parent
                        anchors.margins: 2
                        implicitHeight: windowsLayout.implicitHeight + 16
                        implicitWidth: 20
                        radius: 6
                        color: Colors.palette().surface1

                        ColumnLayout {
                            id: windowsLayout
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            IconImage {
                                visible: item.windowCount === 0
                                source: Quickshell.iconPath("desktop")
                                Layout.alignment: Qt.AlignHCenter
                                implicitHeight: 16
                                implicitWidth: 16
                            }

                            Repeater {
                                model: item.modelData.toplevels

                                delegate: Item {
                                    id: windowItem
                                    required property var modelData

                                    implicitHeight: 16
                                    implicitWidth: 16

                                    ToolTip.visible: hover.hovered
                                    ToolTip.delay: 400
                                    ToolTip.text: modelData.title || ""

                                    HoverHandler {
                                        id: hover
                                    }

                                    IconImage {
                                        anchors.fill: parent
                                        source: Compositor.iconForToplevel(windowItem.modelData)
                                    }

                                    TapHandler {
                                        onTapped: Compositor.focusWindow(windowItem.modelData)
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: item.visible && !item.modelData.focused
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        color: item.modelData.urgent ? Colors.palette().red : (item.occupied ? Colors.palette().text : Colors.palette().surface2)
                        text: root.labelFor(item.modelData)

                        TapHandler {
                            onTapped: Compositor.activateWorkspace(item.modelData)
                        }
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
                model: Hyprland.workspaces

                delegate: Item {
                    id: pill
                    required property var modelData

                    visible: Compositor.workspaceOnScreen(modelData, root.screen)
                    implicitHeight: visible ? 18 : 0
                    implicitWidth: 18
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: visible ? 18 : 0

                    readonly property bool occupied: (modelData.toplevels && modelData.toplevels.values.length > 0) || modelData.active

                    Rectangle {
                        anchors.centerIn: parent
                        implicitHeight: pill.modelData.focused ? 16 : (pill.occupied ? 10 : 8)
                        implicitWidth: 8
                        radius: 8
                        color: pill.modelData.urgent ? Colors.palette().red : (pill.modelData.focused ? Colors.palette().pink : (pill.occupied ? Colors.palette().text : Colors.palette().surface2))

                        Behavior on implicitHeight {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }

                    TapHandler {
                        onTapped: Compositor.activateWorkspace(pill.modelData)
                    }

                    ToolTip.visible: hover.hovered
                    ToolTip.delay: 400
                    ToolTip.text: "Workspace " + (pill.modelData.name || pill.modelData.id)

                    HoverHandler {
                        id: hover
                    }
                }
            }
        }
    }
}
