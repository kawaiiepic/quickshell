import Quickshell // for PanelWindow
import Quickshell.Io
import Quickshell.Wayland
import QtQuick // for Text
import Qt5Compat.GraphicalEffects
import "./colors"

    PanelWindow {
      id: wallpaper
      implicitHeight: 20
      anchors {
        top: true
        left: true
        right: true
      }
      // WlrLayershell.layer: WlrLayer.
      // WlrLayershell.namespace: "wallpaper"
      aboveWindows: false
      color: "transparent"

    // Rectangle {
    //   width: parent.width
    //   height: parent.height
    //   anchors.centerIn: parent
    //   color: "transparent"
    //   radius: 20
    //   border.width: 10
    //   border.color: "purple"


//       Image {
//     id: imageInstance
//     anchors.centerIn: parent
//     property int radius: 20

//     width: parent.width - 20
//     height: parent.height - 20

//     source: "/home/mia/Downloads/2d0bb8230016eb3480cc5728b7caca08.jpg"
//     fillMode: Image.PreserveAspectCrop
//     layer.enabled: true
//     layer.effect: OpacityMask {
//         id: opacityMaskInstance
//         maskSource: Rectangle {
//             id: maskedRect
//             width: imageInstance.width
//             height: imageInstance.height
//             radius: imageInstance.radius
//             border.width: 20
//             border.color: "#ffffff40"
//         }
//     }
// }
    // }

    }
