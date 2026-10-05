import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import ".."

RowLayout {
    id: workspaceBar
    spacing: 4
    implicitWidth: workspaces.length * 32 + Math.max(0, workspaces.length - 1) * spacing
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

            Layout.preferredWidth: 32
            Layout.preferredHeight: 28
            Layout.minimumWidth: 32
            Layout.maximumWidth: 32
            Layout.minimumHeight: 28
            Layout.maximumHeight: 28
            Layout.alignment: Qt.AlignVCenter
            radius: 9
            scale: workspaceMouse.containsMouse ? 1.06 : 1.0
            color: isActive ? Theme.colAccent : (workspaceMouse.containsMouse ? Theme.colBorder : "transparent")
            border.width: isActive || isUrgent ? 1 : 0
            border.color: isUrgent ? Theme.colDanger : Theme.colAccent

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
                color: parent.isActive ? Theme.colBg : Theme.colMuted
                font.pixelSize: 11
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
                width: 18
                height: 18
                source: parent.displayedIconName ? Quickshell.iconPath(parent.displayedIconName) : ""
                visible: parent.displayedIconName !== ""
                opacity: 1
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