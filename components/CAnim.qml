import qs.config
import QtQuick

ColorAnimation {
    duration: 200
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.curves.standard
}