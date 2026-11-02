import QtQuick
import QtQuick.Controls
import ".."

Slider {
    id: control
    implicitWidth: 180
    implicitHeight: Theme.controlSize
    padding: 6
    hoverEnabled: true
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.colBorder
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: control.enabled ? Theme.colAccent : Theme.colMuted
        }
    }
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 12
        height: 12
        radius: 6
        color: control.pressed ? Theme.colAccent : Theme.colFg
        border.width: control.activeFocus ? 2 : 0
        border.color: Theme.colAccent
        scale: control.pressed || control.hovered ? 1.15 : 1
        Behavior on scale { NumberAnimation { duration: Theme.motionFast; easing.type: Theme.easing } }
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }
}
