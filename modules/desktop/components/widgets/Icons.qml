pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import QtCore
import QtQml
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland

import "../../../../ui"
import "../../../../theme"
import "../../../../services"

Scope {
    id: desktopIcons

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            WlrLayershell.namespace: "quickshell-icons"
            WlrLayershell.layer: WlrLayer.Background

            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            aboveWindows: false
            focusable: true

            FolderListModel {
                id: desktopFolder
                folder: StandardPaths.writableLocation(StandardPaths.DesktopLocation)
                showDirsFirst: true
            }

            Item {
                anchors.fill: parent
                anchors.margins: 24

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    ThemedMenu {
                        id: contextMenu

                        width: 500

                        Text {
                            text: WallpaperManager.settings.wallpaperName
                            opacity: 0.8
                            color: Colors.palette().text
                            horizontalAlignment: Text.AlignHCenter // Center horizontally
                            verticalAlignment: Text.AlignVCenter   // Center vertically
                            topPadding: 5
                            bottomPadding: 5
                            elide: Text.ElideRight
                            ToolTip.visible: tooltipHover.hovered
                            ToolTip.text: WallpaperManager.settings.wallpaperPath

                            HoverHandler {
                                id: tooltipHover
                            }
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 20
                            height: 1
                            color: Colors.palette().surface1
                            radius: 10
                        }

                        Action {
                            text: qsTr("Open Terminal Here")
                            icon.name: "terminal"
                        }

                        Action {
                            text: qsTr("Open Desktop Folder")
                            icon.name: "folder"
                        }

                        Action {
                            text: qsTr("New Folder")
                            icon.name: "folder"
                        }

                        Action {
                            text: "Modify Shell Settings"
                            icon.name: ""
                            onTriggered: GlobalData.settingsWindow = true
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
                    anchors.rightMargin: 50

                    cellWidth: 90
                    cellHeight: 90

                    model: desktopFolder

                    interactive: false

                    delegate: Rectangle {
                        id: item

                        required property var modelData
                        required property int index

                        width: iconGrid.cellWidth - 2
                        height: iconGrid.cellHeight - 2

                        radius: 8
                        color: hover.hovered ? Colors.transparent(Colors.palette().surface0, 0.1) : "transparent"

                        FileView {
                            id: desktopFile
                            path: item.modelData.fileUrl
                            blockLoading: true
                            printErrors: false
                        }

                        Column {
                            id: desktopSuffix
                            property string name
                            property string exec
                            property string icon

                            anchors.centerIn: parent
                            spacing: 6

                            function iconForItem(item) {
                                if (item.fileIsDir) {
                                    return Quickshell.iconPath("folder");
                                }
                                switch (item.fileSuffix) {
                                case "desktop":
                                    return Quickshell.iconPath(desktopSuffix.icon, "image-missing");
                                case "jpg":
                                case "webp":
                                case "png":
                                    return item.fileUrl;
                                default:
                                    return Quickshell.iconPath("text-x-generic");
                                }
                            }

                            function nameForItem(item) {
                                switch (item.fileSuffix) {
                                case "desktop":
                                    return desktopSuffix.name;
                                default:
                                    return item.fileName;
                                }
                            }

                            IconImage {
                                visible: {
                                    var suffix = item.modelData.fileSuffix;
                                    switch (suffix) {
                                    case "jpg":
                                    case "webp":
                                    case "png":
                                        return false;
                                    default:
                                        return true;
                                    }
                                }
                                width: 38
                                height: 38
                                source: desktopSuffix.iconForItem(item.modelData)
                            }

                            Image {
                                id: imageInstance
                                visible: {
                                    var suffix = item.modelData.fileSuffix;
                                    switch (suffix) {
                                    case "jpg":
                                    case "webp":
                                    case "png":
                                        return true;
                                    default:
                                        return false;
                                    }
                                }

                                width: 38
                                height: 38
                                fillMode: Image.PreserveAspectFit
                                clip: true
                                source: desktopSuffix.iconForItem(item.modelData)

                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    id: opacityMaskInstance
                                    maskSource: Rectangle {
                                        id: maskedRect
                                        width: imageInstance.width
                                        height: imageInstance.height
                                        radius: 8
                                    }
                                }
                            }

                            Text {
                                property string name: desktopSuffix.nameForItem(item.modelData)
                                width: parent.width
                                text: name
                                ToolTip.visible: _mouseArea.containsMouse
                                ToolTip.text: name
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                horizontalAlignment: Text.AlignHCenter
                                color: Colors.palette().text

                                style: Text.Raised
                                styleColor: Colors.palette().crust  // semi-transparent black outline

                                MouseArea {
                                    id: _mouseArea
                                    hoverEnabled: true
                                    anchors.fill: parent
                                }
                            }

                            Component.onCompleted: {
                                if (item.modelData.fileIsDir) {} else {
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
                        }

                        HoverHandler {
                            id: hover
                            cursorShape: Qt.CrossCursor
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            Process {
                                id: process
                            }

                            ThemedMenu {
                                id: appContextMenu

                                focus: true

                                Action {
                                    id: openAction
                                    text: qsTr("Open")
                                    icon.name: "󰌧"
                                    shortcut: StandardKey.Open
                                    onTriggered: console.log("Open")
                                }

                                Action {
                                    id: copyAction
                                    text: qsTr("Copy")
                                    icon.name: ""
                                    shortcut: StandardKey.Copy
                                    onTriggered: console.log("Copy")
                                }

                                Action {
                                    id: deleteAction
                                    text: qsTr("Delete")
                                    icon.name: "󰆴"
                                    shortcut: StandardKey.Delete
                                    onTriggered: console.log("Delete")
                                }
                            }

                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton) {
                                    if (item.modelData.fileSuffix == "desktop") {
                                        process.command = desktopSuffix.exec.replace(" %U", "").split(" ");
                                        process.running = true;
                                    } else {
                                        Qt.openUrlExternally(item.modelData.fileUrl);
                                    }
                                } else if (mouse.button === Qt.RightButton) {
                                    appContextMenu.popup();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
