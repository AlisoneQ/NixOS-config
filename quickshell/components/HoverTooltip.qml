import QtQuick
import ".."

Rectangle {
    id: tooltip

    // Shared tooltip surface for compact status widgets.

    required property string label
    property bool shown: false

    width: tooltipText.implicitWidth + 20
    height: tooltipText.implicitHeight + 12
    radius: 7
    color: Theme.colTooltip
    border.width: 1
    border.color: Theme.colBorder
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.94
    visible: opacity > 0
    z: 20

    Behavior on opacity {
        NumberAnimation { duration: Theme.motionFast }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.motionFast
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: tooltipText
        anchors.centerIn: parent
        text: tooltip.label
        color: Theme.colFg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        maximumLineCount: 1
    }
}
