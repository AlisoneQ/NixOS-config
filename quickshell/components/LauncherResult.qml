import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import ".."

Rectangle {
    id: resultRow

    required property var entry
    required property int resultIndex
    property bool selected: LauncherState.selectedIndex === resultIndex

    height: 52
    radius: 8
    color: selected ? Qt.alpha(Theme.colAccent, 0.22) : "transparent"
    border.width: selected ? 1 : 0
    border.color: Qt.alpha(Theme.colAccent, 0.65)

    Behavior on color {
        ColorAnimation { duration: Theme.motionFast }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        IconImage {
            source: Quickshell.iconPath(resultRow.entry.icon || "application-x-executable")
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: resultRow.entry.name || resultRow.entry.id
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: resultRow.entry.genericName || resultRow.entry.comment || ""
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideRight
            }
        }

        Text {
            text: resultRow.selected ? "Enter" : ""
            color: Theme.colMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: LauncherState.selectedIndex = resultRow.resultIndex
        onClicked: {
            LauncherState.selectedIndex = resultRow.resultIndex
            LauncherState.activateSelected()
        }
    }
}
