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
        id: clickable
        color: "red"

        visible: root.visible && root.dismissable

        // WlrLayershell.layer: WlrLayer.Overlay
        // exclusionMode: ExclusionMode.Ignore

        focusable: root.dismissable

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        Item {
            id: focusRoot
            focus: false

            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    print("Clicked!!!");
                    closeAnim.start();
                }
            }
            Keys.onEscapePressed: {
                closeAnim.start();
            }
        }
    }

    PanelWindow {
        id: main

        color: "transparent"

        visible: root.visible

        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        Item {
            id: container
            anchors.fill: parent
            opacity: 0
        }
    }
}
