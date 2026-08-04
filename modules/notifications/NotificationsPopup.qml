pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQml
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.Notifications

import "../../services"
import "../../theme"
import "../../ui"

BaseOverlay {
    id: notifications

    visible: NotificationManager.popupNotifications.count > 0

    dismissable: false

    implicitWidth: column.width
    implicitHeight: column.height

    anchorRight: true

    StyledRect {
        parentWindow: parent
        pos: "top-right"

        implicitHeight: column.height
        implicitWidth: column.width

        Column {
            id: column
            spacing: 5
            padding: 8

            height: childrenRect.height + 50
            width: childrenRect.width + 30

            Repeater {
                id: repeater
                model: NotificationManager.popupNotifications

                delegate: Flickable {
                    id: root

                    required property var model
                    required property int id
                    required property string summary
                    required property string body
                    required property var expireTimeout
                    required property var image
                    required property var hints
                    required property var appIcon
                    required property var appName
                    required property var actions

                    required property int index

                    implicitWidth: noti.width
                    implicitHeight: noti.height

                    // anchors.horizontalCenter: parent.horizontalCenter

                    opacity: Math.max(0.5, 1.0 - Math.abs(verticalOvershoot) / height)
                    rebound: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 700
                            easing.type: Easing.OutBounce
                        }
                    }

                    flickableDirection: scrollingHorizontally ? Flickable.HorizontalFlick : (scrollingVertically ? Flickable.VerticalFlick : Flickable.HorizontalAndVerticalFlick)

                    readonly property bool scrollingHorizontally: draggingHorizontally && !draggingVertically
                    readonly property bool scrollingVertically: draggingVertically && !draggingHorizontally

                    onFlickStarted: {
                        if (flickingHorizontally) {
                            fadeOut.start();
                        } else {
                            if (verticalOvershoot > 0) {
                                if (noti.isExpanded) {
                                    noti.isExpanded = false;
                                }
                            } else {
                                if (!noti.isExpanded) {
                                    noti.isExpanded = true;
                                }
                            }
                        }
                    }

                    function removeSelf() {
                        for (var i = 0; i < NotificationManager.popupNotifications.count; i++) {
                            var item = NotificationManager.popupNotifications.get(i);
                            if (item.id === root.id) { // unique identifier
                                NotificationManager.popupNotifications.remove(i, 1);  // stop after removing one item
                                break;
                            }
                        }
                    }

                    Rectangle {
                        id: noti
                        property real elapsed: 0
                        property real duration: (root.expireTimeout == -1 ? 8 : root.expireTimeout) * 1000
                        property bool preview: root.hints["preview"] ? true : false
                        property bool isExpanded: root.hints["preview"] ? true : false
                        property int hoverCount: 0
                        property bool paused: hoverCount > 0

                        width: content.width + 20
                        height: content.height + 20

                        radius: 14
                        color: Colors.palette().surface0
                        border.color: Colors.palette().crust
                        border.width: 1

                        opacity: 0

                        Component.onCompleted: {
                            opacity = 1;
                            y = 0;
                        }

                        MouseArea {
                            id: hoverMouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: noti.isExpanded = !noti.isExpanded

                            onEntered: noti.hoverCount++
                            onExited: noti.hoverCount--
                        }

                        // Entrance animation
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 1000
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutCubic
                            }
                        }

                        Timer {
                            interval: 16
                            running: true
                            repeat: true

                            onTriggered: {
                                if (!noti.paused) {
                                    noti.elapsed += interval;
                                    progressBar.value = noti.elapsed / noti.duration;

                                    if (progressBar.value >= 1.0) {
                                        fadeOut.start();
                                    }
                                }
                            }
                        }

                        SequentialAnimation {
                            id: fadeOut
                            PropertyAnimation {
                                target: noti
                                property: "opacity"
                                to: 0
                                duration: 260
                            }
                            ScriptAction {
                                script: root.removeSelf()
                            }
                        }

                        ColumnLayout {
                            id: content
                            anchors.centerIn: parent
                            width: 300
                            spacing: 5

                            RowLayout {
                                spacing: 10

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
                                        source: noti.preview ? Quickshell.iconPath(root.appIcon, "desktop") : (root.image && root.image.length > 0 ? root.image : Quickshell.iconPath(root.appIcon, "desktop"))
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    RowLayout {

                                        Text {
                                            text: noti.isExpanded ? root.appName : root.summary
                                            font.pixelSize: 11
                                            font.weight: Font.Light
                                            color: noti.isExpanded ? Colors.palette().subtext0 : Colors.palette().text
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
                                            Layout.alignment: Qt.AlignRight
                                            horizontalAlignment: Text.AlignRight
                                            text: noti.isExpanded ? "" : ""
                                        }
                                    }

                                    Text {
                                        visible: noti.isExpanded
                                        text: root.summary
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: Colors.palette().text
                                        elide: Text.ElideRight
                                        Layout.fillWidth: false
                                    }

                                    Text {
                                        text: root.body
                                        font.pixelSize: 11
                                        color: Colors.palette().subtext0
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                        maximumLineCount: noti.isExpanded ? 20 : 1
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: noti.preview && !noti.isExpanded
                                        text: ""
                                        font.pixelSize: 15
                                        color: Colors.palette().text
                                    }
                                }
                            }

                            RowLayout {
                                visible: root.actions.count > 0
                                Layout.alignment: Qt.AlignCenter
                                spacing: 8
                                Repeater {
                                    id: action
                                    model: root.actions

                                    delegate: Button {
                                        id: btn
                                        required property var modelData
                                        required property var model

                                        background: Rectangle {
                                            implicitWidth: row.width
                                            implicitHeight: row.height
                                            color: Colors.palette().surface2
                                            radius: 16
                                        }

                                        onHoveredChanged: {
                                            if (hovered)
                                                noti.hoverCount++;
                                            else
                                                noti.hoverCount--;
                                        }

                                        onClicked: {
                                            print("Clicked: " + modelData.text);
                                            NotificationManager.invokeAction(root.id, modelData.identifier);
                                            fadeOut.start();
                                        }

                                        RowLayout {
                                            id: row
                                            width: childrenRect.width + 8 * 2
                                            height: childrenRect.height + 8 * 2

                                            Text {
                                                text: btn.modelData.text
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
                                visible: noti.preview && noti.isExpanded

                                implicitHeight: 150
                                Layout.fillWidth: true
                                radius: 8
                                clip: false
                                antialiasing: true
                                AnimatedImage {
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    source: root.image.replace("image://icon/", "")
                                    onStatusChanged: playing = (status == AnimatedImage.Ready)
                                    sourceSize.width: parent.width
                                    sourceSize.height: parent.height
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        Qt.openUrlExternally(root.image.replace("image://icon/", ""));
                                    }
                                }
                            }

                            ProgressBar {
                                id: progressBar
                                Layout.fillWidth: true

                                implicitHeight: 3
                                value: 0
                            }
                        }
                    }
                }
            }
        }
    }
}
