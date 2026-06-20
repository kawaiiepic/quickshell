pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import QtQuick.Controls

import "../../../theme"
import "../../../services"

Rectangle {
    id: parentRoot
    property ShellScreen screen

    implicitWidth: parent.width
    implicitHeight: childrenRect.height
    color: Colors.palette().surface0
    border.width: 0.5
    border.color: Colors.palette().mantle
    radius: 10

    Loader {
        id: loader
        sourceComponent: ShellSettings.detailedWorkspaces ? detailed : simple
        height: 200
        width: 200
    }

    Component {
        id: detailed

        ColumnLayout {
            spacing: 5
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Repeater {
                model: Niri.workspaces
                delegate: Item {
                    id: item
                    required property var modelData

                    Layout.preferredWidth: 20
                    Layout.preferredHeight: modelData.isFocused ? bg.implicitHeight : 20

                    Rectangle {
                        id: bg

                        visible: item.modelData.isFocused
                        anchors.fill: parent
                        anchors.margins: 2
                        implicitHeight: windowsLayout.implicitHeight + 20
                        implicitWidth: windowsLayout.implicitWidth + 4
                        radius: 6

                        border.width: 0

                        color: Colors.palette().surface1

                        SortFilterProxyModel {
                            id: filteredModel
                            model: Niri.windows

                            filters: [
                                ValueFilter {
                                    roleName: "workspaceId"
                                    value: item.modelData.id
                                }
                            ]
                        }

                        ColumnLayout {
                            id: windowsLayout
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter

                            IconImage {
                                id: icon
                                visible: repeater.count == 0
                                source: Quickshell.iconPath("desktop")
                                Layout.alignment: Qt.AlignHCenter
                                implicitHeight: 18
                                implicitWidth: 18
                                scale: 0.6
                            }

                            Repeater {
                                id: repeater
                                model: filteredModel

                                delegate: Item {
                                    id: windowItem
                                    required property var modelData

                                    scale: 0.8

                                    implicitHeight: 18
                                    implicitWidth: 18

                                    ToolTip.visible: hover.hovered
                                    ToolTip.delay: Application.styleHints.mousePressAndHoldInterval
                                    ToolTip.text: modelData.title

                                    HoverHandler {
                                        id: hover
                                    }

                                    IconImage {
                                        width: windowItem.implicitWidth
                                        height: windowItem.implicitHeight
                                        source: windowItem.modelData.iconPath ? "file://" + windowItem.modelData.iconPath : ""
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: !item.modelData.isFocused
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        color: repeater.count > 0 ? Colors.palette().text : Colors.palette().surface2
                        text: (item.modelData.name ? ({
                                    1: "",
                                    2: "",
                                    3: "󰙯",
                                    4: "",
                                    5: ""
                                }[item.modelData.name]) : "*")
                        TapHandler {
                            onTapped: {
                                Niri.focusWorkspace(item.modelData.id);
                            }
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
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Repeater {
                model: Niri.workspaces

                delegate: Item {
                    implicitHeight: 40
                    implicitWidth: 20

                    Rectangle {
                        implicitHeight: 40
                        implicitWidth: 20
                        radius: 25
                        color: "pink"
                    }
                }
            }
        }
    }
}
