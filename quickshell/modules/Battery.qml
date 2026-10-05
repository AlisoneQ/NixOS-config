import Quickshell.Services.UPower
import QtQuick

Text {
    property string prefix: "BAT "

    text: prefix + Math.round(UPower.displayDevice.percentage) + "%"

    font.pixelSize: 15
}
