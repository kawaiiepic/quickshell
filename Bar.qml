// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import Qt5Compat.GraphicalEffects
import "./colors"

Scope {
  id: root
  property string time

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      color: Color.palette().base

      anchors {
        top: true
        left: true
        bottom:  true
      }

      implicitWidth: 30

      Column {
    spacing: 12
    anchors.horizontalCenter: parent.horizontalCenter

    Rectangle {
        width: 24
        height: 24
        radius: 22
        clip: true   // THIS makes the image round
        color: "transparent"

        Image {
            id: imageInstance
            anchors.fill: parent
            source: "file:///home/mia/.face"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            layer.enabled: true
            layer.effect: OpacityMask {
        id: opacityMaskInstance
        maskSource: Rectangle {
            id: maskedRect
            width: 24
            height: 24
            radius: 50
            border.width: 20
            border.color: "#ffffff40"
        }
    }
        }
    }
}

    }
  }
}