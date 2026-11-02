import QtQuick
import QtQuick.Controls
import ".."

AbstractButton {
    id: button
    property string symbol: ""
    property string label: ""
    property bool highlighted: false
    implicitWidth: label ? Math.min(150, caption.implicitWidth + Theme.space4) : Theme.controlSize
    implicitHeight: Theme.controlSize
    hoverEnabled: true
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
