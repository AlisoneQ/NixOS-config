pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io


Item {
    id: state

    visible: false

    property bool open: false
    property string targetOutput: ""
    property string confirmAction: ""
    property string fallbackOutput: ""

    readonly property var actions: [
        { id: "lock", label: "Lock", icon: "lock" },
        { id: "suspend", label: "Suspend", icon: "bedtime" },
        { id: "logout", label: "Log out", icon: "logout" },
        { id: "reboot", label: "Reboot", icon: "restart_alt" },
        { id: "poweroff", label: "Power off", icon: "power_settings_new" }
    ]

    function toggle(output) {
        if (open) {
            close()
            return
        }
        confirmAction = ""
        fallbackOutput = output || ""
        focusOutputProcess.output = ""
        focusOutputProcess.running = true
    }

    function close() {
        open = false
        confirmAction = ""
    }

    function requestAction(actionId) {
        if (actionId === "lock") {
            close()
            Quickshell.execDetached(["swaylock"])
            return
        }

        if (["suspend", "logout", "reboot", "poweroff"].includes(actionId) && confirmAction !== actionId) {
            confirmAction = actionId
            return
        }

        close()
        if (actionId === "suspend") Quickshell.execDetached(["systemctl", "suspend"])
        else if (actionId === "logout") Quickshell.execDetached(["niri", "msg", "action", "quit"])
        else if (actionId === "reboot") Quickshell.execDetached(["systemctl", "reboot"])
        else if (actionId === "poweroff") Quickshell.execDetached(["systemctl", "poweroff"])
    }

    Process {
        id: focusOutputProcess
        command: ["niri", "msg", "-j", "focused-output"]
        property string output: ""

        stdout: SplitParser {
            onRead: data => focusOutputProcess.output += data
        }

        onRunningChanged: {
            if (running) return
            try {
                state.targetOutput = JSON.parse(output).name || fallbackOutput
            } catch (error) {
                state.targetOutput = fallbackOutput
            }
            state.open = true
        }
    }

    IpcHandler {
        target: "power"

        function toggle() { state.toggle("") }
        function close() { state.close() }
    }
}
