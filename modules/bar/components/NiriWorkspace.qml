pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import "../../../theme"
import "../../../services"

Rectangle {
    id: parentRoot

    property ShellScreen screen

    readonly property var monitor:
        screen ? Hyprland.monitorFor(screen) : null

    implicitWidth: parent.width
    implicitHeight: childrenRect.height

    color: Colors.palette().surface0
    border.width: 0.5
    border.color: Colors.palette().mantle
    radius: 10

    Loader {
        id: loader

        anchors.centerIn: parent

        sourceComponent:
            ASettings.settings.detailedWorkspaces
                ? detailed
                : simple
    }

    Component {
        id: detailed

        ColumnLayout {
            spacing: 5

            Repeater {
                model: Hyprland.workspaces

                delegate: Item {
                    id: workspaceItem

                    required property var modelData

                    readonly property bool belongsToMonitor:
                        parentRoot.monitor !== null &&
                        modelData.monitor !== null &&
                        modelData.monitor.id === parentRoot.monitor.id

                    readonly property bool focused:
                        modelData.focused

                    readonly property int windowCount:
                        modelData.toplevels
                            ? modelData.toplevels.count
                            : 0

                    visible: belongsToMonitor

                    Layout.preferredWidth:
                        focused ? bg.implicitWidth : 20

                    Layout.preferredHeight:
                        focused ? bg.implicitHeight : 20

                    Rectangle {
                        id: bg

                        visible: workspaceItem.focused

                        anchors.fill: parent
                        anchors.margins: 2

                        implicitHeight:
                            windowsLayout.implicitHeight + 20

                        implicitWidth:
                            windowsLayout.implicitWidth + 4

                        radius: 6
                        border.width: 0

                        color: Colors.palette().surface1

                        ColumnLayout {
                            id: windowsLayout

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter

                            IconImage {
                                visible: windowsRepeater.count === 0

                                source: Quickshell.iconPath("desktop")

                                Layout.alignment: Qt.AlignHCenter

                                implicitHeight: 18
                                implicitWidth: 18

                                scale: 0.6
                            }

                            Repeater {
                                id: windowsRepeater

                                model: workspaceItem.modelData.toplevels

                                delegate: Item {
                                    id: windowItem

                                    required property var modelData

                                    readonly property string appId:
                                        modelData.wayland?.appId ?? ""

                                    readonly property string normalizedAppId:
                                        windowItem.appId
                                            .toLowerCase()
                                            .replace(/\s+/g, "-")

                                    readonly property var desktopEntry:
                                        DesktopEntries.heuristicLookup(
                                            windowItem.normalizedAppId
                                        )

                                    implicitHeight: 18
                                    implicitWidth: 18

                                    scale: 0.8

                                    ToolTip.visible: hover.hovered
                                    ToolTip.delay:
                                        Application.styleHints.mousePressAndHoldInterval
                                    ToolTip.text:
                                        modelData.title ?? ""

                                    HoverHandler {
                                        id: hover
                                    }

                                    IconImage {
                                        anchors.fill: parent

                                        source:
                                            windowItem.desktopEntry?.icon
                                                ? Quickshell.iconPath(
                                                      windowItem.desktopEntry.icon
                                                  )
                                                : Quickshell.iconPath(
                                                      windowItem.appId
                                                  )
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible:
                            workspaceItem.belongsToMonitor &&
                            !workspaceItem.focused

                        anchors.centerIn: parent

                        font.pixelSize: 16

                        color:
                            workspaceItem.windowCount > 0
                                ? Colors.palette().text
                                : Colors.palette().surface2

                        text:
                            workspaceItem.modelData.name
                                ? ({
                                      1: "",
                                      2: "",
                                      3: "󰙯",
                                      4: "",
                                      5: ""
                                  }[
                                      workspaceItem.modelData.name
                                  ] ?? workspaceItem.modelData.name)
                                : "*"

                        TapHandler {
                            onTapped:
                                workspaceItem.modelData.activate()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: simple

        ColumnLayout {
            spacing: 5

            Repeater {
                model: Hyprland.workspaces

                delegate: Rectangle {
                    id: workspace

                    required property var modelData

                    readonly property bool belongsToMonitor:
                        parentRoot.monitor !== null &&
                        modelData.monitor !== null &&
                        modelData.monitor.id === parentRoot.monitor.id

                    readonly property bool focused:
                        modelData.focused

                    readonly property bool hasWindows:
                        modelData.toplevels &&
                        modelData.toplevels.count > 0

                    visible: belongsToMonitor

                    implicitHeight: 40
                    implicitWidth: 20

                    radius: 25

                    color:
                        focused
                            ? Colors.palette().text
                            : hasWindows
                                ? Colors.palette().surface2
                                : Colors.palette().surface1

                    TapHandler {
                        onTapped:
                            workspace.modelData.activate()
                    }
                }
            }
        }
    }
}
