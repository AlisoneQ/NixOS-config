import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Rectangle {
    id: panel
    width: 330
    height: 154
    radius: 12
    color: Qt.alpha(Theme.colTooltip, 0.98)
    border.width: 1
    border.color: Theme.colBorder

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text { text: "volume_up"; color: Theme.colAccent; font.family: Theme.iconFontFamily; font.pixelSize: 18 }
            Slider {
                id: outputSlider
                Layout.fillWidth: true
                from: 0
                to: AudioState.maxVolume
                value: AudioState.outputVolume
                onMoved: AudioState.setOutputVolume(value)
            }
            Text { text: Math.round(AudioState.outputVolume * 100) + "%"; color: Theme.colFg; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2; Layout.preferredWidth: 34 }
            NotificationButton {
                symbol: AudioState.outputMuted ? "volume_off" : "volume_up"
                label: AudioState.outputMuted ? "Unmute output" : "Mute output"
                highlighted: AudioState.outputMuted
                onClicked: AudioState.toggleOutputMute()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "mic"; color: Theme.colAccent; font.family: Theme.iconFontFamily; font.pixelSize: 18 }
            Slider {
                Layout.fillWidth: true
                from: 0
                to: AudioState.maxVolume
                value: AudioState.inputVolume
                onMoved: AudioState.setInputVolume(value)
            }
            Text { text: Math.round(AudioState.inputVolume * 100) + "%"; color: Theme.colFg; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2; Layout.preferredWidth: 34 }
            NotificationButton {
                symbol: AudioState.inputMuted ? "mic_off" : "mic"
                label: AudioState.inputMuted ? "Unmute microphone" : "Mute microphone"
                highlighted: AudioState.inputMuted
                onClicked: AudioState.toggleInputMute()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; text: AudioState.outputDevice ? (AudioState.outputDevice.description || "Default output") : "No output device"; color: Theme.colMuted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2; elide: Text.ElideRight }
            NotificationButton { symbol: "close"; label: "Close audio controls"; onClicked: AudioState.closePanel() }
        }
    }
}
