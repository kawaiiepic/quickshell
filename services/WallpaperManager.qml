pragma Singleton
import Qt.labs.folderlistmodel
import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var process

    property var wallpaperEngineProcess: Process {}

    property var randomWallpaper: false

    process: Process {}

    Timer {
        // 1000 milliseconds is 1 second
        interval: 1000 * 60 * 30

        // start the timer immediately
        running: root.randomWallpaper

        // run the timer again when it ends
        repeat: root.randomWallpaper

        // when the timer is triggered, set the running property of the
        // process to true, which reruns it if stopped.
        onTriggered: {
            var randomIndex = Math.floor(Math.random() * wallpaperList.count);
            root.setWallpaper(randomIndex);
        }
    }

    property FolderListModel wallpaperList

    wallpaperList: FolderListModel {
        id: wallpaperList

        folder: "file:" + Quickshell.shellPath("assets/wallpapers")
        nameFilters: ["*.jpg", "*.png"]
        showDirs: false
        showFiles: true
        onStatusChanged: {
            if (status === FolderListModel.Ready && wallpaperList.count > 0) {
                if (settings.wallpaperID === -1) {
                    settings.wallpaperID = 1;
                    settings.wallpaperName = wallpaperList.get(1, "fileName");
                    settings.wallpaperPath = wallpaperList.get(1, "filePath");
                    settings.wallpaperType = "static";
                }
            }
        }
    }

    property FolderListModel wallpaperEngineList: FolderListModel {
        id: wallpaperEngineList

        folder: "file://" + "/home/mia/.local/share/Steam/steamapps/workshop/content/431960/"
        showDirs: true
        showFiles: true
    }

    function setWallpaper(index, type = "static", clipPreview = "") {
        if (wallpaperEngineProcess.running)
            wallpaperEngineProcess.running = false;

        if (type == "static") {
            if (index < 0 || index >= wallpaperList.count)
                return;

            var name = wallpaperList.get(index, "fileName");
            var path = wallpaperList.get(index, "filePath");
            print("Setting wallpaper to " + index);
            settings.wallpaperID = index;
            settings.wallpaperName = name;
            settings.wallpaperPath = path;
            settings.wallpaperType = "static";

            process.command = ["ln", "-sf", path, "/home/mia/.cache/background"];
            process.running = true;
            process.command = ["notify-send", "-i", "camera", "-h", "string:image-path:" + path, "-h", "string:preview:true", "Wallpaper", "Wallpaper has been updated: \n" + name];
            process.running = true;
        } else {
            if (index < 0 || index >= wallpaperEngineList.count)
                return;

            var name = wallpaperEngineList.get(index, "fileName");
            var path = wallpaperEngineList.get(index, "filePath");
            print("Setting wallpaper to " + index);
            settings.wallpaperID = index;
            settings.wallpaperName = name;
            settings.wallpaperPath = path;
            settings.wallpaperType = "engine";

            var screenArrayString = [];
            for (var screen of Quickshell.screens) {
                screenArrayString.push("--screen-root");
                screenArrayString.push(screen.name);
            }

            wallpaperEngineProcess.command = ["linux-wallpaperengine", "--fullscreen-pause-only-active", "--fullscreen-pause-ignore-appid", "kitty", "-v", "60", "--scaling", "fit", "--fps", "60", ...screenArrayString, "--bg", name];
            wallpaperEngineProcess.running = true;

            process.command = ["notify-send", "-i", "camera", "-h", "string:image-path:" + clipPreview, "-h", "string:preview:true", "Wallpaper", "Wallpaper has been updated: \n" + name];
            process.running = true;
        }
    }

    property Settings settings: Settings {
        id: settings

        property int wallpaperID: -1
        property string wallpaperName: ""
        property string wallpaperPath: ""
        property string wallpaperType: ""

        category: "wallpaper"
        location: Paths.settings
    }

    Component.onCompleted: {
     if (settings.wallpaperType == "engine") {
            if (wallpaperEngineProcess.running)
                wallpaperEngineProcess.running = false;
            var screenArrayString = [];
            for (var screen of Quickshell.screens) {
                screenArrayString.push("--screen-root");
                screenArrayString.push(screen.name);
            }

            wallpaperEngineProcess.command = ["linux-wallpaperengine", "--fullscreen-pause-only-active", "--fullscreen-pause-ignore-appid", "kitty", "-v", "60", "--scaling", "fit", "--fps", "30", ...screenArrayString, "--bg", settings.wallpaperName];
            wallpaperEngineProcess.running = true;
        }
    }
}
