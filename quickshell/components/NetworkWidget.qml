import QtQuick
import Quickshell.Io
import ".."

Item {
    id: networkWidget

    implicitWidth: 24
    implicitHeight: 24

    property string connectionKind: "offline"
    property string connectionName: ""
    property int signalStrength: 0
    property bool hovered: false
    property string iconName: connectionKind === "ethernet" ? "cable" :
                             connectionKind !== "wifi" ? "wifi_off" :
                             signalStrength >= 80 ? "wifi" :
                             signalStrength >= 55 ? "wifi_2_bar" :
                             signalStrength >= 30 ? "wifi_1_bar" : "wifi_0_bar"
    property real iconOpacity: connectionKind === "wifi" ? Math.max(0.45, signalStrength / 100) :
                               connectionKind === "offline" ? 0.55 : 1
    property string hoverText: connectionKind === "ethernet" ?
                               (connectionName ? "Ethernet · " + connectionName : "Ethernet · Connected") :
                               connectionKind === "wifi" ? "Wi-Fi · " + signalStrength + "%" :
                               "Network · Offline"

    FontLoader {
        id: materialSymbolsFont
        source: "/etc/nixos/fonts/MaterialSymbolsRounded.ttf"
    }

    Process {
        id: networkProc
        property string output: ""
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device; nmcli -t -f IN-USE,SIGNAL,SSID device wifi"]

        stdout: SplitParser {
            onRead: data => networkProc.output += data + "\n"
        }

        onRunningChanged: {
            if (running) {
                output = ""
                return
            }

            var nextKind = "offline"
            var nextName = ""
            var nextSignal = 0
            var lines = output.trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts.length >= 2 && parts[0] === "ethernet" && parts[1] === "connected") {
                    nextKind = "ethernet"
                    nextName = parts.length >= 3 ? parts[2] : ""
                    break
                }
                if (parts.length >= 2 && parts[0] === "wifi" && parts[1] === "connected") {
                    nextKind = "wifi"
                    nextName = parts.length >= 3 ? parts[2] : ""
                }
                if (parts.length >= 2 && parts[0] === "yes") {
                    nextSignal = parseInt(parts[1]) || 0
                }
            }
            networkWidget.connectionKind = nextKind
            networkWidget.connectionName = nextName
            networkWidget.signalStrength = nextSignal
        }

        Component.onCompleted: running = true
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            if (!networkProc.running) networkProc.running = true
        }
    }

    Text {
        id: networkIcon
        anchors.centerIn: parent
        text: networkWidget.iconName
        font.family: materialSymbolsFont.name || Theme.iconFontFamily
        font.pixelSize: 19
        font.weight: Font.Normal
        color: Theme.colFg
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: networkWidget.iconOpacity

        Behavior on opacity {
            NumberAnimation { duration: Theme.motionFast }
        }
    }

    MouseArea {
        id: networkMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: networkWidget.hovered = true
        onExited: networkWidget.hovered = false
    }

    HoverTooltip {
        anchors.right: parent.right
        anchors.top: parent.bottom
        anchors.topMargin: 6
        label: networkWidget.hoverText
        shown: networkWidget.hovered
    }
}
