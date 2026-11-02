//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "components"

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        LauncherOverlay {
            required property var modelData

            screen: modelData
            outputName: modelData.name
        }
    }

    Variants {
        model: Quickshell.screens

        PowerMenu {
            required property var modelData
            screen: modelData
            outputName: modelData.name
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            // Stable layer surface; only the animated island rectangle accepts input.
            implicitHeight: screen.height
            readonly property bool showHistory: NotificationState.centerVisible && NotificationState.centerOutput === modelData.name
            readonly property bool showPreview: !NotificationState.blocked && !!NotificationState.preview && NotificationState.targetOutput === modelData.name
            readonly property bool showAudioPanel: AudioState.panelOpen && !showHistory && !showPreview && !LauncherState.open && !PowerMenuState.open && NotificationState.targetOutput === modelData.name
            readonly property string mode: showHistory ? "history" : showPreview ? "preview" : showAudioPanel ? "audio" : "bar"
            WlrLayershell.namespace: "quickshell:niri-island"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: showHistory ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            onShowHistoryChanged: if (showHistory) Qt.callLater(historyContent.forceActiveFocus)
            IpcHandler {
                target: "island-" + barWindow.modelData.name
                function status(): string {
                    return JSON.stringify({ mode: barWindow.mode, width: bar.width, height: bar.height,
                        surfaceHeight: barWindow.height, keyboard: barWindow.showHistory,
                        preview: previewContent.shownRecord ? previewContent.shownRecord.notificationId : null,
                        historyCount: NotificationState.history.length })
                }
            }

            // One extra workspace worth of room.
            property int workspaceBuffer: 36

            // Everything that isn't part of the workspace section.
            property int fixedWidth: 156

            // The visible island grows with the workspace bar,
            // while always leaving room for one more workspace.
            property int contentWidth:
                (workspaceBar.implicitWidth + workspaceBuffer) * 2
                + fixedWidth

            color: "transparent"
            exclusiveZone: 32

            margins {
                top: 0
                bottom: 0
                left: 10
                right: 10
            }

            // Only the actual island receives mouse input.
            mask: Region {
                item: bar
            }

            Rectangle {
                id: bar

                property bool entered: false

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                y: bar.entered ? 0 : -5

                width: Math.min(parent.width, barWindow.mode === "bar" ? contentWidth : barWindow.showHistory ? 520 : barWindow.showAudioPanel ? 370 : 460)
                height: barWindow.showHistory ? Math.min(barWindow.height - 24, 520) :
                        barWindow.showPreview ? Math.min(barWindow.height - 24, Math.max(114, previewContent.implicitHeight + 12)) :
                        barWindow.showAudioPanel ? 212 : 42
                clip: true

                topLeftRadius: 0
                topRightRadius: 0
                bottomLeftRadius: barWindow.mode === "bar" ? 13 : 18
                bottomRightRadius: bottomLeftRadius
                Behavior on height { NumberAnimation { duration: Theme.motionSlow; easing.type: Easing.OutCubic } }
                Behavior on bottomLeftRadius { NumberAnimation { duration: Theme.motionSlow; easing.type: Easing.OutCubic } }

                color: Qt.alpha(Theme.colBg, 0.94)

                border.width: 0
                border.color: Qt.alpha(Theme.colBorder, 0.62)

                opacity: bar.entered ? 1 : 0

                Component.onCompleted: entered = true

                Behavior on y {
                    NumberAnimation {
                        duration: Theme.motionSlow
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motionSlow
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.motionMedium
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top

                    width: Math.min(96, parent.width * 0.28)
                    height: 1

                    color: Qt.alpha(Theme.colAccent, 0.58)
                }

                Item {
                    id: normalContent
                    width: bar.width
                    height: 42
                    opacity: barWindow.showHistory || barWindow.showPreview ? 0 : 1
                    visible: opacity > 0
                    enabled: !barWindow.showHistory && !barWindow.showPreview
                    Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
                WorkspaceBar {
                    id: workspaceBar

                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    outputName: modelData.name
                }

                Rectangle {
                    width: 64
                    height: 36

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    radius: 9
                    color: Qt.alpha(Theme.colTooltip, 0.50)

                    Clock {
                        anchors.centerIn: parent
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 6

                    BatteryWidget {
                        id: batteryWidget
                    }

                    NetworkWidget {
                        id: networkWidget
                    }

                    AudioWidget {
                        id: audioWidget
                    }

                    NotificationButton {
                        symbol: NotificationState.dnd ? "notifications_off" : "notifications"
                        label: "Notification history"
                        highlighted: NotificationState.historyOpen || NotificationState.dnd
                        onClicked: NotificationState.toggleHistory(modelData.name)
                    }

                    PowerButton {
                        id: powerButton
                        outputName: modelData.name
                    }
                }

                AudioPanel {
                    id: audioPanel
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    visible: barWindow.showAudioPanel
                    enabled: visible
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
                }
                }

                Item {
                    id: previewContent
                    width: bar.width
                    y: 6
                    implicitHeight: previewCard.implicitHeight
                    property var requestedRecord: NotificationState.preview
                    property var shownRecord: null
                    onRequestedRecordChanged: previewSwap.restart()
                    opacity: barWindow.showPreview ? 1 : 0
                    visible: opacity > 0
                    enabled: barWindow.showPreview
                    Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
                    NotificationCard {
                        id: previewCard
                        width: parent.width
                        compact: true
                        record: previewContent.shownRecord
                    }
                    SequentialAnimation {
                        id: previewSwap
                        NumberAnimation { target: previewCard; property: "opacity"; to: 0; duration: Theme.motionFast / 2 }
                        ScriptAction { script: previewContent.shownRecord = previewContent.requestedRecord }
                        NumberAnimation { target: previewCard; property: "opacity"; to: 1; duration: Theme.motionFast }
                    }
                }
                NotificationCenter {
                    id: historyContent
                    width: bar.width
                    height: Math.min(barWindow.height - 24, 520)
                    opacity: barWindow.showHistory ? 1 : 0
                    visible: opacity > 0
                    enabled: barWindow.showHistory
                    Behavior on opacity { NumberAnimation { duration: Theme.motionFast } }
                }
            }
        }
    }
}
