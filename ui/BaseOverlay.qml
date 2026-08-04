import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    property alias margins: main.margins
    property alias anchors: container.anchors
    property alias implicitHeight: main.implicitHeight
    property alias implicitWidth: main.implicitWidth
    // property alias visible: main.visible
    property alias color: main.color
    property alias exclusionMode: main.exclusionMode
    property alias screen: main.screen

    property bool anchorTop: false
    property bool anchorRight: false
    property bool anchorBottom: false
    property bool anchorLeft: false
    property bool horizontalCenter: false
    property bool verticalCenter: false

    property bool visible

    property bool dismissable: true
    property bool clickable: true

    signal requestClose

    // exclusionMode: ExclusionMode.Ignore

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
            to: 1
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

        mask: root.dismissable ? null : root.clickable ? focusRoot : noMask

        Region {
            id: noMask
        }

        Region {
            id: focusRoot
            item: container
        }

        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        focusable: root.clickable

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

            // anchors.right: parent.right
            anchors.top: root.anchorTop ? parent.top : undefined
            anchors.right: root.anchorRight ? parent.right : undefined
            anchors.bottom: root.anchorBottom ? parent.bottom : undefined
            anchors.left: root.anchorLeft ? parent.left : undefined
            anchors.horizontalCenter: root.horizontalCenter ? parent.horizontalCenter : undefined
            anchors.verticalCenter: root.verticalCenter ? parent.verticalCenter : undefined
            width: childrenRect.width
            height: childrenRect.height
        }
    }
}
