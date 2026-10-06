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
    property bool clipboardEntry: entry.kind === "clipboard"
    property bool hovered: resultMouse.containsMouse

    height: 54
    radius: 11
    color: selected ? Qt.alpha(Theme.colAccent, 0.18) :
                      (hovered ? Qt.alpha(Theme.colBorder, 0.34) : "transparent")
    border.width: selected ? 1 : 0
    border.color: Qt.alpha(Theme.colAccent, 0.58)

    Behavior on color {
        ColorAnimation { duration: Theme.motionFast }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 11

        Rectangle {
            Layout.preferredWidth: 2
            Layout.preferredHeight: 22
            radius: 1
            color: Theme.colAccent
            visible: resultRow.selected
        }

        IconImage {
            visible: !resultRow.clipboardEntry
            source: Quickshell.iconPath(resultRow.entry.icon || "application-x-executable")
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
        }

        Text {
            visible: resultRow.clipboardEntry
            text: "⧉"
            color: Theme.colAccent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 8
            Layout.preferredWidth: 28
            horizontalAlignment: Text.AlignHCenter
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
                text: resultRow.clipboardEntry ? "Clipboard" : (resultRow.entry.genericName || resultRow.entry.comment || "")
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideRight
            }
        }

        Text {
            text: resultRow.selected ? (resultRow.clipboardEntry ? "Copy" : "Open") : ""
            color: resultRow.selected ? Theme.colAccent : Theme.colMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
        }
    }

    MouseArea {
        id: resultMouse
        anchors.fill: parent
        hoverEnabled: true
        onEntered: LauncherState.selectedIndex = resultRow.resultIndex
        onClicked: {
            LauncherState.selectedIndex = resultRow.resultIndex
            LauncherState.activateSelected()
        }
    }
}
