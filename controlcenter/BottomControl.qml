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
import "../services" as Services
import QtQml.Models

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
                bottom: true
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
        model: Quickshell.screens

        PanelWindow {
            id: bottom
            required property var modelData

            screen: modelData

            visible: root.show

            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.show ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Normal
            anchors {
                bottom: true
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
                        // height: rectangle.border.width
                        height: 8
                        color: rectangle.color
                    }

                    ColumnLayout {
                        id: appList
                        anchors.fill: parent
                        spacing: 12

                        property var filteredApplications: DesktopEntries.applications.values.filter(app => {
                            return app.name.toLowerCase().includes(field.text.toLowerCase());
                        })

                        ScrollView {
                            // anchors.fill: parent
                            // Layout.fillHeight: true
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                bottom: searchBar.top
                                bottomMargin: 16
                            }
                            Layout.fillWidth: true
                            ListView {
                                model: appList.filteredApplications

                                delegate: Item {
                                    id: entry
                                    required property DesktopEntry modelData
                                    width: 200
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

                        Rectangle {
                            id: searchBar

                            Layout.preferredHeight: 44
                            radius: height / 2
                            color: "red"

                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                bottomMargin: 5
                                leftMargin: 10
                                rightMargin: 10
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10

                                // Search icon
                                Text {
                                    text: "🔍"
                                    font.pixelSize: 18
                                    opacity: 0.55
                                }

                                TextField {
                                    id: field
                                    Layout.fillWidth: true
                                    background: null
                                    placeholderText: "search..."
                                    font.pixelSize: 16
                                    cursorVisible: true
                                    selectByMouse: true

                                    focus: true // Set initial focus for demonstration

                                    //     // This block of code runs when the Escape key is pressed
                                    Keys.onEscapePressed: {
                                        field.text = "";
                                        root.show = false;
                                    }
                                }

                                // Clear button
                                MouseArea {
                                    visible: field.text.length > 0
                                    Layout.alignment: Qt.AlignVCenter6
                                    width: 24
                                    height: 24
                                    cursorShape: Qt.PointingHandCursor

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✕"
                                        font.pixelSize: 14
                                        opacity: 0.6
                                    }

                                    onClicked: field.clear()
                                }
                            }
                        }

                        // TextField {
                        //     id: myTextInput
                        //     Layout.fillWidth: true
                        //     placeholderText: "Search..."
                        //     // text: "Focus here and press Esc"
                        //     focus: true // Set initial focus for demonstration

                        //     // This block of code runs when the Escape key is pressed
                        //     Keys.onEscapePressed: {
                        //         console.log("Escape key pressed! Running custom code.");
                        //         print("Test");
                        //         myTextInput.text = ""
                        //         root.show = false;
                        //     }

                        //     Keys.onEnterPressed: {}
                        // }

                        Component.onCompleted: {
                            field.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }
}
