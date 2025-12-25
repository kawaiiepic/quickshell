pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import QtCore
import QtQml
import QtQuick.Controls
import "../colors"

Scope {
    id: desktopIcons

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            aboveWindows: false
            focusable: false

            FolderListModel {
                id: desktopFolder
                folder: StandardPaths.writableLocation(StandardPaths.DesktopLocation)
            }

            Item {
                anchors.fill: parent
                anchors.margins: 24

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    Menu {
                        id: contextMenu
                        popupType: Popup.Item
                        width: 500

                        Text {
                            text: root.wallpaperSrc
                            opacity: 0.8
                            horizontalAlignment: Text.AlignHCenter // Center horizontally
                            verticalAlignment: Text.AlignVCenter   // Center vertically
                            topPadding: 5
                            bottomPadding: 5
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 20
                            height: 1
                            color: "#1E000000"
                            radius: 10
                        }

                        MenuItem {
                            text: "🖥️ Open Terminal Here"
                            onTriggered: console.log("Open")
                            contentItem: Text {
                                text: parent.text // Bind to the MenuItem's text property
                                font: parent.font
                                color: parent.highlighted ? "white" : "black"
                                horizontalAlignment: Text.AlignHCenter // Center the text horizontally
                                verticalAlignment: Text.AlignVCenter   // Center the text vertically
                                anchors.fill: parent // Make the Text item fill the entire MenuItem
                            }
                        }

                        MenuItem {
                            text: "📁 Open Desktop Folder"
                            onTriggered: console.log("Delete")
                            contentItem: Text {
                                text: parent.text // Bind to the MenuItem's text property
                                font: parent.font
                                color: parent.highlighted ? "white" : "black"
                                horizontalAlignment: Text.AlignHCenter // Center the text horizontally
                                verticalAlignment: Text.AlignVCenter   // Center the text vertically
                                anchors.fill: parent // Make the Text item fill the entire MenuItem
                            }
                        }

                        MenuItem {
                            text: "📂 New Folder"
                            onTriggered: console.log("Delete")
                            contentItem: Text {
                                text: parent.text // Bind to the MenuItem's text property
                                font: parent.font
                                color: parent.highlighted ? "white" : "black"
                                horizontalAlignment: Text.AlignHCenter // Center the text horizontally
                                verticalAlignment: Text.AlignVCenter   // Center the text vertically
                                anchors.fill: parent // Make the Text item fill the entire MenuItem
                            }
                        }
                    }

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            contextMenu.popup();
                        }
                    }
                }

                GridView {
                    id: iconGrid
                    anchors.fill: parent

                    cellWidth: 96
                    cellHeight: 96

                    model: desktopFolder

                    interactive: false

                    delegate: Item {
                        id: item
                        required property var modelData
                        width: iconGrid.cellWidth
                        height: iconGrid.cellHeight

                        FileView {
                            id: desktopFile
                            path: item.modelData.fileUrl
                            blockLoading: true
                        }

                        Column {
                            id: desktopSuffix
                            property string name
                            property string exec
                            property string icon

                            anchors.centerIn: parent
                            spacing: 6

                            function iconForItem(item) {
                                switch (item.fileSuffix) {
                                case "desktop":
                                    return Quickshell.iconPath(desktopSuffix.icon, "image-missing");
                                case "folder":
                                    return Quickshell.iconPath("folder");
                                case "jpg":
                                case "webp":
                                    return item.modelData.fileUrl;
                                default:
                                    return Quickshell.iconPath("text-x-generic");
                                }
                            }

                            function nameForItem(item) {
                                switch (item.fileSuffix) {
                                case "desktop":
                                    return desktopSuffix.name;
                                default:
                                    return item.modelData.fileName;
                                }
                            }

                            IconImage {
                                width: 48
                                height: 48
                                source: desktopSuffix.iconForItem(item.modelData)
                            }

                            Text {
                                property string name: desktopSuffix.nameForItem(item.modelData)
                                width: parent.width
                                text: name
                                ToolTip.visible: _mouseArea.containsMouse
                                ToolTip.text: name
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                horizontalAlignment: Text.AlignHCenter
                                color: "black"

                                MouseArea {
                                    id: _mouseArea
                                    hoverEnabled: true
                                    anchors.fill: parent
                                }
                            }

                            Component.onCompleted: {
                                desktopFile.text().split('\n').forEach(line => {
                                    if (line.startsWith("Name="))
                                        name = line.substring(5);
                                    if (line.startsWith("Exec="))
                                        exec = line.substring(5);
                                    if (line.startsWith("Icon="))
                                        icon = line.substring(5);
                                });
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            Process {
                                id: process
                            }

                            Menu {
                                id: appContextMenu

                                MenuItem {
                                    text: "📂 Open"
                                    onTriggered: console.log("Open")
                                }

                                MenuItem {
                                    text: "📋 Copy"
                                    onTriggered: console.log("Delete")
                                }

                                MenuItem {
                                    text: "✂️ Cut"
                                    onTriggered: console.log("Delete")
                                }

                                MenuItem {
                                    text: "🗑️ Delete"
                                    onTriggered: console.log("Delete")
                                }

                                MenuItem {
                                    text: "🔧 Properties"
                                    onTriggered: console.log("Delete")
                                }
                            }

                            onClicked: mouse => {
                                print("Clicked app: " + item.modelData.fileName);
                                print(desktopSuffix.exec);

                                if (mouse.button === Qt.RightButton) {
                                    appContextMenu.popup();
                                }
                            }

                            onDoubleClicked: {
                                if (item.modelData.fileSuffix == "desktop") {
                                    process.command = desktopSuffix.exec.replace(" %U", "").split(" ");
                                    process.running = true;
                                    print(desktopSuffix.exec.replace(" %U", "").split(" "));
                                } else {
                                    Qt.openUrlExternally(item.modelData.fileUrl);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
