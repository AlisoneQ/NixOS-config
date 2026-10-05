import Quickshell.WindowManager
import QtQuick

Row {
    property var targetScreen

    spacing: 5

    Repeater {
        model: WindowManager.screenProjection(targetScreen).windowsets

        Rectangle {
            required property var modelData

            width: 26
            height: 24
            radius: 6

            color: modelData.active
                ? "#ffffff"
                : modelData.urgent
                    ? "#aa5555"
                    : "#444444"

            Text {
                anchors.centerIn: parent

                text: modelData.name

                color: modelData.active
                    ? "#202020"
                    : "#ffffff"

                font.pixelSize: 13
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (modelData.canActivate)
                        modelData.activate()
                }
            }
        }
    }
}