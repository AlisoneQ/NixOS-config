import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

FocusScope {
    id: center
    Keys.onEscapePressed: NotificationState.closeHistory()
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space3
        spacing: Theme.space2
        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: "Notifications"
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.DemiBold
            }
            NotificationButton {
                symbol: NotificationState.dnd ? "notifications_off" : "notifications"
                label: NotificationState.dnd ? "Disable do not disturb" : "Enable do not disturb"
                highlighted: NotificationState.dnd
                onClicked: NotificationState.toggleDnd()
            }
            NotificationButton { symbol: "delete_sweep"; label: "Clear all"; onClicked: NotificationState.clearHistory() }
            NotificationButton { symbol: "close"; label: "Close history"; onClicked: NotificationState.closeHistory() }
        }
        Text {
            visible: NotificationState.dnd
            text: "Do not disturb · saved quietly in history"
            color: Theme.colAccent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                anchors.centerIn: parent
                visible: NotificationState.history.length === 0
                text: "No notifications yet"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 6
                model: NotificationState.history
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    required property var modelData
                    width: list.width - 12
                    height: card.implicitHeight
                    color: Qt.alpha(Theme.colSurfaceRaised, 0.72)
                    radius: Theme.radiusMedium
                    NotificationCard { id: card; width: parent.width; record: modelData }
                }
            }
        }
    }
}
