import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: launcherWindow

    property string outputName: ""
    visible: LauncherState.open && (LauncherState.targetOutput === "" || LauncherState.targetOutput === outputName)
    color: "transparent"
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell:niri-launcher"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    onVisibleChanged: {
        if (visible) focusTimer.restart()
    }

    Timer {
        id: focusTimer
        interval: 20
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.32)

        MouseArea {
            anchors.fill: parent
            onClicked: LauncherState.close()
        }
    }

    Rectangle {
        id: launcherCard
        width: Math.min(620, parent.width - 40)
        height: Math.min(640, Math.max(94, contentLayout.implicitHeight + 20))
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(70, parent.height * 0.16)
        radius: 12
        color: Theme.colBg
        border.width: 1
        border.color: Theme.colBorder

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                LauncherState.close()
                event.accepted = true
            }
        }

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            TextField {
                id: searchInput
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                focus: true
                placeholderText: "Search applications"
                text: LauncherState.query
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                selectionColor: Theme.colAccent
                selectedTextColor: Theme.colBg

                background: Rectangle {
                    radius: 8
                    color: Theme.colTooltip
                    border.width: 1
                    border.color: searchInput.activeFocus ? Theme.colAccent : Theme.colBorder
                }

                onTextEdited: LauncherState.query = text

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        LauncherState.close()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        LauncherState.moveSelection(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        LauncherState.moveSelection(-1)
                        event.accepted = true
                    }
                }

                onAccepted: LauncherState.activateSelected()
            }

            Text {
                Layout.fillWidth: true
                visible: LauncherState.results.length === 0
                text: "No applications found"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                horizontalAlignment: Text.AlignHCenter
                topPadding: 12
                bottomPadding: 12
            }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 520)
                visible: LauncherState.results.length > 0
                clip: true
                spacing: 4
                model: LauncherState.results

                delegate: LauncherResult {
                    required property var modelData
                    required property int index
                    width: resultsList.width
                    entry: modelData
                    resultIndex: index
                }

                Connections {
                    target: LauncherState
                    function onSelectedIndexChanged() {
                        resultsList.positionViewAtIndex(LauncherState.selectedIndex, ListView.Contain)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "↑/↓ select   Enter open   Esc close"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
