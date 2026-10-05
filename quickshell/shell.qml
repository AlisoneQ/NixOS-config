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

        PanelWindow {
            id: barWindow
            property var modelData
            screen: modelData
            property int contentWidth: Math.max(220, workspaceBar.implicitWidth * 2 + 180)

            anchors {
                top: true
            }

            implicitHeight: 80
            implicitWidth: Math.min(screen.width - 24, 420)
            color: "transparent"
            exclusiveZone: 0

            margins {
                top: 0
                bottom: 0
                left: 12
                right: 12
            }

            Rectangle {
                id: bar
                property bool entered: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                y: bar.entered ? 0 : -6
                width: Math.min(parent.width, contentWidth)
                height: 34
                radius: 10
                color: Theme.colBg
                border.width: 1
                border.color: Theme.colBorder
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

                WorkspaceBar {
                    id: workspaceBar
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    outputName: modelData.name
                }

                Clock {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                NetworkWidget {
                    anchors.right: parent.right
                    anchors.rightMargin: batteryWidget.visible ? 38 : 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                BatteryWidget {
                    id: batteryWidget
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
