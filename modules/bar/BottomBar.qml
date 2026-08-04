import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import QtCore

import "../../ui"
import "../../theme"

import "../../services"

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: barWindow

        required property var modelData

        // we can then set the window's screen to the injected property
        screen: modelData

        visible: GlobalData.showDock

        anchors {
            bottom: true
        }
        margins {
            left: 10
            right: 10
            bottom: 10
        }

        implicitHeight: 55
        implicitWidth: dockContent.implicitWidth
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        onVisibleChanged: {
            if (visible) {
                hideTimer.restart();
                dockContent.state = "hidden";
                showAnim.restart();
            } else {
                hideTimer.stop();
            }
        }

        Timer {
            id: hideTimer
            interval: 3000
            repeat: false
            onTriggered: {
                // GlobalData.showDock = false;
                hideAnim.restart();
            }
        }

        Item {
            id: dockContent
            anchors.fill: parent

            implicitWidth: rect.width

            // start collapsed/invisible before animation runs
            state: "hidden"

            states: [
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: dockContent
                        opacity: 0
                        scale: 0.82
                        y: -10
                    }
                },
                State {
                    name: "shown"
                    PropertyChanges {
                        target: dockContent
                        opacity: 1
                        scale: 1.0
                        y: 0
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"
                    to: "shown"
                    ParallelAnimation {
                        NumberAnimation {
                            property: "scale"
                            duration: 220
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.2
                        }
                        NumberAnimation {
                            property: "opacity"
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }
                },
                Transition {
                    from: "shown"
                    to: "hidden"
                    ParallelAnimation {
                        NumberAnimation {
                            property: "scale"
                            duration: 220
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.2
                        }
                        NumberAnimation {
                            property: "opacity"
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "y"
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            ]

            // keeps transform origin at bottom-center to match dock anchoring
            transform: Scale {
                origin.x: dockContent.width / 2
                origin.y: dockContent.height
                xScale: dockContent.scale
                yScale: dockContent.scale
            }

            SequentialAnimation {
                id: showAnim
                PauseAnimation {
                    duration: 10
                }  // one frame so "hidden" state settles first
                ScriptAction {
                    script: dockContent.state = "shown"
                }
            }

            SequentialAnimation {
                id: hideAnim
                PauseAnimation {
                    duration: 10
                }  // one frame so "hidden" state settles first
                ScriptAction {
                    script: dockContent.state = "hidden"
                }
                PauseAnimation {
                    duration: 200
                }
                ScriptAction {
                    script: GlobalData.showDock = false
                }
            }

            // ── gradient border ───────────────────────────────────────────
            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                radius: 18
                height: 46
                width: 300
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 0.2
                        color: "#b000ff"
                    }
                    GradientStop {
                        position: 0.5
                        color: "#ff2d78"
                    }
                    GradientStop {
                        position: 0.8
                        color: "#00e5ff"
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                }
            }

            // ── main pill ─────────────────────────────────────────────────
            Rectangle {
                id: rect
                // anchors.fill: parent
                implicitWidth: row.width + 20
                implicitHeight: parent.height
                radius: 18
                color: "#0a0b12"
                opacity: 0.95
                border.color: "#2a0a3a"
                border.width: 0

                RowLayout {
                    id: row
                    Layout.alignment: Qt.AlignHCenter

                    anchors {
                        centerIn: parent
                        // fill: parent
                        leftMargin: 20
                        rightMargin: 20
                    }
                    spacing: 0
                    Repeater {
                        model: [
                            {
                                icon: "",
                                label: "terminal",
                                clicked: () => {
                                    GlobalData.showAppMenu = !GlobalData.showAppMenu;
                                }
                            }
                            // {
                            //     icon: "\uf120",
                            //     label: "terminal"
                            // },
                            // {
                            //     icon: "\uf0ac",
                            //     label: "browser"
                            // },
                            // {
                            //     icon: "\uf07b",
                            //     label: "files"
                            // },
                            // {
                            //     icon: "\uf001",
                            //     label: "music"
                            // },
                            // {
                            //     icon: "\uf013",
                            //     label: "settings"
                            // },
                            // {
                            //     icon: "\uf011",
                            //     label: "power"
                            // },
                            ,
                        ]

                        delegate: Rectangle {
                            id: appBtn
                            width: 38
                            height: 32
                            radius: 8
                            color: hov.hovered ? "#1a0828" : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    modelData.clicked();
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                color: "#5a4070"
                            }

                            HoverHandler {
                                id: hov
                            }
                        }
                    }

                    Repeater {

                        model: ASettings.apps.favouriteApps

                        delegate: Rectangle {
                            id: appBtn2

                            required property var modelData

                            property var entry: DesktopEntries.applications.values.find(function (app) {
                                return app.name == modelData;
                            })

                            ThemedMenu {
                                id: appContextMenu
                                width: 20
                                Action {
                                    text: qsTr("Favourite App")
                                    icon.name: "add"
                                    onTriggered: {
                                        ASettings.apps.favouriteApps = [...ASettings.apps.favouriteApps, appRow.model.desktopEntry.name];
                                        root.requestClose();
                                    }
                                }

                                Action {
                                    text: qsTr("Add to Desktop")
                                    icon.name: "add"
                                    onTriggered: console.log("add-to-desktop")
                                }
                            }

                            width: 38
                            height: 32
                            radius: 8
                            color: appHov.hovered ? "#1a0828" : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                onClicked: mouse => {
                                    if (mouse.button === Qt.LeftButton) {
                                        entry.execute();
                                    } else {
                                        appContextMenu.popup();
                                    }
                                }
                            }

                            IconImage {
                                source: appBtn2.entry ? Quickshell.iconPath(appBtn2.entry.icon, "desktop") : Quickshell.iconPath("desktop")
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                            }

                            // Text {
                            //     anchors.centerIn: parent
                            //     text: appBtn2.entry.name
                            //     font.family: "JetBrainsMono Nerd Font"
                            //     font.pixelSize: 9
                            //     color: "#5a4070"
                            // }

                            HoverHandler {
                                id: appHov
                            }
                        }
                    }
                }
            }
        }
    }
}
