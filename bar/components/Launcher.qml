import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    color: "transparent"
    implicitWidth: 23
    implicitHeight: 23

    Image {
        id: imageInstance
        source: "/home/mia/.face"
        anchors.centerIn: parent
        property int radius: 20
        width: 23
        height: 23
        visible: true

        layer.enabled: true
        layer.effect: OpacityMask {
            id: opacityMaskInstance
            maskSource: Rectangle {
                id: maskedRect
                width: imageInstance.width
                height: imageInstance.height
                radius: imageInstance.radius
            }
        }
    }
}
