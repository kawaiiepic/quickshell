import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    color: "transparent"
    implicitWidth: 25
    implicitHeight: 25

    Image {
        id: imageInstance
        source: "/home/mia/.face"
        anchors.centerIn: parent
        property int radius: 20
        width: 25
        height: 25
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
