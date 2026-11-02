import QtQuick
import QtQuick.Controls
import ".."

AbstractButton {
    id: button
    property string symbol: ""
    property string label: ""
    property bool highlighted: false
    implicitWidth: label ? Math.min(150, caption.implicitWidth + 20) : 28
    implicitHeight: 28
    hoverEnabled: true
    background: Rectangle {
        radius: 8
        color: button.hovered || button.activeFocus ? Qt.alpha(Theme.colAccent, 0.22) : "transparent"
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
