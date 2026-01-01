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
        model: Quickshell.screens.filter(screen => screen.x == 0)

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

                        // property var filteredApplications: {
                        //     const query = field.text.toLowerCase();
                        //     const customCommands = [
                        //         {
                        //             type: "command",
                        //             icon: "󰸉",
                        //             name: "Wallpaper",
                        //             desc: "Change the current wallpaper"
                        //         }
                        //     ];
                        //     const out = [];

                        //     // command entry
                        //     if (query.startsWith(">")) {
                        //         for (const command of customCommands) {
                        //             if (command.name.toLowerCase().includes(query.slice(1).trim().toLowerCase())) {
                        //                 out.push(command);
                        //             }
                        //         }
                        //         // out.push({
                        //         //     type: "command",
                        //         //     name: "change wallpaper"
                        //         // });
                        //     }

                        //     // app entries
                        //     for (const app of DesktopEntries.applications.values) {
                        //         if (app.name.toLowerCase().includes(query.toLowerCase())) {
                        //             out.push({
                        //                 type: "app",
                        //                 desktopEntry: app
                        //             });
                        //         }
                        //     }

                        //     return out;
                        // }

                        Item {
                            id: content
                            property string mode: "wallpaper"

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Loader {
                                id: loader
                                anchors.fill: parent

                                sourceComponent: {
                                    switch (content.mode) {
                                    case "apps":
                                        return appsComp;
                                    case "wallpaper":
                                        return wallpaperComp;
                                    }
                                }
                                onLoaded: {
                                    switch (content.mode) {
                                    case "wallpaper":
                                        bottom.implicitHeight = 250;
                                    }
                                }
                            }

                            Component {
                                id: appsComp
                                Item {
                                    Text {
                                        text: "Testing"
                                    }
                                }
                            }

                            Component {
                                id: wallpaperComp
                                Item {

                                    Process {
                                        id: process
                                    }

                                    ListView {
                                        id: list
                                        width: content.width
                                        height: content.height
                                        orientation: ListView.Horizontal
                                        reuseItems: true
                                        spacing: 8

                                        anchors.verticalCenter: content.verticalCenter

                                        model: WallpaperManager.wallpaperList

                                        delegate: Item {
                                            id: wall
                                            required property int index
                                            required property string fileName
                                            required property string filePath

                                            // anchors.horizontalCenter: parent.horizontalCenter
                                            // anchors.verticalCenter: content.verticalCenter

                                            width: WallpaperManager.currentWallpaper.path == filePath ? 250 : 200
                                            height: list.height

                                            Loader {
                                                id: clipLoader
                                                active: list.visible
                                                sourceComponent: wallComp
                                            }

                                            Component {
                                                id: wallComp
                                                Item {
                                                    id: rec

                                                    Column {
                                                        anchors.centerIn: wall
                                                        spacing: 8

                                                        ClippingRectangle {
                                                            implicitWidth: wall.width
                                                            implicitHeight: WallpaperManager.currentWallpaper.path == wall.filePath ? 150 : 120
                                                            radius: 12
                                                            clip: true

                                                            Image {
                                                                anchors.fill: parent
                                                                source: wall.filePath
                                                                fillMode: Image.PreserveAspectCrop
                                                            }

                                                            MouseArea {
                                                                anchors.fill: parent
                                                                onClicked: {
                                                                    WallpaperManager.setWallpaper(wall.index);
                                                                    process.command = ["notify-send", "Updated Wallpaper"];
                                                                    process.running = true;
                                                                }
                                                            }
                                                        }

                                                        Text {
                                                            text: wall.fileName.replace(".jpg", "").replace(".png", "")
                                                            font.pixelSize: 14
                                                            horizontalAlignment: Text.AlignHCenter
                                                            color: Color.palette().text
                                                            elide: Text.ElideRight
                                                            width: wall.width
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        // ScrollView {
                        //     anchors {
                        //         top: parent.top
                        //         left: parent.left
                        //         right: parent.right
                        //         bottom: searchBar.top
                        //         bottomMargin: 16
                        //     }
                        //     Layout.fillWidth: true
                        //     ListView {
                        //         id: listView
                        //         model: appList.filteredApplications
                        //         clip: true

                        //         delegate: DelegateChooser {
                        //             id: entry
                        //             role: "type"

                        //             // COMMAND ROW
                        //             DelegateChoice {
                        //                 roleValue: "command"

                        //                 Item {
                        //                     id: boop
                        //                     width: listView.width
                        //                     height: 48
                        //                     required property var model

                        //                     function activate() {
                        //                         console.log("custom command activated");
                        //                     }

                        //                     MouseArea {
                        //                         anchors.fill: parent
                        //                         onClicked: {
                        //                             boop.activate();
                        //                         }
                        //                     }

                        //                     Rectangle {
                        //                         anchors.fill: parent
                        //                         radius: 12
                        //                         color: boop.ListView.isCurrentItem ? Color.palette().surface0 : "transparent"

                        //                         Row {
                        //                             anchors.fill: parent
                        //                             anchors.margins: 12
                        //                             spacing: 12

                        //                             Text {
                        //                                 anchors.verticalCenter: parent.verticalCenter
                        //                                 text: boop.model.icon
                        //                                 color: Color.palette().text
                        //                                 font.pixelSize: 30
                        //                             }

                        //                             Column {
                        //                                 spacing: 2
                        //                                 anchors.verticalCenter: parent.verticalCenter

                        //                                 Text {
                        //                                     text: boop.model.name
                        //                                     font.pixelSize: 15
                        //                                     color: Color.palette().text
                        //                                 }

                        //                                 Text {
                        //                                     text: boop.model.desc
                        //                                     font.pixelSize: 11
                        //                                     color: Color.palette().subtext0
                        //                                 }
                        //                             }
                        //                         }
                        //                     }
                        //                 }
                        //             }

                        //             // APP ROW
                        //             DelegateChoice {

                        //                 roleValue: "app"

                        //                 Item {
                        //                     id: boop2
                        //                     width: listView.width
                        //                     height: 48
                        //                     required property var model
                        //                     required property int index

                        //                     Rectangle {
                        //                         anchors.fill: parent
                        //                         radius: 12
                        //                         color: boop2.ListView.isCurrentItem ? Color.palette().surface0 : "transparent" // ListView.isCurrentItem

                        //                         Row {
                        //                             anchors.fill: parent
                        //                             anchors.margins: 12
                        //                             spacing: 12

                        //                             Image {
                        //                                 source: Quickshell.iconPath(boop2.model.desktopEntry.icon)
                        //                                 width: 24
                        //                                 height: 24
                        //                                 visible: source !== ""
                        //                             }

                        //                             Column {
                        //                                 spacing: 2

                        //                                 Text {
                        //                                     text: boop2.model.desktopEntry.name
                        //                                     font.pixelSize: 15
                        //                                     color: Color.palette().text
                        //                                 }

                        //                                 Text {
                        //                                     text: boop2.model.desktopEntry.comment || boop2.model.desktopEntry.execString
                        //                                     font.pixelSize: 11
                        //                                     color: Color.palette().subtext0
                        //                                 }
                        //                             }
                        //                         }

                        //                         MouseArea {
                        //                             id: mouse
                        //                             anchors.fill: parent
                        //                             hoverEnabled: true
                        //                             onEntered: {
                        //                                 listView.currentIndex = boop2.index;
                        //                             }
                        //                             onClicked: boop2.model.desktopEntry.launch()
                        //                         }
                        //                     }
                        //                 }
                        //             }
                        //         }
                        //     }
                        // }

                        Rectangle {
                            id: searchBar

                            Layout.preferredHeight: 44
                            radius: height / 2
                            color: Color.palette().surface1

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
                                    focus: true
                                    color: Color.palette().subtext0
                                    font.pixelSize: 16
                                    cursorVisible: true
                                    selectByMouse: true

                                    // focus: true // Set initial focus for demonstration

                                    Keys.onPressed: event => {
                                        if (event.key === Qt.Key_Down) {
                                            listView.incrementCurrentIndex();
                                            event.accepted = true;
                                        } else if (event.key === Qt.Key_Up) {
                                            listView.decrementCurrentIndex();
                                            event.accepted = true;
                                        } else if (event.key === Qt.Key_Return) {
                                            listView.forceActiveFocus();
                                            listView.currentItem?.activate?.();
                                            event.accepted = true;
                                        }
                                    }

                                    Keys.onEscapePressed: {
                                        field.text = "";
                                        root.show = false;
                                    }
                                }

                                // Clear button
                                MouseArea {
                                    visible: field.text.length > 0
                                    Layout.alignment: Qt.AlignVCenter
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
                        Component.onCompleted: {
                            field.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }
}
