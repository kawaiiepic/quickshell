// The Wired — Quickshell Lockscreen (test mode: Enter to quit)
//
// Usage:
//   quickshell -c lockscreen.qml

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Quickshell.Services.Pam

import "../../theme"

Scope {
    id: root

    property bool locked: false
    property string unhashedPassword: ""

    IpcHandler {
        target: "lockscreen"

        function showLockscreen(): void {
            root.locked = true;
        }
    }

    PamContext {
        id: pam

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.unhashedPassword);
            }
        }

        onCompleted: result => {
			if (result == PamResult.Success) {
				root.unlocked();
			} else {
				root.currentText = "";
				root.showFailure = true;
			}
        
			root.unlockInProgress = false;
		}

    }

    WlSessionLock {
        id: lock

        locked: root.locked

        WlSessionLockSurface {
            id: surface

            onVisibleChanged: {
                if (surface.visible) {
                    btnLabelTimer.start();
                }
            }

            property string currentUser: ""

            function authenticate() {
                if (pwField.text.length === 0) {
                    btnLabel.setTextTemp("[ failed... ]", Colors.palette().red);
                    return;
                } else {
                    root.locked = false;
                }
            }

            Component.onCompleted: {
                pwField.forceActiveFocus();
            }

            Process {
                running: true
                command: ["whoami"]
                stdout: StdioCollector {
                    onStreamFinished: surface.currentUser = this.text.trim()
                }
            }

            Rectangle {
                id: rootRect
                anchors.fill: parent
                color: "#080c0a"

                Canvas {
                    id: gridCanvas
                    anchors.fill: parent
                    opacity: 0.07

                    property real offset: 0

                    NumberAnimation on offset {
                        from: 0
                        to: 40
                        duration: 14000
                        loops: Animation.Infinite
                        easing.type: Easing.Linear
                    }

                    onOffsetChanged: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.strokeStyle = "#00ffa0";
                        ctx.lineWidth = 0.5;
                        const step = 40;

                        // horizontal lines
                        for (let y = (offset % step); y < height + step; y += step) {
                            ctx.beginPath();
                            ctx.moveTo(0, y);
                            ctx.lineTo(width, y);
                            ctx.stroke();
                        }
                        // vertical lines
                        for (let x = 0; x < width + step; x += step) {
                            ctx.beginPath();
                            ctx.moveTo(x, 0);
                            ctx.lineTo(x, height);
                            ctx.stroke();
                        }
                    }
                }
            }

            // ── Scanlines ─────────────────────────────────────────────────────
            Canvas {
                anchors.fill: parent
                z: 5
                onPaint: {
                    var ctx = getContext("2d");
                    for (var y = 0; y < height; y += 4) {
                        ctx.fillStyle = '#041ef2a4';
                        ctx.fillRect(0, y + 2, width, 2);
                    }
                }
            }

            // ── Corner brackets ───────────────────────────────────────────────
            Canvas {
                anchors.fill: parent
                z: 6
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = "#6600ffa0";
                    ctx.lineWidth = 1;
                    var s = 22, m = 16;
                    ctx.beginPath();
                    ctx.moveTo(m, m + s);
                    ctx.lineTo(m, m);
                    ctx.lineTo(m + s, m);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(width - m - s, m);
                    ctx.lineTo(width - m, m);
                    ctx.lineTo(width - m, m + s);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(m, height - m - s);
                    ctx.lineTo(m, height - m);
                    ctx.lineTo(m + s, height - m);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(width - m - s, height - m);
                    ctx.lineTo(width - m, height - m);
                    ctx.lineTo(width - m, height - m - s);
                    ctx.stroke();
                }
            }

            // ── Main column ───────────────────────────────────────────────────
            ColumnLayout {
                anchors.centerIn: parent
                width: 380
                spacing: 0
                z: 10

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 8
                    text: ["  ██╗      █████╗ ██╗███╗   ██╗", "  ██║     ██╔══██╗██║████╗  ██║", "  ██║     ███████║██║██╔██╗ ██║", "  ██║     ██╔══██║██║██║╚██╗██║", "  ███████╗██║  ██║██║██║ ╚████║", "  ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝"].join("\n")
                    font.family: "monospace"
                    font.pixelSize: 11
                    font.letterSpacing: 2
                    color: "#6100ffa0"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation {
                            duration: 6500
                        }
                        NumberAnimation {
                            to: 0.15
                            duration: 80
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: 80
                        }
                        NumberAnimation {
                            to: 0.4
                            duration: 80
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: 80
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 8
                    text: "connected to the wired"
                    font.family: "monospace"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: "#4700ffa0"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 0.85
                            duration: 3000
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: 3000
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    // Layout.bottomMargin: 22
                    text: "present day, present time"
                    font.family: "monospace"
                    font.pixelSize: 10
                    font.letterSpacing: 3
                    color: "#4700ffa0"
                }

                Item {
                    width: clockText.width
                    height: clockText.height
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        id: clockText
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatTime(new Date(), "hh:mm")
                        font.family: "monospace"
                        font.pixelSize: 80
                        font.weight: Font.Light
                        font.letterSpacing: -1
                        color: "#00ffa0"
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.88
                                duration: 2800
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                to: 1.0
                                duration: 2800
                                easing.type: Easing.InOutSine
                            }
                        }
                    }

                    Glow {
                        anchors.fill: clockText
                        radius: 15
                        samples: 17
                        height: 0
                        color: '#1900ffa2'
                        source: clockText
                    }
                }

                Text {
                    id: dateText
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 28
                    text: Qt.formatDate(new Date(), "ddd / dd.MM.yyyy").toUpperCase()
                    font.family: "monospace"
                    font.pixelSize: 11
                    font.letterSpacing: 3
                    color: "#7300ffa0"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 20
                    height: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: "#0000ffa0"
                        }
                        GradientStop {
                            position: 0.5
                            color: "#5900ffa0"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#0000ffa0"
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 16
                    spacing: 10

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: "#00000000"
                        border.color: "#4d00ffa0"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "◈"
                            font.pixelSize: 12
                            color: "#8c00ffa0"
                        }
                    }
                    Text {
                        text: surface.currentUser + "@wired ~ layer_07"
                        font.family: "monospace"
                        font.pixelSize: 11
                        font.letterSpacing: 2
                        color: "#8c00ffa0"
                    }
                }

                // Password field
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 10
                    height: 44
                    color: "#00000000"
                    border.color: pwField.activeFocus ? "#a600ffa0" : "#3800ffa0"
                    border.width: 1
                    radius: 8

                    Text {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 14
                        }
                        text: "enter passphrase"
                        font.family: "monospace"
                        font.pixelSize: 13
                        color: "#3800ffa0"
                        visible: pwField.text.length === 0 && !pwField.activeFocus
                    }

                    TextInput {
                        id: pwField
                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 14
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        color: "#00ffa0"
                        font.family: "monospace"
                        font.pixelSize: 14
                        cursorVisible: activeFocus
                        cursorDelegate: Rectangle {
                            width: 2
                            height: 18
                            color: "#00ffa0"
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 0
                                    duration: 520
                                }
                                NumberAnimation {
                                    to: 1
                                    duration: 520
                                }
                            }
                        }
                        Keys.onReturnPressed: surface.authenticate()
                        Keys.onEscapePressed: text = ""
                    }
                }

                // Unlock button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 6
                    height: 42
                    color: btnMouse.containsMouse ? "#1200ffa0" : "#0000ffa0"
                    border.color: btnMouse.containsMouse ? "#9900ffa0" : "#4700ffa0"
                    border.width: 1
                    radius: 8
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    Text {
                        id: btnLabel
                        anchors.centerIn: parent
                        text: displayed
                        font.family: "monospace"
                        font.pixelSize: 12
                        font.letterSpacing: 5
                        color: btnMouse.containsMouse ? "#00ffa0" : "#a600ffa0"
                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        function setText(text: string) {
                            btnLabel.fullText = text;
                            btnLabel.displayed = "";
                            btnLabel.i = 0;
                            btnLabelTimer.start();
                        }

                        function setTextTemp(text: string, color: string) {
                            if (btnLabelColorTimer.running == false) {
                                btnLabelColorTimer.prevText = btnLabel.fullText;
                                btnLabelColorTimer.start();
                                btnLabel.color = color;
                                setText(text);
                            }
                        }

                        property string fullText: "[ authenticate ]"
                        property int i: 0

                        Timer {
                            id: btnLabelColorTimer

                            property string prevText: ""
                            interval: 2000
                            onTriggered: {
                                btnLabel.color = btnMouse.containsMouse ? "#00ffa0" : "#a600ffa0";
                                btnLabel.setText(prevText);
                            }
                        }

                        Timer {
                            id: btnLabelTimer
                            interval: 50
                            repeat: true
                            running: false
                            onTriggered: {
                                btnLabel.i++;
                                btnLabel.displayed = btnLabel.fullText.slice(0, btnLabel.i);
                                if (btnLabel.i >= btnLabel.fullText.length)
                                    stop();
                            }
                        }

                        property string displayed: ""
                    }

                    HoverHandler {
                        id: btnMouse
                    }
                    TapHandler {
                        onTapped: surface.authenticate()
                    }
                }
            }

            // ── Status bar ────────────────────────────────────────────────────
            RowLayout {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 25
                    bottomMargin: 22
                }
                z: 10

                Text {
                    text: "nwl_v2.3.1"
                    font.family: "monospace"
                    font.pixelSize: 10
                    font.letterSpacing: 2
                    color: "#4700ffa0"
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    id: pingText
                    text: "ping: --ms"
                    font.family: "monospace"
                    font.pixelSize: 10
                    font.letterSpacing: 2
                    color: "#4700ffa0"
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: "layer:07/active"
                    font.family: "monospace"
                    font.pixelSize: 10
                    font.letterSpacing: 2
                    color: "#4700ffa0"
                }
            }

            // ── Timers ────────────────────────────────────────────────────────
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    clockText.text = Qt.formatTime(new Date(), "hh:mm");
                    dateText.text = Qt.formatDate(new Date(), "ddd / dd.MM.yyyy").toUpperCase();
                }
            }
            Timer {
                interval: 3000
                running: true
                repeat: true
                onTriggered: pingText.text = "ping: " + (Math.floor(Math.random() * 28) + 4) + "ms"
            }
        }

        // WlSessionLockSurface {
        //     id: rect

        //     // visible: true
        //     // anchors.fill: parent
        //     WlrLayershell.layer: WlrLayer.Overlay
        //     WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        //     // exclusiveZone: -1
        //     WlrLayershell.namespace: "lockscreen"

        //     property string currentUser: ""

        //     Process {
        //         running: true
        //         command: ["whoami"]
        //         stdout: StdioCollector {
        //             onStreamFinished: rect.currentUser = this.text.trim()
        //         }
        //     }

        //     Component.onCompleted: {
        //         pwField.forceActiveFocus();
        //     }

        //     function authenticate() {
        //         if (pwField.text.length === 0) {
        //             btnLabel.setTextTemp("[ failed... ]", Colors.palette().red);
        //             return;
        //         } else {
        //             root.locked = false;
        //         }
        //     }

        //     Rectangle {
        //         id: rootRect
        //         anchors.fill: parent
        //         color: "#080c0a"

        //         Canvas {
        //             id: gridCanvas
        //             anchors.fill: parent
        //             opacity: 0.07

        //             property real offset: 0

        //             NumberAnimation on offset {
        //                 from: 0
        //                 to: 40
        //                 duration: 14000
        //                 loops: Animation.Infinite
        //                 easing.type: Easing.Linear
        //             }

        //             onOffsetChanged: requestPaint()

        //             onPaint: {
        //                 const ctx = getContext("2d");
        //                 ctx.clearRect(0, 0, width, height);
        //                 ctx.strokeStyle = "#00ffa0";
        //                 ctx.lineWidth = 0.5;
        //                 const step = 40;

        //                 // horizontal lines
        //                 for (let y = (offset % step); y < height + step; y += step) {
        //                     ctx.beginPath();
        //                     ctx.moveTo(0, y);
        //                     ctx.lineTo(width, y);
        //                     ctx.stroke();
        //                 }
        //                 // vertical lines
        //                 for (let x = 0; x < width + step; x += step) {
        //                     ctx.beginPath();
        //                     ctx.moveTo(x, 0);
        //                     ctx.lineTo(x, height);
        //                     ctx.stroke();
        //                 }
        //             }
        //         }

        //         // ── Glow orb ──────────────────────────────────────────────────────
        //         // Item {
        //         //     width: 380; height: 380
        //         //     anchors.horizontalCenter: parent.horizontalCenter
        //         //     anchors.verticalCenter:   parent.verticalCenter
        //         //     anchors.verticalCenterOffset: -40

        //         //     Rectangle {
        //         //         anchors.centerIn: parent
        //         //         width: 380; height: 380; radius: 190
        //         //         color: '#3707231a'
        //         //         SequentialAnimation on opacity {
        //         //             loops: Animation.Infinite
        //         //             NumberAnimation { to: 0.3; duration: 2500; easing.type: Easing.InOutSine }
        //         //             NumberAnimation { to: 0.1; duration: 2500; easing.type: Easing.InOutSine }
        //         //         }
        //         //     }
        //         //     Rectangle {
        //         //         anchors.centerIn: parent
        //         //         width: 240; height: 240; radius: 120
        //         //         color: "#0a3326"
        //         //         SequentialAnimation on opacity {
        //         //             loops: Animation.Infinite
        //         //             NumberAnimation { to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
        //         //             NumberAnimation { to: 0.1; duration: 2000; easing.type: Easing.InOutSine }
        //         //         }
        //         //     }
        //         //     Rectangle {
        //         //         anchors.centerIn: parent
        //         //         width: 100; height: 100; radius: 50
        //         //         color: "#00ffa0"
        //         //         SequentialAnimation on opacity {
        //         //             loops: Animation.Infinite
        //         //             NumberAnimation { to: 0.3; duration: 1800; easing.type: Easing.InOutSine }
        //         //             NumberAnimation { to: 0.1; duration: 1800; easing.type: Easing.InOutSine }
        //         //         }
        //         //     }
        //         // }

        //         // ── Scanlines ─────────────────────────────────────────────────────
        //         Canvas {
        //             anchors.fill: parent
        //             z: 5
        //             onPaint: {
        //                 var ctx = getContext("2d");
        //                 for (var y = 0; y < height; y += 4) {
        //                     ctx.fillStyle = '#041ef2a4';
        //                     ctx.fillRect(0, y + 2, width, 2);
        //                 }
        //             }
        //         }

        //         // ── Corner brackets ───────────────────────────────────────────────
        //         Canvas {
        //             anchors.fill: parent
        //             z: 6
        //             onPaint: {
        //                 var ctx = getContext("2d");
        //                 ctx.strokeStyle = "#6600ffa0";
        //                 ctx.lineWidth = 1;
        //                 var s = 22, m = 16;
        //                 ctx.beginPath();
        //                 ctx.moveTo(m, m + s);
        //                 ctx.lineTo(m, m);
        //                 ctx.lineTo(m + s, m);
        //                 ctx.stroke();
        //                 ctx.beginPath();
        //                 ctx.moveTo(width - m - s, m);
        //                 ctx.lineTo(width - m, m);
        //                 ctx.lineTo(width - m, m + s);
        //                 ctx.stroke();
        //                 ctx.beginPath();
        //                 ctx.moveTo(m, height - m - s);
        //                 ctx.lineTo(m, height - m);
        //                 ctx.lineTo(m + s, height - m);
        //                 ctx.stroke();
        //                 ctx.beginPath();
        //                 ctx.moveTo(width - m - s, height - m);
        //                 ctx.lineTo(width - m, height - m);
        //                 ctx.lineTo(width - m, height - m - s);
        //                 ctx.stroke();
        //             }
        //         }

        //         // ── Main column ───────────────────────────────────────────────────
        //         ColumnLayout {
        //             anchors.centerIn: parent
        //             width: 380
        //             spacing: 0
        //             z: 10

        //             Text {
        //                 Layout.alignment: Qt.AlignHCenter
        //                 Layout.bottomMargin: 8
        //                 text: ["  ██╗      █████╗ ██╗███╗   ██╗", "  ██║     ██╔══██╗██║████╗  ██║", "  ██║     ███████║██║██╔██╗ ██║", "  ██║     ██╔══██║██║██║╚██╗██║", "  ███████╗██║  ██║██║██║ ╚████║", "  ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝"].join("\n")
        //                 font.family: "monospace"
        //                 font.pixelSize: 11
        //                 font.letterSpacing: 2
        //                 color: "#6100ffa0"
        //                 SequentialAnimation on opacity {
        //                     loops: Animation.Infinite
        //                     PauseAnimation {
        //                         duration: 6500
        //                     }
        //                     NumberAnimation {
        //                         to: 0.15
        //                         duration: 80
        //                     }
        //                     NumberAnimation {
        //                         to: 1.0
        //                         duration: 80
        //                     }
        //                     NumberAnimation {
        //                         to: 0.4
        //                         duration: 80
        //                     }
        //                     NumberAnimation {
        //                         to: 1.0
        //                         duration: 80
        //                     }
        //                 }
        //             }

        //             Text {
        //                 Layout.alignment: Qt.AlignHCenter
        //                 Layout.bottomMargin: 8
        //                 text: "connected to the wired"
        //                 font.family: "monospace"
        //                 font.pixelSize: 12
        //                 font.weight: Font.Bold
        //                 color: "#4700ffa0"
        //                 SequentialAnimation on opacity {
        //                     loops: Animation.Infinite
        //                     NumberAnimation {
        //                         to: 0.85
        //                         duration: 3000
        //                         easing.type: Easing.InOutSine
        //                     }
        //                     NumberAnimation {
        //                         to: 1.0
        //                         duration: 3000
        //                         easing.type: Easing.InOutSine
        //                     }
        //                 }
        //             }

        //             Text {
        //                 Layout.alignment: Qt.AlignHCenter
        //                 // Layout.bottomMargin: 22
        //                 text: "present day, present time"
        //                 font.family: "monospace"
        //                 font.pixelSize: 10
        //                 font.letterSpacing: 3
        //                 color: "#4700ffa0"
        //             }

        //             Item {
        //                 width: clockText.width
        //                 height: clockText.height
        //                 Layout.alignment: Qt.AlignHCenter

        //                 Text {
        //                     id: clockText
        //                     Layout.alignment: Qt.AlignHCenter
        //                     text: Qt.formatTime(new Date(), "hh:mm")
        //                     font.family: "monospace"
        //                     font.pixelSize: 80
        //                     font.weight: Font.Light
        //                     font.letterSpacing: -1
        //                     color: "#00ffa0"
        //                     SequentialAnimation on opacity {
        //                         loops: Animation.Infinite
        //                         NumberAnimation {
        //                             to: 0.88
        //                             duration: 2800
        //                             easing.type: Easing.InOutSine
        //                         }
        //                         NumberAnimation {
        //                             to: 1.0
        //                             duration: 2800
        //                             easing.type: Easing.InOutSine
        //                         }
        //                     }
        //                 }

        //                 Glow {
        //                     anchors.fill: clockText
        //                     radius: 15
        //                     samples: 17
        //                     height: 0
        //                     color: '#1900ffa2'
        //                     source: clockText
        //                 }
        //             }

        //             Text {
        //                 id: dateText
        //                 Layout.alignment: Qt.AlignHCenter
        //                 Layout.bottomMargin: 28
        //                 text: Qt.formatDate(new Date(), "ddd / dd.MM.yyyy").toUpperCase()
        //                 font.family: "monospace"
        //                 font.pixelSize: 11
        //                 font.letterSpacing: 3
        //                 color: "#7300ffa0"
        //             }

        //             Rectangle {
        //                 Layout.fillWidth: true
        //                 Layout.bottomMargin: 20
        //                 height: 1
        //                 gradient: Gradient {
        //                     orientation: Gradient.Horizontal
        //                     GradientStop {
        //                         position: 0.0
        //                         color: "#0000ffa0"
        //                     }
        //                     GradientStop {
        //                         position: 0.5
        //                         color: "#5900ffa0"
        //                     }
        //                     GradientStop {
        //                         position: 1.0
        //                         color: "#0000ffa0"
        //                     }
        //                 }
        //             }

        //             RowLayout {
        //                 Layout.alignment: Qt.AlignHCenter
        //                 Layout.bottomMargin: 16
        //                 spacing: 10

        //                 Rectangle {
        //                     width: 28
        //                     height: 28
        //                     radius: 14
        //                     color: "#00000000"
        //                     border.color: "#4d00ffa0"
        //                     border.width: 1
        //                     Text {
        //                         anchors.centerIn: parent
        //                         text: "◈"
        //                         font.pixelSize: 12
        //                         color: "#8c00ffa0"
        //                     }
        //                 }
        //                 Text {
        //                     text: root.currentUser + "@wired ~ layer_07"
        //                     font.family: "monospace"
        //                     font.pixelSize: 11
        //                     font.letterSpacing: 2
        //                     color: "#8c00ffa0"
        //                 }
        //             }

        //             // Password field
        //             Rectangle {
        //                 Layout.fillWidth: true
        //                 Layout.bottomMargin: 10
        //                 height: 44
        //                 color: "#00000000"
        //                 border.color: pwField.activeFocus ? "#a600ffa0" : "#3800ffa0"
        //                 border.width: 1
        //                 radius: 8

        //                 Text {
        //                     anchors {
        //                         verticalCenter: parent.verticalCenter
        //                         left: parent.left
        //                         leftMargin: 14
        //                     }
        //                     text: "enter passphrase"
        //                     font.family: "monospace"
        //                     font.pixelSize: 13
        //                     color: "#3800ffa0"
        //                     visible: pwField.text.length === 0 && !pwField.activeFocus
        //                 }

        //                 TextInput {
        //                     id: pwField
        //                     anchors {
        //                         fill: parent
        //                         leftMargin: 14
        //                         rightMargin: 14
        //                     }
        //                     verticalAlignment: TextInput.AlignVCenter
        //                     echoMode: TextInput.Password
        //                     passwordCharacter: "•"
        //                     color: "#00ffa0"
        //                     font.family: "monospace"
        //                     font.pixelSize: 14
        //                     cursorVisible: activeFocus
        //                     cursorDelegate: Rectangle {
        //                         width: 2
        //                         height: 18
        //                         color: "#00ffa0"
        //                         SequentialAnimation on opacity {
        //                             loops: Animation.Infinite
        //                             NumberAnimation {
        //                                 to: 0
        //                                 duration: 520
        //                             }
        //                             NumberAnimation {
        //                                 to: 1
        //                                 duration: 520
        //                             }
        //                         }
        //                     }
        //                     Keys.onReturnPressed: root.authenticate()
        //                     Keys.onEscapePressed: text = ""
        //                 }
        //             }

        //             // Unlock button
        //             Rectangle {
        //                 Layout.fillWidth: true
        //                 Layout.bottomMargin: 6
        //                 height: 42
        //                 color: btnMouse.containsMouse ? "#1200ffa0" : "#0000ffa0"
        //                 border.color: btnMouse.containsMouse ? "#9900ffa0" : "#4700ffa0"
        //                 border.width: 1
        //                 radius: 8
        //                 Behavior on color {
        //                     ColorAnimation {
        //                         duration: 120
        //                     }
        //                 }
        //                 Behavior on border.color {
        //                     ColorAnimation {
        //                         duration: 120
        //                     }
        //                 }

        //                 Text {
        //                     id: btnLabel
        //                     anchors.centerIn: parent
        //                     text: displayed
        //                     font.family: "monospace"
        //                     font.pixelSize: 12
        //                     font.letterSpacing: 5
        //                     color: btnMouse.containsMouse ? "#00ffa0" : "#a600ffa0"
        //                     Behavior on color {
        //                         ColorAnimation {
        //                             duration: 120
        //                         }
        //                     }

        //                     function setText(text: string) {
        //                         btnLabel.fullText = text;
        //                         btnLabel.displayed = "";
        //                         btnLabel.i = 0;
        //                         btnLabelTimer.start();
        //                     }

        //                     function setTextTemp(text: string, color: string) {
        //                         if (btnLabelColorTimer.running == false) {
        //                             btnLabelColorTimer.prevText = btnLabel.fullText;
        //                             btnLabelColorTimer.start();
        //                             btnLabel.color = color;
        //                             setText(text);
        //                         }
        //                     }

        //                     property string fullText: "[ authenticate ]"
        //                     property int i: 0

        //                     Timer {
        //                         id: btnLabelColorTimer

        //                         property string prevText: ""
        //                         interval: 2000
        //                         onTriggered: {
        //                             btnLabel.color = btnMouse.containsMouse ? "#00ffa0" : "#a600ffa0";
        //                             btnLabel.setText(prevText);
        //                         }
        //                     }

        //                     Timer {
        //                         id: btnLabelTimer
        //                         interval: 50
        //                         repeat: true
        //                         running: false
        //                         onTriggered: {
        //                             btnLabel.i++;
        //                             btnLabel.displayed = btnLabel.fullText.slice(0, btnLabel.i);
        //                             if (btnLabel.i >= btnLabel.fullText.length)
        //                                 stop();
        //                         }
        //                     }

        //                     property string displayed: ""
        //                 }

        //                 HoverHandler {
        //                     id: btnMouse
        //                 }
        //                 TapHandler {
        //                     onTapped: root.authenticate()
        //                 }
        //             }
        //         }

        //         // ── Status bar ────────────────────────────────────────────────────
        //         RowLayout {
        //             anchors {
        //                 bottom: parent.bottom
        //                 left: parent.left
        //                 right: parent.right
        //                 margins: 25
        //                 bottomMargin: 22
        //             }
        //             z: 10

        //             Text {
        //                 text: "nwl_v2.3.1"
        //                 font.family: "monospace"
        //                 font.pixelSize: 10
        //                 font.letterSpacing: 2
        //                 color: "#4700ffa0"
        //             }
        //             Item {
        //                 Layout.fillWidth: true
        //             }
        //             Text {
        //                 id: pingText
        //                 text: "ping: --ms"
        //                 font.family: "monospace"
        //                 font.pixelSize: 10
        //                 font.letterSpacing: 2
        //                 color: "#4700ffa0"
        //             }
        //             Item {
        //                 Layout.fillWidth: true
        //             }
        //             Text {
        //                 text: "layer:07/active"
        //                 font.family: "monospace"
        //                 font.pixelSize: 10
        //                 font.letterSpacing: 2
        //                 color: "#4700ffa0"
        //             }
        //         }

        //         // ── Timers ────────────────────────────────────────────────────────
        //         Timer {
        //             interval: 1000
        //             running: true
        //             repeat: true
        //             onTriggered: {
        //                 clockText.text = Qt.formatTime(new Date(), "hh:mm");
        //                 dateText.text = Qt.formatDate(new Date(), "ddd / dd.MM.yyyy").toUpperCase();
        //             }
        //         }
        //         Timer {
        //             interval: 3000
        //             running: true
        //             repeat: true
        //             onTriggered: pingText.text = "ping: " + (Math.floor(Math.random() * 28) + 4) + "ms"
        //         }
        //     }
        // }
    }
}
