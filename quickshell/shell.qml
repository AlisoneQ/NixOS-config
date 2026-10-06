//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
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

        PanelWindow {
            id: barWindow

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 68

            // One extra workspace worth of room.
            property int workspaceBuffer: 36

            // Everything that isn't part of the workspace section.
            property int fixedWidth: 88

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

                width: Math.min(parent.width, contentWidth)
                height: 40

                topLeftRadius: 0
                topRightRadius: 0
                bottomLeftRadius: 13
                bottomRightRadius: 13

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

                WorkspaceBar {
                    id: workspaceBar

                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    outputName: modelData.name
                }

                Rectangle {
                    width: 64
                    height: 28

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    radius: 9
                    color: Qt.alpha(Theme.colTooltip, 0.7)

                    Clock {
                        anchors.centerIn: parent
                    }
                }

                NetworkWidget {
                    anchors.right: parent.right
                    anchors.rightMargin: batteryWidget.visible ? 46 : 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                BatteryWidget {
                    id: batteryWidget

                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}