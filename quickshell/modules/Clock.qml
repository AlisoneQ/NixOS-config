import Quickshell
import QtQuick

Text {
    property string format: "HH:mm"

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, format)

    font.pixelSize: 15
}
