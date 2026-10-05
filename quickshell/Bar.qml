import Quickshell
import QtQuick
import qs.modules

PanelWindow {
    property var barScreen

    screen: barScreen

    anchors {
        top: true
    }

    implicitWidth: 300
    implicitHeight: 35

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        color: "#202020"

        bottomLeftRadius: 12
        bottomRightRadius: 12

        Row {
            anchors.centerIn: parent
            spacing: 15

            Workspaces {
                targetScreen: barScreen
            }

            Clock {
                format: "HH:mm"
            }

            Wifi {}

            Battery {}
        }
    }
}