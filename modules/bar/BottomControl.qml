pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import QtQml.Models
import Quickshell.Hyprland

import "../../ui"
import "../../theme"
import "../../services"

BaseOverlay {
    id: root

    visible: GlobalData.showAppMenu

    implicitWidth: screen.width / 2.7
    implicitHeight: Math.min(400, screen.height - 40)

    onRequestClose: {
        GlobalData.showAppMenu = false;
    }

    anchors {
        bottom: true
    }

    margins {
        bottom: 5
    }

    StyledRect {
        id: rectangle
        parentWindow: bottom

        implicitHeight: 400
        implicitWidth: 600

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        ColumnLayout {
            id: appList
            anchors.fill: parent
            spacing: 0

            property string activeCategory: "ALL"

            property var customCommands: [
                {
                    type: "command",
                    icon: "󰸉",
                    name: "Wallpaper",
                    desc: "Change the current wallpaper"
                }
            ]

            // collect unique categories from all apps
            property var allCategories: {
                const query = field.text.toLowerCase();
                if (query.startsWith(">wallpaper")) {
                    return ["ALL", "NORMAL", "ANIMATED"];
                }
                const cats = new Set();
                for (const app of DesktopEntries.applications.values) {
                    for (const c of app.categories) {
                        if (c && c.length > 0)
                            cats.add(c);
                    }
                }
                return ["ALL", ...Array.from(cats).sort().slice(0, 6)];
            }

            property int count: 0

            property var filteredApplications: {
                const query = field.text.toLowerCase();
                const out = [];

                if (query.startsWith(">")) {
                    for (const command of customCommands) {
                        if (command.name.toLowerCase().includes(query.slice(1).trim().toLowerCase()))
                            out.push(command);
                    }
                }

                for (const app of DesktopEntries.applications.values) {
                    const matchesQuery = app.name.toLowerCase().includes(query.toLowerCase());
                    const matchesCat = appList.activeCategory === "ALL" || app.categories.includes(appList.activeCategory);
                    if (matchesQuery && matchesCat)
                        out.push({
                            type: "app",
                            desktopEntry: app
                        });
                }

                appList.count = out.length;

                return out;
            }

            // ── category tabs ────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                Layout.topMargin: 10
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                ListView {
                    id: catTabs
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    spacing: 4
                    clip: true
                    model: appList.allCategories

                    delegate: Item {
                        required property string modelData
                        required property int index
                        width: catLabel.implicitWidth + 20
                        height: 28

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: appList.activeCategory === modelData ? Colors.palette().surface1 : Colors.palette().surface0
                            border.color: appList.activeCategory === modelData ? Colors.palette().pink : Colors.palette().crust
                            border.width: 0

                            Text {
                                id: catLabel
                                anchors.centerIn: parent
                                text: modelData
                                font.family: "Share Tech Mono"
                                font.pixelSize: 10
                                font.letterSpacing: 0.6
                                color: appList.activeCategory === modelData ? Colors.palette().text : Colors.palette().subtext0
                            }

                            TapHandler {
                                onTapped: appList.activeCategory = modelData
                            }
                        }
                    }
                }
            }

            // ── thin divider ─────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                height: 1
                color: Colors.palette().surface1
            }

            // ── app list ─────────────────────────────────────────────────
            Item {
                id: content
                property string mode: "apps"
                Layout.fillHeight: true
                Layout.fillWidth: true

                Loader {
                    id: loader
                    anchors.fill: parent
                    sourceComponent: content.mode === "apps" ? appsComp : wallpaperComp
                    onLoaded: {
                        bottom.implicitHeight = content.mode === "wallpaper" ? 500 : Math.min(400, screen.height - 40);
                        searchBar.list = item.listView;
                    }
                }

                Component {
                    id: appsComp
                    Item {
                        property alias listView: list

                        ListView {
                            id: list
                            anchors.fill: parent
                            model: appList.filteredApplications
                            clip: true
                            spacing: 2
                            topMargin: 6
                            bottomMargin: 6

                            property double previousMouseX: 0
                            property double previousMouseY: 0

                            delegate: DelegateChooser {
                                role: "type"

                                // ── command row ──────────────────────────
                                DelegateChoice {
                                    roleValue: "command"

                                    Item {
                                        id: cmdRow
                                        width: list.width
                                        height: 44
                                        required property var model

                                        function activate() {
                                            field.text = ">" + model.name.toLowerCase();
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            radius: 8
                                            color: cmdRow.ListView.isCurrentItem ? Colors.palette().surface0 : "transparent"
                                            border.color: cmdRow.ListView.isCurrentItem ? Colors.palette().crust : "transparent"
                                            border.width: 1

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 10
                                                // anchors.rightMargin: 10
                                                // spacing: 12

                                                Rectangle {
                                                    width: 30
                                                    height: 30
                                                    radius: 3
                                                    color: Colors.palette().base
                                                    border.color: Colors.palette().crust
                                                    border.width: 1
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: cmdRow.model.icon
                                                        font.pixelSize: 16
                                                        color: Colors.palette().text
                                                    }
                                                }

                                                ColumnLayout {
                                                    spacing: 2
                                                    Text {
                                                        text: cmdRow.model.name
                                                        font.family: "Share Tech Mono"
                                                        font.pixelSize: 13
                                                        color: Colors.palette().text
                                                    }
                                                    Text {
                                                        text: cmdRow.model.desc
                                                        font.family: "Share Tech Mono"
                                                        font.pixelSize: 10
                                                        color: Colors.palette().text
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: cmdRow.activate()
                                            }
                                        }
                                    }
                                }

                                // ── app row ──────────────────────────────
                                DelegateChoice {
                                    roleValue: "app"

                                    Item {
                                        id: appRow
                                        width: list.width
                                        height: 50
                                        required property var model
                                        required property int index

                                        function activate() {
                                            appRow.model.desktopEntry.execute();
                                            field.text = "";
                                            root.requestClose();
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            radius: 3
                                            color: appRow.ListView.isCurrentItem ? Colors.palette().surface0 : "transparent"
                                            border.color: appRow.ListView.isCurrentItem ? Colors.palette().crust : "transparent"
                                            border.width: 1

                                            // left accent on selected
                                            Rectangle {
                                                visible: appRow.ListView.isCurrentItem
                                                width: 2
                                                height: parent.height - 12
                                                anchors.left: parent.left
                                                anchors.leftMargin: 1
                                                anchors.verticalCenter: parent.verticalCenter
                                                radius: 1
                                                color: Colors.palette().pink
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 14
                                                anchors.rightMargin: 10
                                                anchors.topMargin: 6
                                                anchors.bottomMargin: 6
                                                spacing: 12

                                                // icon box
                                                Rectangle {
                                                    width: 32
                                                    height: 32
                                                    radius: 6
                                                    color: Colors.palette().mantle
                                                    border.color: appRow.ListView.isCurrentItem ? Colors.palette().mantle : Colors.palette().crust
                                                    border.width: 1

                                                    Image {
                                                        anchors.centerIn: parent
                                                        source: Quickshell.iconPath(appRow.model.desktopEntry.icon, 'desktop')
                                                        width: 20
                                                        height: 20
                                                        visible: source !== ""
                                                    }
                                                }

                                                ColumnLayout {
                                                    spacing: 2
                                                    Layout.fillWidth: true

                                                    Text {
                                                        text: appRow.model.desktopEntry.name
                                                        font.family: "Share Tech Mono"
                                                        font.pixelSize: 13
                                                        color: appRow.ListView.isCurrentItem ? Colors.palette().text : Colors.palette().subtext0
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: appRow.model.desktopEntry.comment || appRow.model.desktopEntry.execString
                                                        font.family: "Share Tech Mono"
                                                        font.pixelSize: 9
                                                        color: Colors.palette().subtext0
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }
                                                }

                                                // category pill
                                                Repeater {
                                                    model: appRow.model.desktopEntry.categories.slice(0, 1)
                                                    delegate: Rectangle {
                                                        required property string modelData
                                                        height: 16
                                                        implicitWidth: pillLabel.implicitWidth + 12
                                                        radius: 2
                                                        color: Colors.palette().surface0
                                                        border.color: Colors.palette().crust
                                                        border.width: 1
                                                        Text {
                                                            id: pillLabel
                                                            anchors.centerIn: parent
                                                            text: modelData
                                                            font.family: "Share Tech Mono"
                                                            font.pixelSize: 8
                                                            color: Colors.palette().subtext0
                                                            font.letterSpacing: 0.4
                                                        }
                                                    }
                                                }
                                            }

                                            ThemedMenu {
                                                id: appContextMenu
                                                width: 200
                                                Action {
                                                    text: qsTr("Add to Desktop")
                                                    icon.name: "add"
                                                    onTriggered: console.log("add-to-desktop")
                                                }
                                            }

                                            MouseArea {
                                                id: mouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                onEntered: {
                                                    if (mouse.mouseX != list.previousMouseX || mouse.mouseY != list.previousMouseY) {
                                                        list.currentIndex = appRow.index;
                                                        list.previousMouseX = mouse.mouseX;
                                                        list.previousMouseY = mouse.mouseY;
                                                    }
                                                }
                                                onClicked: mouse => {
                                                    if (mouse.button === Qt.LeftButton) {
                                                        appRow.activate();
                                                    } else {
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
                }

                Component {
                    id: wallpaperComp
                    Item {
                        property alias listView: engineList
                        property var filteredWallpapers: {
                            const query = field.textSplit[1] ?? "";
                            const out = [];
                            for (var i = 0; i < WallpaperManager.wallpaperList.count; i++) {
                                var fileName = WallpaperManager.wallpaperList.get(i, "fileName");
                                var filePath = WallpaperManager.wallpaperList.get(i, "filePath");
                                if (fileName.toLowerCase().includes(query.toLowerCase()))
                                    out.push({
                                        fileIndex: i,
                                        fileName,
                                        filePath
                                    });
                            }
                            return out;
                        }

                        property var combinedModel: {
                            const items = [];

                            if (appList.activeCategory === "ALL" || appList.activeCategory === "ANIMATED") {
                                for (let i = 0; i < WallpaperManager.wallpaperEngineList.count; i++) {
                                    items.push({
                                        type: "engine",
                                        fileName: WallpaperManager.wallpaperEngineList.get(i, "fileName"),
                                        filePath: WallpaperManager.wallpaperEngineList.get(i, "filePath"),
                                        engineIndex: i
                                    });
                                }
                            }

                            if (appList.activeCategory === "ALL" || appList.activeCategory === "NORMAL") {
                                for (let i = 0; i < filteredWallpapers.length; i++) {
                                    items.push({
                                        type: "static",
                                        data: filteredWallpapers[i]
                                    });
                                }
                            }

                            appList.count = items.length;

                            return items;
                        }

                        ColumnLayout {
                            Text {
                                text: "Wallpapers"
                                padding: 8
                                color: Colors.palette().text
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pixelSize: 17
                                font.family: "Share Tech Mono"
                            }

                            ListView {
                                id: engineList
                                implicitWidth: content.width - 10
                                implicitHeight: 250
                                anchors.horizontalCenter: parent.horizontalCenter
                                clip: true
                                property int selectedIndex: -1
                                orientation: ListView.Horizontal
                                reuseItems: true
                                spacing: 8
                                flickDeceleration: 2000

                                model: combinedModel
                                delegate: Item {
                                    id: item
                                    required property var modelData
                                    required property int index

                                    property bool isEngine: modelData.type === "engine"

                                    implicitWidth: engineList.selectedIndex == index ? 350 : 300
                                    implicitHeight: engineList.selectedIndex == index ? 250 : 220

                                    ClippingRectangle {
                                        id: clip
                                        property string previewPath
                                        implicitWidth: parent.width
                                        implicitHeight: parent.height
                                        radius: 8
                                        clip: true
                                        border.width: engineList.selectedIndex == index ? 1 : 0
                                        border.color: Colors.palette().crust
                                        FolderListModel {
                                            folder: "file:" + item.modelData.filePath
                                            showDirs: false
                                            nameFilters: ["preview.*"]
                                            onStatusChanged: {
                                                if (status === FolderListModel.Ready && count > 0)
                                                    clip.previewPath = get(0, "filePath");
                                            }
                                        }
                                        AnimatedImage {
                                            visible: item.isEngine
                                            anchors.fill: parent
                                            source: clip.previewPath
                                            fillMode: Image.PreserveAspectCrop
                                            onStatusChanged: playing = (status == AnimatedImage.Ready)
                                        }
                                        Image {
                                            visible: !item.isEngine
                                            anchors.fill: parent
                                            source: item.modelData.data.filePath
                                            fillMode: Image.PreserveAspectCrop
                                        }
                                        Text {
                                            padding: 8
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            font.pixelSize: 20
                                            color: Colors.palette().text
                                            text: item.isEngine ? "" : ""
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                engineList.selectedIndex = item.index;
                                                if (item.isEngine) {
                                                    WallpaperManager.setWallpaper(item.modelData.engineIndex, "engine", clip.previewPath);
                                                } else {
                                                    WallpaperManager.setWallpaper(item.modelData.data.fileIndex);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── search bar ───────────────────────────────────────────────
            Rectangle {
                id: searchBar
                property ListView list

                Layout.fillWidth: true
                Layout.preferredHeight: 36
                Layout.bottomMargin: 10
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                radius: 3
                color: Colors.palette().mantle
                border.color: field.activeFocus ? Colors.palette().crust : Colors.palette().crust
                border.width: 1

                // top accent when focused
                Rectangle {
                    visible: field.activeFocus
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Colors.palette().pink
                    radius: 0
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10

                    Text {
                        text: ">_"
                        font.family: "Share Tech Mono"
                        font.pixelSize: 13
                        color: Colors.palette().subtext0
                        opacity: 0.7
                    }

                    TextField {
                        id: field
                        Layout.fillWidth: true
                        background: null
                        placeholderText: "search apps... (> for commands)"
                        focus: true
                        color: Colors.palette().text
                        placeholderTextColor: Colors.palette().subtext0
                        font.family: "Share Tech Mono"
                        font.pixelSize: 13
                        cursorVisible: true
                        selectByMouse: true
                        property var textSplit: field.text.toLowerCase().replace(">", "").split(" ")

                        onTextChanged: {
                            var mode = content.mode;
                            field.textSplit = field.text.toLowerCase().replace(">", "").split(" ");
                            if (mode == "apps") {
                                appList.customCommands.forEach(command => {
                                    if (textSplit[0] == command.name.toLowerCase()) {
                                        content.mode = "wallpaper";
                                        field.text += " ";
                                    }
                                });
                            }
                            if (mode != "apps" && !field.text.includes(mode + " ")) {
                                content.mode = "apps";
                                field.text = "";
                            }
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Down) {
                                searchBar.list.incrementCurrentIndex();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                searchBar.list.decrementCurrentIndex();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return) {
                                searchBar.list.currentItem?.activate?.();
                                forceActiveFocus();
                                event.accepted = true;
                            }
                        }
                        Keys.onEscapePressed: field.text = ""
                    }

                    // result count
                    Text {
                        text: appList.count + " apps"
                        font.family: "Share Tech Mono"
                        font.pixelSize: 9
                        color: Colors.palette().subtext0
                        font.letterSpacing: 0.4
                    }

                    MouseArea {
                        visible: field.text.length > 0
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 22
                        implicitHeight: 22
                        cursorShape: Qt.PointingHandCursor
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 14
                            color: Colors.palette().subtext0
                        }
                        onClicked: field.clear()
                    }
                }
            }

            Component.onCompleted: field.forceActiveFocus()
        }
    }
}
