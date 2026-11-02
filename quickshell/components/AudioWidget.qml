import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: widget
    implicitWidth: Theme.controlSize
    implicitHeight: Theme.controlSize

    property string iconName: AudioState.outputMuted ? "volume_off" :
                              AudioState.outputVolume <= 0.01 ? "volume_mute" :
                              AudioState.outputVolume < 0.45 ? "volume_down" : "volume_up"

    Behavior on implicitWidth { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: audioMouse.containsMouse ? Qt.alpha(Theme.colBorder, 0.46) : Qt.alpha(Theme.colSurfaceRaised, 0.18)
        border.width: audioMouse.containsMouse ? 1 : 0
        border.color: Qt.alpha(Theme.colBorder, 0.7)
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }

    Row {
        anchors.centerIn: parent
        spacing: 3
        Text {
            text: widget.iconName
            color: AudioState.outputMuted ? Theme.colDanger : Theme.colFg
            font.family: Theme.iconFontFamily
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: audioMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton) AudioState.toggleOutputMute()
            else AudioState.togglePanel()
        }
        onWheel: event => {
            AudioState.adjustOutputVolume(event.angleDelta.y > 0 ? AudioState.volumeStep : -AudioState.volumeStep)
            event.accepted = true
        }
    }

    HoverTooltip {
        anchors.right: parent.right
        anchors.top: parent.bottom
        anchors.topMargin: 6
        label: AudioState.outputMuted ? "Audio · muted" : "Audio · " + Math.round(AudioState.outputVolume * 100) + "%"
        shown: audioMouse.containsMouse && !AudioState.panelOpen
    }
}
