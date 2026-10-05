pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: state

    visible: false

    property var workspaces: []
    property var windows: []
    property var windowsById: ({})
    property var largestWindowByWorkspace: ({})
    property var activeWorkspaceByOutput: ({})

    function rebuildWindowIndex(windowList) {
        var byId = {}
        var indexed = {}
        for (var i = 0; i < windowList.length; i++) {
            var window = windowList[i]
            byId[String(window.id)] = window
            var size = window.layout && window.layout.window_size ? window.layout.window_size : [0, 0]
            var area = Number(size[0]) * Number(size[1])
            var key = String(window.workspace_id)
            var current = indexed[key]
            var currentSize = current && current.layout && current.layout.window_size ? current.layout.window_size : [0, 0]
            var currentArea = Number(currentSize[0]) * Number(currentSize[1])
            if (!current || area > currentArea || (area === currentArea && window.is_focused)) {
                indexed[key] = window
            }
        }
        windowsById = byId
        largestWindowByWorkspace = indexed
    }

    function appForWorkspace(workspaceId, activeWindowId) {
        if (activeWindowId !== null && activeWindowId !== undefined) {
            var activeWindow = windowsById[String(activeWindowId)]
            if (activeWindow) return activeWindow
        }
        return largestWindowByWorkspace[String(workspaceId)] || null
    }

    function updateWorkspaceState(workspaceList) {
        var activeByOutput = {}
        for (var i = 0; i < workspaceList.length; i++) {
            var workspace = workspaceList[i]
            if (workspace.is_active === true && workspace.output) {
                activeByOutput[workspace.output] = workspace.id
            }
        }
        state.workspaces = workspaceList.slice()
        state.activeWorkspaceByOutput = activeByOutput
    }

    function updateActivatedWorkspace(workspaceId) {
        var activatedWorkspace = null
        for (var i = 0; i < state.workspaces.length; i++) {
            if (Number(state.workspaces[i].id) === Number(workspaceId)) {
                activatedWorkspace = state.workspaces[i]
                break
            }
        }
        if (!activatedWorkspace || !activatedWorkspace.output) return

        var activeByOutput = Object.assign({}, state.activeWorkspaceByOutput)
        activeByOutput[activatedWorkspace.output] = activatedWorkspace.id
        state.activeWorkspaceByOutput = activeByOutput
    }

    function updateWorkspaceActiveWindow(workspaceId, activeWindowId) {
        var updatedWorkspaces = state.workspaces.map(workspace => {
            if (Number(workspace.id) !== Number(workspaceId)) return workspace
            return Object.assign({}, workspace, {active_window_id: activeWindowId})
        })
        state.updateWorkspaceState(updatedWorkspaces)
    }

    function updateWindow(window) {
        var updatedWindows = state.windows.slice()
        var found = false
        for (var i = 0; i < updatedWindows.length; i++) {
            if (Number(updatedWindows[i].id) === Number(window.id)) {
                updatedWindows[i] = window
                found = true
                break
            }
        }
        if (!found) updatedWindows.push(window)
        state.windows = updatedWindows
        state.rebuildWindowIndex(updatedWindows)
    }

    function removeWindow(windowId) {
        var updatedWindows = state.windows.filter(window => Number(window.id) !== Number(windowId))
        state.windows = updatedWindows
        state.rebuildWindowIndex(updatedWindows)
    }

    // One event stream keeps every monitor bar in sync with niri.
    Process {
        id: eventStream
        command: ["niri", "msg", "-j", "event-stream"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    var event = JSON.parse(data)
                    if (event.WorkspacesChanged) state.updateWorkspaceState(event.WorkspacesChanged.workspaces || [])
                    if (event.WorkspaceActivated) state.updateActivatedWorkspace(event.WorkspaceActivated.id)
                    if (event.WorkspaceActiveWindowChanged) {
                        state.updateWorkspaceActiveWindow(event.WorkspaceActiveWindowChanged.workspace_id, event.WorkspaceActiveWindowChanged.active_window_id)
                    }
                    if (event.WindowsChanged) {
                        state.windows = event.WindowsChanged.windows || []
                        state.rebuildWindowIndex(state.windows)
                    }
                    if (event.WindowOpenedOrChanged) state.updateWindow(event.WindowOpenedOrChanged.window)
                    if (event.WindowClosed) state.removeWindow(event.WindowClosed.id)
                } catch (error) {
                    // Ignore malformed lines and wait for the next complete event.
                }
            }
        }

        onRunningChanged: if (!running) restartTimer.start()

        Component.onCompleted: running = true
    }

    Timer {
        id: restartTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (!eventStream.running) eventStream.running = true
        }
    }
}
