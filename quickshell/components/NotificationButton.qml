import QtQuick
import QtQuick.Controls
import ".."

AbstractButton {
    id: button
    property string symbol: ""
    property string label: ""
    property bool highlighted: false
    implicitWidth: symbol ? Theme.controlSize : Math.min(180, caption.implicitWidth + Theme.space4)
    implicitHeight: Theme.controlSize
    hoverEnabled: true
    scale: down ? 0.94 : 1
    Behavior on scale { NumberAnimation { duration: Theme.motionFast; easing.type: Theme.easing } }
    background: Rectangle {
        radius: Theme.radiusSmall
        color: button.highlighted ? Qt.alpha(Theme.colAccent, 0.18) :
               (button.hovered || button.activeFocus ? Qt.alpha(Theme.colBorder, 0.46) : Qt.alpha(Theme.colSurfaceRaised, 0.18))
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }
    contentItem: Text {
        id: caption
        text: button.symbol || button.label
        textFormat: Text.PlainText
        color: button.highlighted ? Theme.colAccent : Theme.colFg
        font.family: button.symbol ? Theme.iconFontFamily : Theme.fontFamily
        font.pixelSize: button.symbol ? 19 : Theme.fontSize - 2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    Accessible.name: label
    ToolTip.visible: hovered && label !== "" && symbol !== ""
    ToolTip.text: label
    ToolTip.delay: 600
}
