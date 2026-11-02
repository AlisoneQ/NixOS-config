import QtQuick
import ".."

Column {
    id: clockColumn

    spacing: 0

    Text {
        id: clockText

        text: Qt.formatDateTime(new Date(), "HH:mm")
        color: Theme.colClock
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
        font.weight: Font.DemiBold
        renderType: Text.NativeRendering

        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: dateText

        text: Qt.formatDateTime(new Date(), "ddd d MMM")
        color: Theme.colMuted
        font.pixelSize: Theme.fontSize - 4
        font.family: Theme.fontFamily
        font.weight: Font.Normal
        renderType: Text.NativeRendering

        anchors.horizontalCenter: parent.horizontalCenter
    }

    Timer {
        interval: 30000
        running: true
        repeat: true

        onTriggered: {
            const now = new Date()
            clockText.text = Qt.formatDateTime(now, "HH:mm")
            dateText.text = Qt.formatDateTime(now, "ddd d MMM")
        }
    }
}