import QtQuick
import ".."

Text {
    id: clockText
    text: Qt.formatDateTime(new Date(), "HH:mm")
    color: Theme.colClock
    font.pixelSize: Theme.fontSize
    font.family: Theme.fontFamily
    font.bold: true
    renderType: Text.NativeRendering
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
    }
}
