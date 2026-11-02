import QtQuick
import Quickshell.Io
import ".."
import Quickshell.Wayland

Item {

    property string outputName: ""

    id: powerButton

    implicitWidth: 28
    implicitHeight: 28

    FontLoader {
        id: materialSymbolsFont
        source: "/etc/nixos/fonts/MaterialSymbolsRounded.ttf"
    }

    MouseArea {
        id: powerMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            PowerMenuState.toggle(outputName)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: powerMouse.containsMouse ? Qt.alpha(Theme.colBorder, 0.5) : "transparent"
        border.width: powerMouse.containsMouse ? 1 : 0
        border.color: Qt.alpha(Theme.colBorder, 0.7)

        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }

    Text {
        id: powerIcon
        anchors.centerIn: parent
        text: "power_settings_new"
        font.family: materialSymbolsFont.name || Theme.iconFontFamily
        font.pixelSize: 18
        font.weight: Font.Normal
        color: Theme.colFg
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on opacity {
            NumberAnimation { duration: Theme.motionFast }
        }
    }
}