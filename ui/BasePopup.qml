import QtQuick.Layouts
import QtQuick
import Quickshell
import QtQuick.Controls
import Quickshell.Wayland

import "../ui"
import "../services"

PanelWindow {
    id: root
    visible: root.show

    default property alias contentChildren: contentLayout.data

    property int hoverCount: 0
    property bool logicallyHovered: hoverCount > 0
    property bool show: false

    onLogicallyHoveredChanged: {
        if (logicallyHovered) {
            autoCloseTimer.stop();
            show = true;
        } else {
            autoCloseTimer.restart();
        }
    }

    property Item parentItem
    property BasePopup parentPopup

    anchors {
        left: true
        top: true
        right: true
        bottom: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay

    Timer {
        id: autoCloseTimer
        interval: Anim.long1
        repeat: false

        onTriggered: {
            if (!root.logicallyHovered) {
                root.show = false;
                root.hoverCount = 0;
            }
        }
    }

    function hoverUpdate(delta) {
        hoverCount += delta;
    }

    HoverHandler {
        parent: root.parentItem

        onHoveredChanged: {
            root.hoverUpdate(hovered ? 1 : -1);
        }
    }

    Popup {
        id: popup
        visible: root.show
        modal: true
        focus: true
        clip: true

        x: -2

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
            }
        }

        onClosed: {
            root.show = false;
            root.hoverCount = 0;
        }

        function recalculateY() {
            var y = root.parentItem.mapToGlobal(0, 0).y;
            var screenHeight = root.screen.height;
            var totalHeight = y + popup.height;
            var padding = 25;

            if (totalHeight > (screenHeight)) {
                y = y - (totalHeight - screenHeight + padding);
            }
            popup.y = y - padding;
        }

        onHeightChanged: recalculateY()

        onWindowChanged: recalculateY()

        HoverHandler {
            id: popupHover
            cursorShape: Qt.PointingHandCursor

            onHoveredChanged: {
                root.hoverUpdate(hovered ? 1 : -1);
                root.parentPopup?.hoverUpdate(hovered ? 1 : 0);
            }
        }

        background: Rectangle {
            color: "transparent"
        }

        contentItem: StyledRect {
            parentWindow: root
            show: root.show
            pos: "left"
            cornerSize: 26
            implicitWidth: control.implicitWidth
            implicitHeight: control.implicitHeight

            Control {
                id: control
                // anchors.fill: parent
                padding: 10

                contentItem: ColumnLayout {
                    id: contentLayout
                }
            }
        }
    }
}
