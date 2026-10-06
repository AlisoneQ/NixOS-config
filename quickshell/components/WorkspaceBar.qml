import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import ".."

RowLayout {
    id: workspaceBar
    spacing: 3
    implicitWidth: workspaces.length * 28 + Math.max(0, workspaces.length - 1) * spacing
    implicitHeight: 28

    required property string outputName
    property var allWorkspaces: WorkspaceState.workspaces
    property var workspaces: workspaceBar.workspacesForOutput(workspaceBar.allWorkspaces, workspaceBar.outputName)
    property var activeWorkspaceId: WorkspaceState.activeWorkspaceByOutput[workspaceBar.outputName]

    function workspacesForOutput(allWorkspaces, output) {
        var visibleWorkspaces = allWorkspaces.filter(workspace => workspace.output === output)
        visibleWorkspaces.sort((left, right) => {
            var indexDifference = Number(left.idx) - Number(right.idx)
            return indexDifference !== 0 ? indexDifference : Number(left.id) - Number(right.id)
        })
        return visibleWorkspaces
    }

    function desktopIcon(appId) {
        var aliases = {
            "discord": "discord",
            "code": "vscode",
            "code-oss": "code",
            "vscodium": "vscodium",
            "zen": "zen-browser",
            "zen-beta": "zen-browser",
            "firefox": "firefox",
            "chromium": "chromium",
            "brave": "brave-browser",
            "ghostty": "com.mitchellh.ghostty",
            "kitty": "kitty",
            "foot": "foot",
            "spotify": "spotify",
            "steam": "steam",
            "thunar": "org.xfce.thunar",
            "org.telegram.desktop": "telegram"
        }
        var key = (appId || "").toLowerCase()
        if (aliases[key]) return aliases[key]
        for (var alias in aliases) {
            if (key.endsWith("." + alias) || key.includes(alias)) return aliases[alias]
        }
        return key
    }

    function workspaceApp(workspace) {
        // Prefer niri's active window, then use the largest remaining window.
        return WorkspaceState.appForWorkspace(workspace.id, workspace.active_window_id)
    }

    Repeater {
        model: workspaceBar.workspaces

        Rectangle {
            required property var modelData
            property bool isActive: Number(workspaceBar.activeWorkspaceId) === Number(modelData.id)
            property bool isUrgent: modelData.is_urgent === true
            property var appWindow: workspaceBar.workspaceApp(modelData)
            property string desktopIconName: appWindow ? workspaceBar.desktopIcon(appWindow.app_id) : ""
            property string displayedIconName: ""

            onDesktopIconNameChanged: {
                if (desktopIconName === "") displayedIconName = ""
            }

            Layout.preferredWidth: 28
            Layout.preferredHeight: 26
            Layout.minimumWidth: 28
            Layout.maximumWidth: 28
            Layout.minimumHeight: 26
            Layout.maximumHeight: 26
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            scale: workspaceMouse.containsMouse ? 1.035 : 1.0
            color: isActive ? Qt.alpha(Theme.colAccent, 0.2) :
                              (workspaceMouse.containsMouse ? Qt.alpha(Theme.colBorder, 0.52) : "transparent")
            border.width: isActive || isUrgent ? 1 : 0
            border.color: isUrgent ? Theme.colDanger : Qt.alpha(Theme.colAccent, 0.7)

            Behavior on color {
                ColorAnimation { duration: Theme.motionFast }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motionMedium
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent
                text: "•"
                color: parent.isActive ? Theme.colAccent : Qt.alpha(Theme.colMuted, 0.7)
                font.pixelSize: 9
                visible: parent.displayedIconName === ""
            }

            IconImage {
                id: iconProbe
                width: 1
                height: 1
                visible: false
                source: parent.desktopIconName ? Quickshell.iconPath(parent.desktopIconName) : ""

                onStatusChanged: {
                    if (status === Image.Ready) parent.displayedIconName = parent.desktopIconName
                }
            }

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                width: 16
                height: 16
                source: parent.displayedIconName ? Quickshell.iconPath(parent.displayedIconName) : ""
                visible: parent.displayedIconName !== ""
                opacity: parent.isActive ? 1 : 0.78
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
                width: parent.isActive ? 10 : 0
                height: 2
                radius: 1
                color: Theme.colAccent
                visible: parent.isActive

                Behavior on width {
                    NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                id: workspaceMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: workspaceAction.running = true
            }

            Process {
                id: workspaceAction
                command: ["niri", "msg", "action", "focus-workspace", String(modelData.idx)]
            }
        }
    }
}
