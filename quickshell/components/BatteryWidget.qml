import QtQuick
import Quickshell.Io
import ".."

Item {
    id: batteryWidget
    visible: hasBattery

    implicitWidth: 24
    implicitHeight: 24

    property int batteryLevel: 0
    property bool charging: false
    property bool hasBattery: false
    property bool hovered: false
    property string batteryStatus: "Unknown"
    property string iconName: charging ? "battery_charging_full" :
                              batteryLevel >= 90 ? "battery_full" :
                              batteryLevel >= 60 ? "battery_6_bar" :
                              batteryLevel >= 30 ? "battery_4_bar" :
                              batteryLevel > 10 ? "battery_2_bar" : "battery_alert"
    property string hoverText: "Battery · " + batteryLevel + "% · " + batteryStatus

    FontLoader {
        id: materialSymbolsFont
        source: "/etc/nixos/fonts/MaterialSymbolsRounded.ttf"
    }

    Process {
        id: batteryProc
        property string output: ""
        command: ["sh", "-c", "for battery in /sys/class/power_supply/BAT*/capacity; do cat \"$battery\"; exit; done"]

        stdout: SplitParser {
            onRead: data => batteryProc.output += data
        }

        onRunningChanged: {
            if (running) {
                output = ""
            } else {
                var capacity = output.trim()
                batteryWidget.hasBattery = capacity !== ""
                if (batteryWidget.hasBattery) batteryWidget.batteryLevel = parseInt(capacity) || 0
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: statusProc
        property string output: ""
        command: ["sh", "-c", "for battery in /sys/class/power_supply/BAT*/status; do cat \"$battery\"; exit; done"]

        stdout: SplitParser {
            onRead: data => statusProc.output += data
        }

        onRunningChanged: {
            if (running) {
                output = ""
            } else {
                var status = output.trim()
                batteryWidget.batteryStatus = status || "Unknown"
                batteryWidget.charging = status === "Charging" || status === "Full"
            }
        }

        Component.onCompleted: running = true
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: {
            if (!batteryProc.running) batteryProc.running = true
            if (!statusProc.running) statusProc.running = true
        }
    }

    Text {
        id: batteryIcon
        anchors.centerIn: parent
        text: batteryWidget.iconName
        font.family: materialSymbolsFont.name || Theme.iconFontFamily
        font.pixelSize: 19
        font.weight: Font.Normal
        color: Theme.colFg
        visible: batteryWidget.hasBattery
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: batteryWidget.batteryLevel <= 15 ? 0.7 : 1
    }

    MouseArea {
        id: batteryMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: batteryWidget.hovered = true
        onExited: batteryWidget.hovered = false
    }

    HoverTooltip {
        anchors.right: parent.right
        anchors.top: parent.bottom
        anchors.topMargin: 6
        label: batteryWidget.hasBattery ? batteryWidget.hoverText : "Battery · not detected"
        shown: batteryWidget.hovered && batteryWidget.hasBattery
    }
}