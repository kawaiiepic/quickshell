pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import "../colors"
import "./components"
import "../components/effects"
import "../components"
import "../services"
import QtQml.Models
import Qt.labs.folderlistmodel
import Quickshell.Io
import Quickshell.Widgets

Scope {
    id: root
    property bool show: false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: hoverTrigger
            required property var modelData

            screen: modelData

            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Normal
            anchors {
                top: true
            }

            implicitWidth: screen.width / 2.5
            implicitHeight: 1

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
            id: bottom
            required property var modelData

            screen: modelData

            visible: root.show

            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Normal
            anchors {
                top: true
            }

            implicitWidth: screen.width / 2.5
            implicitHeight: Math.min(400, screen.height - 40)

            FocusScope {
                id: panelContent
                anchors.fill: parent

                x: rectangle.x
                y: rectangle.y
                width: rectangle.width
                height: rectangle.height

                // Show Animation - Material 3 emphasized decelerate
                SequentialAnimation {
                    running: root.show
                    ParallelAnimation {
                        NumberAnimation {
                            target: panelContent
                            property: "scale"
                            from: 0.94
                            to: 1.0
                            duration: Material3Anim.medium2

                            easing.bezierCurve: Material3Anim.emphasizedDecelerate
                        }
                        NumberAnimation {
                            target: panelContent
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: Material3Anim.medium1
                            easing.bezierCurve: Material3Anim.standard
                        }
                    }
                }

                SequentialAnimation {
                    running: !root.show
                    ParallelAnimation {
                        NumberAnimation {
                            target: panelContent
                            property: "scale"
                            from: 1.0
                            to: 0.94
                            duration: Material3Anim.medium2

                            easing.bezierCurve: Material3Anim.emphasizedDecelerate
                        }
                        NumberAnimation {
                            target: panelContent
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: Material3Anim.medium1
                            easing.bezierCurve: Material3Anim.standard
                        }
                    }
                }

                StyledRect {
                    id: rectangle
                    bottomLeftRadius: 0
                    bottomRightRadius: 0
                    radius: 24
                    anchors.fill: parent

                    border.width: 1.5
                    border.color: Color.palette().crust

                    color: Color.palette().base

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 8
                        color: rectangle.color
                    }

                    ColumnLayout {
                        id: appList
                        anchors.fill: parent
                        spacing: 12

                        Text { text: "Boop"}
                    }
                }
            }
        }
    }
}
