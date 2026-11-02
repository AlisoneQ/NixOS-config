import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: powerMenuWindow

    property string outputName: ""
    visible: PowerMenuState.open && (PowerMenuState.targetOutput === "" || PowerMenuState.targetOutput === outputName)
    color: "transparent"
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell:niri-power-menu"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }

    onVisibleChanged: if (visible) focusTimer.restart()

    Timer {
        id: focusTimer
        interval: 20
        repeat: false
        onTriggered: menuCard.forceActiveFocus()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.46)

        MouseArea {
            anchors.fill: parent
            onClicked: PowerMenuState.close()
        }
    }

    Rectangle {
        id: menuCard
        width: Math.min(360, parent.width - 40)
        height: menuColumn.implicitHeight + 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(72, parent.height * 0.18)
        radius: Theme.radiusLarge
        color: Qt.alpha(Theme.colSurface, Theme.panelOpacity)
        border.width: 1
        border.color: Qt.alpha(Theme.colBorder, 0.92)
        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.985

        Behavior on opacity { NumberAnimation { duration: Theme.motionContent; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: Theme.motionContent; easing.type: Easing.OutCubic } }
        focus: visible

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                PowerMenuState.close()
                event.accepted = true
            }
        }

        ColumnLayout {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: PowerMenuState.confirmAction === "" ? "Session" : "Confirm " + actionLabel(PowerMenuState.confirmAction) + "?"
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter

                function actionLabel(actionId) {
                    for (var i = 0; i < PowerMenuState.actions.length; i++) {
                        if (PowerMenuState.actions[i].id === actionId)
                            return PowerMenuState.actions[i].label.toLowerCase()
                    }
                    return "action"
                }
            }

            Text {
                Layout.fillWidth: true
                visible: PowerMenuState.confirmAction !== ""
                text: "Select the action again to continue"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                horizontalAlignment: Text.AlignHCenter
            }

            Repeater {
                model: PowerMenuState.actions

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: Theme.radiusMedium
                    color: powerMouse.containsMouse ? Qt.alpha(Theme.colBorder, 0.46) : Qt.alpha(Theme.colSurfaceRaised, 0.2)
                    border.width: PowerMenuState.confirmAction === modelData.id ? 1 : 0
                    border.color: Qt.alpha(Theme.colAccent, 0.7)

                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.icon
                        color: modelData.id === "poweroff" ? Theme.colDanger : Theme.colFg
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 19
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 48
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: PowerMenuState.requestAction(modelData.id)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "Esc close"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
