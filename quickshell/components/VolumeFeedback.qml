import QtQuick
import QtQuick.Layouts
import ".."

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space4
        spacing: Theme.space2
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: AudioState.outputMuted ? "volume_off" : "volume_up"
                font.family: Theme.iconFontFamily
                font.pixelSize: 22
                color: Theme.colAccent
            }
            Text {
                Layout.fillWidth: true
                text: AudioState.outputMuted ? "Muted" : "Volume"
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
            Text {
                text: Math.round(AudioState.outputVolume * 100) + "%"
                color: Theme.colAccent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 3
            radius: 1.5
            color: Theme.colBorder
            Rectangle {
                width: parent.width * Math.min(1, AudioState.outputVolume / AudioState.maxVolume)
                height: parent.height
                radius: parent.radius
                color: AudioState.outputMuted ? Theme.colMuted : Theme.colAccent
                Behavior on width { NumberAnimation { duration: Theme.motionFast; easing.type: Theme.easing } }
            }
        }
    }
}
