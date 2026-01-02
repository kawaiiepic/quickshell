pragma Singleton

import Quickshell
import Qt.labs.folderlistmodel
import QtQuick

Singleton {
    id: root

    property var wallpaperList: FolderListModel {
        id: wallpaperFolder
        folder: "file:" + Quickshell.shellPath("assets/wallpapers/static")   // relative to your QML file
        nameFilters: ["*.jpg", "*.png"] // optional filter
        showDirs: false
        showFiles: true
    }

    property var currentWallpaper: {
        "name": "",
        "path": ""
    }

    function setWallpaper(index){
        print("Setting wallpaper to " + index)
        root.currentWallpaper = {
                    "name": wallpaperFolder.get(index, "fileName"),
                    "path": wallpaperFolder.get(index, "filePath")
                };
    }

    Connections {
        target: wallpaperFolder

        function onStatusChanged() {
            if (wallpaperFolder.count > 0)
                root.currentWallpaper = {
                    "name": wallpaperFolder.get(0, "fileName"),
                    "path": wallpaperFolder.get(0, "filePath")
                };
        }
    }
}
