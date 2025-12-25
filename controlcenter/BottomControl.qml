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
import "../services" as Services
import QtQml.Models

Scope {
    id: controlCenter

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData

            property var hoverBarRegion: Region {
                item: hoverBar
            }

            property var bothRegions: Region {
                item: panelContent
            }

            screen: modelData
            visible: true
            mask: Region {item: panelContent}

            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: panelContent.show ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Normal
            anchors {
                bottom: true
            }

            implicitWidth: screen.width / 2.5
            implicitHeight: Math.min(400, screen.height - 40)

            Rectangle {
                id: hoverBar
                color: "transparent"
                height: 1
                width: 500
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        panelContent.show = true;

                        if (panelContent.visible == false)
                            panelContent.visible = true;
                    }
                }
            }

            FocusScope {
                id: panelContent
                anchors.fill: parent
                property bool show: false
                visible: false

                x: rectangle.x
                y: rectangle.y
                width: rectangle.width
                height: rectangle.height

                // Show Animation - Material 3 emphasized decelerate
                SequentialAnimation {
                    running: panelContent.show
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
                    running: !panelContent.show
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
                    Keys.onPressed: event => {
                        if (event.key == Qt.Key_A)
                            print("Pressed A");
                        if (event.key === Qt.Key_Escape) {
                            print("Test");
                            panelContent.show = false;
                            event.accepted = true; // Stop event propagation
                        }
                    }

                    color: Color.palette().base

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        // height: rectangle.border.width
                        height: 8
                        color: rectangle.color
                    }

                    ColumnLayout {
                        id: appList
                        anchors.fill: parent
                        spacing: 12

                        property var filteredApplications: DesktopEntries.applications.values.filter(app => {
                            return app.name.toLowerCase().includes(myTextInput.text.toLowerCase());
                        })

                        ScrollView {
                            anchors.fill: parent
                            ListView {
                                model: appList.filteredApplications

                                delegate: Item {
                                    id: entry
                                    required property DesktopEntry modelData
                                    width: parent.width
                                    height: 48

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 12
                                        color: ListView.isCurrentItem ? Color.palette().surface : "transparent"

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 12

                                            // App icon (optional but recommended)
                                            Image {
                                                source: Quickshell.iconPath(entry.modelData.icon)
                                                width: 24
                                                height: 24
                                                fillMode: Image.PreserveAspectFit
                                                visible: source !== ""
                                            }

                                            Column {
                                                spacing: 2
                                                anchors.verticalCenter: parent.verticalCenter

                                                Text {
                                                    text: entry.modelData.name
                                                    font.pixelSize: 15
                                                    font.weight: Font.Medium
                                                    color: Color.palette().text
                                                    elide: Text.ElideRight
                                                }

                                                // Optional subtitle (exec / comment)
                                                Text {
                                                    text: entry.modelData.comment || entry.modelData.execString
                                                    font.pixelSize: 11
                                                    color: Color.palette().subtext0
                                                    elide: Text.ElideRight
                                                    visible: text.length > 0
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        TextField {
                            id: myTextInput
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "Search..."
                            // text: "Focus here and press Esc"
                            focus: true // Set initial focus for demonstration

                            // This block of code runs when the Escape key is pressed
                            Keys.onEscapePressed: {
                                console.log("Escape key pressed! Running custom code.");
                                print("Test");
                                panelContent.show = false;
                            }

                            Keys.onEnterPressed: {}
                        }

                        Component.onCompleted: {
                            myTextInput.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }
}
