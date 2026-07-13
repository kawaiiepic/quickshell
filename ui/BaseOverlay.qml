import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    property alias margins: main.margins
    property alias anchors: main.anchors
    property alias implicitHeight: main.implicitHeight
    property alias implicitWidth: main.implicitWidth
    // property alias visible: main.visible
    property alias color: main.color
    property alias exclusionMode: main.exclusionMode
    property alias screen: main.screen

    property bool visible

    property bool dismissable: true

    signal requestClose

    // exclusionMode: ExclusionMode.Ignore

    onVisibleChanged: {
        if (visible) {
            print("Animation starting...");
            openAnim.start();
        }
    }

    onRequestClose: {
        print("closed!!");
    }

    default property alias content: container.data

    SequentialAnimation {
        id: openAnim

        NumberAnimation {
            target: container
            property: "opacity"
            to: 1
            duration: 500
        }
    }

    SequentialAnimation {
        id: closeAnim

        NumberAnimation {
            target: container
            property: "opacity"
            to: 0
            duration: 500
        }

        ScriptAction {
            script: root.requestClose()
        }
    }

    PanelWindow {
        id: main

        color: "transparent"

        visible: root.visible

        mask: root.dismissable ? null : noMask

        Region {
            id: noMask
        }

        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        focusable: root.dismissable

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        Item {
            id: focusRoot2

            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.dismissable) {
                        print("Clicked!!!");
                        closeAnim.start();
                    }
                }
            }
            Keys.onEscapePressed: {
                if (root.dismissable)
                    closeAnim.start();
            }
        }

        Item {
            id: container
            anchors.fill: parent
            opacity: 0
        }
    }
}
