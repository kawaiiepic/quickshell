import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 300
    height: 280
    color: "transparent"

    ListModel {
        id: taskModel
        ListElement { label: "respond to mails"; done: true  }
        ListElement { label: "review PR #42";    done: false }
        ListElement { label: "finish quickshell theme"; done: false }
        ListElement { label: "gym";              done: false }
        ListElement { label: "groceries";        done: false }
    }

    Rectangle {
        anchors.fill: parent
        color: "#09080f"
        radius: 10
        border.color: "#2d1f4e"
        border.width: 1
        clip: true

        Rectangle {
            anchors.fill: parent
            color: "#1a0533"
            opacity: 0.4
            radius: 10
        }

        Rectangle { x: 8; y: 8; width: 10; height: 1; color: "#a855f7"; opacity: 0.7 }
        Rectangle { x: 8; y: 8; width: 1; height: 10; color: "#a855f7"; opacity: 0.7 }
        Rectangle { x: parent.width - 18; y: parent.height - 9;  width: 10; height: 1; color: "#ec4899"; opacity: 0.7 }
        Rectangle { x: parent.width - 9;  y: parent.height - 18; width: 1;  height: 10; color: "#ec4899"; opacity: 0.7 }

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "transparent" }
                GradientStop { position: 0.35; color: "#a855f7" }
                GradientStop { position: 0.65; color: "#ec4899" }
                GradientStop { position: 1.0;  color: "transparent" }
            }
        }

        Repeater {
            model: Math.ceil(root.height / 4)
            delegate: Rectangle {
                x: 0; y: index * 4
                width: root.width; height: 2
                color: "#000000"; opacity: 0.1
            }
        }

        ColumnLayout {
            anchors { fill: parent; margins: 18 }
            spacing: 0

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "TASKS"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.letterSpacing: 3
                    font.weight: Font.Medium
                    color: "#4a3570"
                }

                Item { Layout.fillWidth: true }

                // Add button
                Rectangle {
                    width: 16; height: 16; radius: 8
                    color: addHover.containsMouse ? "#2d1f4e" : "transparent"
                    border.color: "#3d2a5e"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        color: addHover.containsMouse ? "#c084fc" : "#4a3570"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        id: addHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: taskModel.append({ label: "new task", done: false })
                    }
                }
            }

            Item { Layout.preferredHeight: 14 }

            // ── Task list ─────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: taskModel

                    delegate: Item {
                        Layout.fillWidth: true
                        height: 36

                        // Hover highlight
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -4
                            radius: 4
                            color: rowHover.containsMouse ? "#1c1030" : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10

                            // Checkbox
                            Rectangle {
                                width: 14; height: 14; radius: 3
                                color: done ? "#7c3aed" : "transparent"
                                border.color: done ? "#a855f7" : "#3d2a5e"
                                border.width: 1
                                Behavior on color { ColorAnimation { duration: 150 } }

                                // Checkmark
                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    color: "#f0e6ff"
                                    visible: done
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: taskModel.setProperty(index, "done", !done)
                                }
                            }

                            // Label
                            Text {
                                text: label
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                color: done ? "#3d2a5e" : "#c4b5d4"
                                font.strikeout: done
                                Layout.fillWidth: true
                                elide: Text.ElideRight

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            // Delete on hover
                            Text {
                                text: "×"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                color: delHover.containsMouse ? "#ec4899" : "#2d1f4e"
                                visible: rowHover.containsMouse || delHover.containsMouse
                                Behavior on color { ColorAnimation { duration: 120 } }

                                MouseArea {
                                    id: delHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: taskModel.remove(index)
                                }
                            }
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onClicked: (m) => m.accepted = false
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // ── Footer count ──────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2d1f4e"
                opacity: 0.6
            }

            Item { Layout.preferredHeight: 10 }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: {
                        var done = 0
                        for (var i = 0; i < taskModel.count; i++)
                            if (taskModel.get(i).done) done++
                        return done + " / " + taskModel.count + " done"
                    }
                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.letterSpacing: 1.5
                    color: "#4a3570"
                }

                Item { Layout.fillWidth: true }

                // Progress pip row
                Row {
                    spacing: 3
                    Repeater {
                        model: taskModel.count
                        delegate: Rectangle {
                            width: 6; height: 6; radius: 3
                            color: {
                                if (index < taskModel.count && taskModel.get(index).done)
                                    return "#a855f7"
                                return "#1c1030"
                            }
                            border.color: "#2d1f4e"
                            border.width: 1
                        }
                    }
                }
            }
        }
    }
}