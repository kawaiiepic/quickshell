pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell
import QtQuick.Controls

import "../../../ui"
import "../../../theme"

Rectangle {
    id: root
    property ShellScreen screen

    color: Colors.palette().surface0
    radius: 10

    width: parent.width
    height: column.height

    Column {
        id: column
        spacing: 4
        topPadding: 4
        bottomPadding: 4
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: item
                required property SystemTrayItem modelData
                enabled: true

                implicitHeight: icon.height
                implicitWidth: icon.width

                BasePopup {
                    id: popup
                    parentItem: root
                    screen: root.screen

                    QsMenuOpener {
                        id: opener
                        menu: item.modelData.menu
                    }

                    Repeater {

                        model: opener.children

                        delegate: Item {
                            id: entry
                            implicitHeight: childrenRect.height
                            implicitWidth: btn.width

                            required property QsMenuEntry modelData

                            MenuSeparator {
                                visible: entry.modelData.isSeparator
                                topPadding: entry.modelData.isSeparator ? 5 : 0
                                bottomPadding: entry.modelData.isSeparator ? 5 : 0

                                contentItem: Rectangle {
                                    implicitWidth: 50
                                    implicitHeight: 2

                                    anchors.centerIn: parent
                                    radius: 20
                                    color: Colors.palette().text
                                }
                            }

                            Button {
                                id: btn
                                visible: !entry.modelData.isSeparator
                                width: 200
                                height: row.height

                                onClicked: {
                                    entry.modelData.triggered();
                                }

                                background: Rectangle {
                                    color: Colors.transparent(Colors.palette().surface0, 0.25)
                                    radius: 8
                                }

                                RowLayout {
                                    id: row
                                    Image {
                                        source: entry.modelData.icon
                                        sourceSize.width: width
                                        sourceSize.height: height
                                    }

                                    Text {
                                        text: entry.modelData.text
                                        color: entry.modelData.enabled ? btn.hovered ? Colors.palette().text : Colors.palette().subtext1 : Colors.palette().subtext0
                                    }

                                    CheckBox {
                                        visible: entry.modelData.buttonType == QsMenuButtonType.CheckBox
                                    }

                                    RadioButton {
                                        visible: entry.modelData.buttonType == QsMenuButtonType.RadioButton
                                    }
                                }
                            }
                        }
                    }
                }

                Image {
                    id: icon
                    width: 15
                    height: 15
                    source: item.modelData.icon
                }
            }
        }
    }
}
