pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import Quickshell.Hyprland

import "../../ui"

Scope {
    id: root
    property bool show: false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: hoverTrigger
            required property var modelData

            screen: modelData

            color: "red"
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            anchors {
                bottom: true
                right: true
            }

            implicitWidth: 10
            implicitHeight: 10

            Rectangle {
                id: hoverBar
                color: hoverTrigger.color
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        root.show = true;
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens.filter(screen => screen.x == 0)

        PanelWindow {
            id: top
            required property var modelData

            screen: modelData

            visible: true

            WlrLayershell.namespace: "controlcenter"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore

            color: "transparent"

            implicitWidth: top.screen.width / 5
            implicitHeight: Math.min(400, top.screen.height - 40)

            anchors {
                bottom: true
                right: true
            }

            margins {
                bottom: 5
                right: 5
            }

            HyprlandFocusGrab {
                id: grab
                active: root.show
                windows: [top]

                onCleared: {
                    root.show = false;
                }
            }

            StyledRect {
                id: rect
                parentWindow: top
                show: root.show
                pos: "bottom-right"

                ColumnLayout {
                    anchors.centerIn: parent
                    Rectangle {
                        color: Color.palette().surface0

                        implicitHeight: childrenRect.height
                        implicitWidth: rect.width - 50

                        radius: 12

                        Control {
                            padding: 10
                            contentItem: RowLayout {
                                anchors.centerIn: parent

                                Rectangle {
                                    implicitHeight: 40
                                    implicitWidth: 40
                                    radius: 50
                                    color: Color.palette().surface1

                                    IconImage {
                                        implicitSize: 24
                                        anchors.centerIn: parent
                                        source: Quickshell.iconPath("desktop")
                                    }
                                }

                                ColumnLayout {
                                    Text {
                                        text: "Keep Awake."
                                        color: Color.palette().text
                                    }
                                    Text {
                                        text: "Normal power managerment"
                                        color: Color.palette().text
                                    }
                                }

                                Switch {
                                    anchors.left: parent.right
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
