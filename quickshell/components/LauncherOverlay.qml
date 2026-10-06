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

    FontLoader {
        id: materialSymbolsFont
        source: "/etc/nixos/fonts/MaterialSymbolsRounded.ttf"
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.38)

        MouseArea {
            anchors.fill: parent
            onClicked: LauncherState.close()
        }
    }

    Rectangle {
        id: launcherCard
        width: Math.min(600, parent.width - 40)
        height: Math.min(626, Math.max(98, contentLayout.implicitHeight + 24))
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(64, parent.height * 0.14)
        radius: 18
        color: Qt.alpha(Theme.colBg, 0.98)
        border.width: 1
        border.color: Qt.alpha(Theme.colBorder, 0.8)

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 72
            height: 2
            radius: 1
            color: Qt.alpha(Theme.colAccent, 0.7)
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                LauncherState.close()
                event.accepted = true
            }
        }

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 12
                color: Qt.alpha(Theme.colTooltip, 0.82)
                border.width: 1
                border.color: searchInput.activeFocus ? Qt.alpha(Theme.colAccent, 0.85) : Qt.alpha(Theme.colBorder, 0.8)

                Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 13
                    anchors.verticalCenter: parent.verticalCenter
                    text: LauncherState.clipboardMode ? "content_paste_search" : "search"
                    color: searchInput.activeFocus ? Theme.colAccent : Theme.colMuted
                    font.family: materialSymbolsFont.name || Theme.iconFontFamily
                    font.pixelSize: 19

                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                }

                TextField {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 43
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    focus: true
                    placeholderText: LauncherState.clipboardMode ? "Search clipboard history" : "Search applications"
                    text: LauncherState.query
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    selectionColor: Theme.colAccent
                    selectedTextColor: Theme.colBg
                    background: Item {}

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
            }

            Text {
                Layout.fillWidth: true
                visible: LauncherState.results.length === 0
                text: LauncherState.clipboardMode ? "No clipboard entries found" : "No applications found"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                horizontalAlignment: Text.AlignHCenter
                topPadding: 16
                bottomPadding: 16
            }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 520)
                visible: LauncherState.results.length > 0
                clip: true
                spacing: 3
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
                text: LauncherState.clipboardMode ? "↑/↓ select   Enter copy   Esc close" : "↑/↓ select   Enter open   Esc close"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
