import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Item {
    id: card
    property var record: null
    property bool compact: false
    implicitHeight: content.implicitHeight + 24

    RowLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10
        Item {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignTop
            Image {
                id: icon
                anchors.fill: parent
                sourceSize: Qt.size(30, 30)
                fillMode: Image.PreserveAspectFit
                property string name: card.record ? card.record.appIcon : ""
                source: !name ? "" : name.startsWith("/") ? "file://" + name :
                        name.startsWith("file:") ? name : Quickshell.iconPath(name, true)
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: !icon.visible
                text: card.record && card.record.critical ? "priority_high" : "notifications"
                color: card.record && card.record.critical ? Theme.colDanger : Theme.colAccent
                font.family: Theme.iconFontFamily
                font.pixelSize: 22
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: card.record ? card.record.appName : ""
                    textFormat: Text.PlainText
                    color: card.record && card.record.critical ? Theme.colDanger : Theme.colMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    elide: Text.ElideRight
                }
                Text {
                    text: card.record ? Qt.formatDateTime(new Date(card.record.timestamp), "HH:mm") : ""
                    color: Theme.colMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                }
                NotificationButton {
                    symbol: "close"
                    label: "Dismiss notification"
                    onClicked: NotificationState.dismissHistory(card.record)
                }
            }
            Text {
                Layout.fillWidth: true
                text: card.record ? card.record.summary : ""
                textFormat: Text.PlainText
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
                maximumLineCount: 2
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.record ? card.record.body : ""
                textFormat: Text.PlainText
                color: Theme.colFg
                opacity: 0.8
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                wrapMode: Text.Wrap
                maximumLineCount: card.compact ? 2 : 5
                elide: Text.ElideRight
            }
            Flow {
                Layout.fillWidth: true
                spacing: 4
                visible: !!card.record && card.record.actions.length > 0
                Repeater {
                    model: card.record ? card.record.actions : []
                    NotificationButton {
                        required property var modelData
                        label: modelData.text || "Open"
                        highlighted: true
                        onClicked: NotificationState.invoke(card.record, modelData.identifier)
                    }
                }
            }
        }
    }
}
