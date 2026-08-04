import Quickshell
import QtQuick
import Quickshell.Wayland

import "../../ui"
import "../../services"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

    PanelWindow {
        id: item

        required property var modelData

        screen: modelData
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        mask: overlayLoader.item ? null : noMask

        Region {
            id: noMask
        }

        MouseArea {
            anchors.fill: parent

            onPressed: {
                overlayLoader.item.closeAnimated();
            }
        }
    }

    PanelWindow {
        required property var modelData

        screen: modelData
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore

        color: "transparent"
        anchors {
            top: true
        }

        implicitWidth: screen.width / 10
        implicitHeight: 2

        Rectangle {
            color: "transparent"
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    overlayLoader.source = "TopControl.qml";
                }
            }
        }
    }

    PanelWindow {
        required property var modelData

        screen: modelData
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore
        anchors {
            bottom: true
        }

        color: "transparent"

        implicitWidth: screen.width / 10
        implicitHeight: 2

        Rectangle {
            color: "transparent"
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    GlobalData.showDock = true;
                }
            }
        }
    }

    }

    Loader {
        id: overlayLoader
        onLoaded: {
            overlayLoader.item.requestClose.connect(() => {
                overlayLoader.source = "";
            });
        }
    }
}
