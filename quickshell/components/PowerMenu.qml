import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

FocusScope {
    id: powerContent
    property int focusedIndex: -1
    implicitHeight: menuColumn.implicitHeight + 24
    function takeFocus() {
        const first = actionRepeater.itemAt(0)
        if (first) first.forceActiveFocus()
        else forceActiveFocus()
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
            id: actionRepeater
            model: PowerMenuState.actions

            delegate: AbstractButton {
                id: actionButton
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                hoverEnabled: true
                Accessible.name: modelData.label
                onActiveFocusChanged: if (activeFocus) powerContent.focusedIndex = index
                onClicked: PowerMenuState.requestAction(modelData.id)
                Keys.onDownPressed: event => {
                    actionRepeater.itemAt((index + 1) % actionRepeater.count).forceActiveFocus()
                    event.accepted = true
                }
                Keys.onUpPressed: event => {
                    actionRepeater.itemAt((index - 1 + actionRepeater.count) % actionRepeater.count).forceActiveFocus()
                    event.accepted = true
                }
                background: Rectangle {
                    radius: Theme.radiusMedium
                    color: actionButton.down ? Qt.alpha(Theme.colAccent, 0.25) :
                        actionButton.hovered || actionButton.activeFocus ? Qt.alpha(Theme.colBorder, 0.6) : Qt.alpha(Theme.colSurfaceRaised, 0.4)
                    border.width: PowerMenuState.confirmAction === actionButton.modelData.id || actionButton.activeFocus ? 1 : 0
                    border.color: Theme.colAccent
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                }

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

            }
        }

        NotificationButton {
            Layout.alignment: Qt.AlignHCenter
            label: "Close · Esc"
            onClicked: PowerMenuState.close()
        }
    }
}
