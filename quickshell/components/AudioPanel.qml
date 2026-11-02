import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

FocusScope {
    id: panel
    implicitHeight: 188

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: "Audio"
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.DemiBold
            }
            NotificationButton { symbol: "close"; label: "Close audio controls"; onClicked: AudioState.closePanel() }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "volume_up"; color: Theme.colAccent; font.family: Theme.iconFontFamily; font.pixelSize: 18 }
            AudioSlider {
                id: outputSlider
                Layout.fillWidth: true
                from: 0
                to: AudioState.maxVolume
                value: AudioState.outputVolume
                enabled: !!AudioState.outputDevice && AudioState.outputDevice.ready
                Accessible.name: "Output volume"
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
            AudioSlider {
                Layout.fillWidth: true
                from: 0
                to: AudioState.maxVolume
                value: AudioState.inputVolume
                enabled: !!AudioState.inputDevice && AudioState.inputDevice.ready
                Accessible.name: "Microphone volume"
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
        }
    }
}
