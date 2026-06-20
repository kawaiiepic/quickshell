pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris

import "../../ui"
import "../../theme"
import "../../services"

BaseOverlay {
    id: overlay
    visible: true

    implicitWidth: screen.width / 2.7
    implicitHeight: Math.min(400, screen.height - 40)

    onRequestClose: {}

    property int selectedIndex: 0

    anchors {
        top: true
    }

    margins {
        top: 5
    }

    StyledRect {
        id: rectangle
        parentWindow: parent

        pos: "top"

        implicitHeight: overlay.height
        implicitWidth: overlay.width

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        ColumnLayout {
            anchors.fill: parent

            spacing: 8

            anchors.leftMargin: 15
            anchors.rightMargin: 15
            anchors.topMargin: 15
            anchors.bottomMargin: 15

            RowLayout {
                id: topRow
                spacing: 100

                Layout.fillWidth: true
                anchors.horizontalCenter: parent.horizontalCenter

                property var buttons: [
                    {
                        name: "Dashboard",
                        icon: "󰨝"
                    },
                    {
                        name: "Media",
                        icon: "󰲸"
                    },
                    {
                        name: "Notifications",
                        icon: "󰲸"
                    },
                    {
                        name: "Performance",
                        icon: "󰓅"
                    },
                ]

                Repeater {
                    id: repeater
                    model: topRow.buttons

                    delegate: Button {
                        id: btn

                        required property int index
                        required property var model

                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: childrenRect.width
                        implicitHeight: childrenRect.height

                        onClicked: {
                            overlay.selectedIndex = btn.index;
                        }

                        background: Rectangle {
                            color: "transparent"
                        }

                        ColumnLayout {
                            Text {
                                horizontalAlignment: Text.Center
                                Layout.fillWidth: true
                                text: btn.model.icon
                                font.pixelSize: 20
                                color: overlay.selectedIndex == btn.index ? Colors.palette().pink : Colors.palette().text
                            }
                            Text {
                                font.pixelSize: 15
                                text: btn.model.name
                                color: overlay.selectedIndex == btn.index ? Colors.palette().pink : Colors.palette().text
                            }
                        }
                    }
                }
            }

            Rectangle {
                implicitWidth: parent.width - 50
                implicitHeight: 2
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 8
                color: Colors.palette().text
            }

            Loader {
                id: loader

                sourceComponent: [dashboard, media, notifications, performance][overlay.selectedIndex]

                height: 500

                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Component {
                id: dashboard

                Item {
                    RowLayout {

                        ColumnLayout {

                            ClippingRectangle {
                                radius: 20
                                implicitWidth: 300
                                implicitHeight: 150
                                color: Colors.transparent(Colors.palette().surface0, 0.8)

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 20
                                    Image {
                                        source: "/home/mia/.face"
                                        sourceSize.width: 100
                                        sourceSize.height: 100

                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            id: opacityMaskInstance
                                            maskSource: Rectangle {
                                                id: maskedRect
                                                width: 100
                                                height: 100
                                                radius: 50
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Row {
                                            spacing: 10
                                            Text {
                                                color: Colors.palette().pink
                                                font.pixelSize: 18
                                                text: "󱄅"
                                            }
                                            Text {
                                                color: Colors.palette().text
                                                font.pixelSize: 18
                                                text: ":"
                                            }

                                            Text {
                                                color: Colors.palette().text
                                                font.pixelSize: 16
                                                text: "NixOS"
                                            }
                                        }

                                        Row {
                                            spacing: 10
                                            Text {
                                                color: Colors.palette().pink
                                                font.pixelSize: 18
                                                text: ""
                                            }
                                            Text {
                                                color: Colors.palette().text
                                                font.pixelSize: 18
                                                text: ":"
                                            }

                                            Text {
                                                color: Colors.palette().text
                                                font.pixelSize: 16
                                                text: "Niri"
                                            }
                                        }

                                        Row {
                                            spacing: 10
                                            Text {
                                                color: Colors.palette().pink
                                                font.pixelSize: 18
                                                text: ""
                                            }
                                            Text {
                                                color: Colors.palette().text
                                                font.pixelSize: 18
                                                text: ":"
                                            }

                                            Text {
                                                color: Colors.palette().text
                                                font.pixelSize: 16
                                                text: "up 2hrs, 20 mins"
                                            }
                                        }
                                    }
                                }
                            }

                            ClippingRectangle {
                                radius: 20
                                implicitWidth: 120
                                implicitHeight: 200
                                color: Colors.transparent(Colors.palette().surface0, 0.8)

                                SystemClock {
                                    id: clock
                                    precision: SystemClock.Minutes
                                }

                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: Qt.formatDateTime(clock.date, "hh")
                                        // Layout.alignment: Qt.AlignHCenter
                                        color: Colors.palette().text
                                        // height:
                                        font.pixelSize: 50
                                        height: 40
                                    }

                                    Text {
                                        text: "󰇘"
                                        // Layout.alignment: Qt.AlignHCenter
                                        color: Colors.palette().text
                                        font.pixelSize: 50
                                        height: 40
                                    }

                                    Text {
                                        text: Qt.formatDateTime(clock.date, "mm")
                                        Layout.alignment: Qt.AlignHCenter
                                        color: Colors.palette().text
                                        font.pixelSize: 50
                                        height: 70
                                    }

                                    Text {
                                        text: Qt.formatDateTime(clock.date, "ddd, d")
                                        Layout.alignment: Qt.AlignHCenter
                                        color: Colors.palette().text
                                        font.pixelSize: 15
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: media

                Item {

                    Row {
                        spacing: 2

                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: Cava.bars.length

                            anchors.horizontalCenter: parent.horizontalCenter

                            Layout.alignment: Qt.AlignCenter

                            Rectangle {
                                required property int index
                                width: 6
                                height: Math.max(4, Cava.bars[index] / 10)
                                radius: 8

                                color: Colors.palette().pink

                                Behavior on height {
                                    NumberAnimation {
                                        duration: 60
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: Mpris.players.values.length == 0

                        Text {
                            text: "Start by playing some music."
                        }
                    }

                    RowLayout {
                        id: row
                        visible: Mpris.players.values.length > 0
                        property MprisPlayer player: Mpris.players.values[0]

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.centerIn: parent
                        anchors.bottom: parent.top
                        spacing: 16

                        Rectangle {
                            width: 100
                            height: 100
                            radius: 100

                            color: Colors.palette().surface0

                            Text {
                                anchors.centerIn: parent
                                text: "T"
                            }
                        }
                        Image {
                            source: row.player.trackArtUrl
                            Layout.preferredHeight: 100
                            Layout.preferredWidth: 100
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: 100
                                    height: 100
                                    radius: 100
                                }
                            }
                            Component.onCompleted: {
                                print("Url" + row.player.trackArtUrl);
                            }
                        }

                        ColumnLayout {
                            implicitWidth: childrenRect.width
                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: row.player.trackTitle
                                color: Colors.palette().text
                            }
                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                visible: row.player.trackAlbum
                                text: row.player.trackAlbum
                                color: Colors.palette().subtext0
                                font.pixelSize: 13
                            }
                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: row.player.trackArtist
                                color: Colors.palette().subtext0
                                font.pixelSize: 13
                            }

                            FrameAnimation {
                                // only emit the signal when the position is actually changing.
                                running: row.player.playbackState == MprisPlaybackState.Playing
                                // emit the positionChanged signal every frame.
                                onTriggered: row.player.positionChanged()
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Item {
                                    Layout.fillWidth: true
                                }

                                Button {
                                    id: previous

                                    onClicked: {
                                        row.player.previous();
                                    }

                                    contentItem: Text {
                                        text: "󰒮"
                                        font.pixelSize: 25
                                        opacity: row.player.canGoPrevious ? 1.0 : 0.3
                                        color: row.player.canGoPrevious && previous.down ? Colors.palette().pink : Colors.palette().text
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                }
                                Button {
                                    id: play

                                    onClicked: {
                                        row.player.togglePlaying();
                                    }

                                    contentItem: Text {
                                        text: row.player.isPlaying ? "" : ""
                                        font.pixelSize: 25
                                        opacity: row.player.canTogglePlaying ? 1.0 : 0.3
                                        color: row.player.canTogglePlaying && play.down ? Colors.palette().pink : Colors.palette().text
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    background: Rectangle {
                                        implicitWidth: 40
                                        implicitHeight: 40
                                        opacity: row.player.canTogglePlaying ? 1 : 0.3
                                        color: Colors.palette().surface0
                                        radius: 25
                                    }
                                }
                                Button {
                                    id: next

                                    onClicked: {
                                        row.player.next();
                                    }

                                    contentItem: Text {
                                        text: "󰒭"
                                        font.pixelSize: 25
                                        opacity: row.player.canGoNext ? 1.0 : 0.3
                                        color: row.player.canGoNext && next.down ? Colors.palette().pink : Colors.palette().text
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }

                            SquigglyBar {
                                value: row.player.position / row.player.length
                                scrollable: row.player.canTogglePlaying
                                onUpdate: function (mouseX) {
                                    if (row.player.canSeek && row.player.positionSupported) {
                                        var n = Math.max(0, Math.min(1, (mouseX) / (width - 2)));
                                        row.player.position = row.player.length * n;
                                    }
                                }
                            }

                            RowLayout {
                                id: time
                                Layout.fillWidth: true
                                function formatTime(totalSeconds) {
                                    var rounded = Math.round(totalSeconds);
                                    var minutes = Math.floor(rounded / 60);
                                    var remainingSeconds = rounded % 60;

                                    var secondsString = remainingSeconds < 10 ? "0" + remainingSeconds : remainingSeconds.toString();

                                    return minutes + ":" + secondsString;
                                }
                                spacing: 0

                                Text {
                                    text: time.formatTime(row.player.position)
                                    color: Colors.palette().subtext0
                                    font.pixelSize: 15
                                    Layout.alignment: Qt.AlignLeft
                                }

                                Text {
                                    text: time.formatTime(row.player.length)
                                    color: Colors.palette().subtext0
                                    font.pixelSize: 15
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Item {
                                    Layout.fillWidth: true
                                }

                                Button {
                                    id: raise
                                    implicitWidth: 30
                                    implicitHeight: 30

                                    onClicked: {
                                        const window = Niri.windowFromName(row.player.desktopEntry);
                                        Niri.focusWindow(window);
                                        row.player.raise();
                                    }

                                    contentItem: Text {
                                        text: "󱂬"
                                        font.pixelSize: 15
                                        opacity: row.player.canRaise ? 1.0 : 0.3
                                        color: row.player.canRaise && raise.down ? Colors.palette().pink : Colors.palette().text
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    background: Rectangle {
                                        color: Colors.palette().surface0
                                        radius: 25
                                    }
                                }

                                Button {
                                    id: identity
                                    implicitWidth: 120
                                    implicitHeight: 30

                                    contentItem: Text {
                                        text: row.player.identity
                                        font.pixelSize: 15
                                        color: Colors.palette().text
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    background: Rectangle {
                                        color: Colors.palette().surface0
                                        radius: 25
                                    }
                                }

                                Button {
                                    id: trash
                                    implicitWidth: 30
                                    implicitHeight: 30

                                    onClicked: {
                                        row.player.quit();
                                    }

                                    contentItem: Text {
                                        text: ""
                                        font.pixelSize: 15
                                        opacity: row.player.canQuit ? 1.0 : 0.3
                                        color: row.player.canQuit && trash.down ? Colors.palette().pink : Colors.palette().text
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    background: Rectangle {
                                        color: Colors.palette().surface0
                                        radius: 25
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        AnimatedImage {
                            id: animated
                            playing: row.player.isPlaying
                            source: "https://i.pinimg.com/originals/b8/38/ed/b838ed9eead6ce4b448bc020883ec881.gif"
                            Layout.preferredHeight: 100
                            Layout.preferredWidth: 100
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }
            }

            Component {
                id: notifications

                Item {

                    Text {
                        visible: NotificationManager.server.trackedNotifications.count == 0
                        text: "No history notifications"
                    }

                    Rectangle {
                        color: Colors.palette().surface0
                        width: loader.width
                        height: loader.height
                        radius: 8

                        anchors.bottom: loader.bottom
                        anchors.top: loader.top

                        ScrollView {
                            id: scroll

                            width: parent.width - 8
                            height: parent.height - 25

                            anchors.centerIn: parent

                            ListView {
                                model: NotificationManager.server.trackedNotifications

                                clip: true

                                spacing: 16

                                delegate: Flickable {
                                    id: item
                                    required property var modelData

                                    property bool preview: item.modelData.hints["preview"] ? true : false
                                    property bool isExpanded: item.modelData.hints["preview"] ? false : false

                                    implicitHeight: 80
                                    implicitWidth: scroll.width - 20

                                    contentWidth: contentItem.childrenRect.width
                                    contentHeight: contentItem.childrenRect.height

                                    anchors.horizontalCenter: parent.horizontalCenter

                                    boundsMovement: Flickable.FollowBoundsBehavior
                                    boundsBehavior: Flickable.DragAndOvershootBounds

                                    opacity: Math.max(0.5, 1.0 - Math.abs(verticalOvershoot) / height)

                                    rebound: Transition {
                                        NumberAnimation {
                                            properties: "x,y"
                                            duration: 700
                                            easing.type: Easing.OutBounce
                                        }
                                    }

                                    flickableDirection: Flickable.HorizontalFlick

                                    Rectangle {
                                        id: rect

                                        radius: 8

                                        implicitWidth: parent.width
                                        implicitHeight: parent.height

                                        color: Colors.palette().surface2

                                        ColumnLayout {
                                            id: content
                                            spacing: 5
                                            anchors.fill: rect

                                            implicitHeight: childrenRect.height

                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            anchors.topMargin: 8
                                            anchors.bottomMargin: 8

                                            RowLayout {
                                                spacing: 10
                                                Layout.fillWidth: true

                                                Rectangle {
                                                    Layout.alignment: Qt.AlignTop
                                                    implicitWidth: 32
                                                    implicitHeight: 32
                                                    radius: 8
                                                    color: Colors.palette().surface1

                                                    IconImage {
                                                        id: sourceImage
                                                        anchors.centerIn: parent
                                                        width: 24
                                                        height: 24
                                                        source: item.preview ? Quickshell.iconPath(item.modelData.appIcon, "desktop") : (item.modelData.image && item.modelData.image.length > 0 ? item.modelData.image : Quickshell.iconPath(item.modelData.appIcon, "desktop"))
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    RowLayout {

                                                        Text {
                                                            text: item.isExpanded ? item.modelData.appName : item.modelData.summary
                                                            font.pixelSize: 14
                                                            font.weight: Font.Light
                                                            color: item.isExpanded ? Colors.palette().subtext0 : Colors.palette().text
                                                            elide: Text.ElideRight
                                                            Layout.fillWidth: false
                                                        }

                                                        Text {
                                                            font.pixelSize: 9
                                                            font.weight: Font.Medium
                                                            color: Colors.palette().subtext0
                                                            text: ""
                                                        }

                                                        Text {
                                                            font.pixelSize: 11
                                                            font.weight: Font.Medium
                                                            color: Colors.palette().subtext0
                                                            text: "now"
                                                        }

                                                        Text {
                                                            font.pixelSize: 11
                                                            color: Colors.palette().subtext0
                                                            Layout.fillWidth: true
                                                            horizontalAlignment: Text.AlignRight
                                                            text: item.isExpanded ? "" : ""
                                                        }
                                                    }

                                                    Text {
                                                        visible: item.isExpanded
                                                        text: item.modelData.summary
                                                        font.pixelSize: 14
                                                        font.weight: Font.Medium
                                                        color: Colors.palette().text
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: false
                                                    }

                                                    Text {
                                                        text: item.modelData.body
                                                        font.pixelSize: 12
                                                        color: Colors.palette().subtext0
                                                        wrapMode: Text.Wrap
                                                        Layout.fillWidth: true
                                                        maximumLineCount: item.isExpanded ? 20 : 1
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        visible: item.preview && !item.isExpanded
                                                        text: ""
                                                        font.pixelSize: 15
                                                        color: Colors.palette().text
                                                    }
                                                }
                                            }

                                            RowLayout {
                                                visible: item.modelData.actions.count > 0
                                                Layout.alignment: Qt.AlignCenter
                                                spacing: 8
                                                Repeater {
                                                    id: action
                                                    model: item.modelData.actions

                                                    delegate: Button {
                                                        id: boop
                                                        required property var modelData
                                                        required property var model

                                                        background: Rectangle {
                                                            implicitWidth: row.width
                                                            implicitHeight: row.height
                                                            color: Colors.palette().surface2
                                                            radius: 16
                                                        }

                                                        // onHoveredChanged: {
                                                        //     if (hovered)
                                                        //         noti.hoverCount++;
                                                        //     else
                                                        //         noti.hoverCount--;
                                                        // }

                                                        onClicked: {
                                                            NotificationManager.invokeAction(item.modelData.id, modelData.identifier);
                                                            // fadeOut.start();
                                                        }

                                                        RowLayout {
                                                            id: row
                                                            width: childrenRect.width + 8 * 2
                                                            height: childrenRect.height + 8 * 2

                                                            Text {
                                                                text: boop.modelData.text
                                                                color: Colors.palette().text
                                                                font.pixelSize: 11
                                                                Layout.fillWidth: true
                                                                horizontalAlignment: Text.AlignHCenter
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            ClippingRectangle {
                                                visible: item.preview && item.isExpanded

                                                implicitHeight: 150
                                                implicitWidth: 500
                                                Layout.fillWidth: false
                                                radius: 12
                                                clip: false
                                                antialiasing: true
                                                Image {
                                                    anchors.fill: parent
                                                    fillMode: Image.PreserveAspectCrop
                                                    source: item.modelData.image
                                                    sourceSize.width: parent.width
                                                    sourceSize.height: parent.height
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        Qt.openUrlExternally(item.modelData.image.replace("image://icon/", ""));
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
            }

            Component {
                id: performance

                Item {
                    Text {
                        text: "Gay"
                    }

                    CircularProgress {
                        value1: 0.8
                        value2: 0.9
                    }
                }
            }
        }
    }
}
