//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "components"

ShellRoot {
    id: root
    property string audioOutput: "" // Captured once per explicit audio-panel open.
    property bool feedbackArmed: false
    property int restoreWindowId: -1
    readonly property bool interactiveOpen: LauncherState.open || PowerMenuState.open ||
        AudioState.panelOpen || NotificationState.historyOpen
    function closeInteractive() {
        LauncherState.close()
        PowerMenuState.close()
        AudioState.closePanel()
        NotificationState.closeHistory()
    }
    function restoreApplicationFocus() {
        if (restoreWindowId <= 0) return
        focusRestore.command = ["niri", "msg", "action", "focus-window", "--id", String(restoreWindowId)]
        focusRestore.running = true
        restoreWindowId = -1
    }
    onInteractiveOpenChanged: {
        if (interactiveOpen) {
            restoreWindowId = WorkspaceState.lastFocusedWindowId
        }
    }
    Process { id: focusRestore }
    Timer { interval: 600; running: true; onTriggered: root.feedbackArmed = true }

    // One explicit interactive mode at a time. Passive events never change it.
    Connections {
        target: LauncherState
        function onOpenChanged() {
            if (!LauncherState.open) return
            PowerMenuState.close()
            AudioState.closePanel()
            NotificationState.closeHistory()
        }
    }
    Connections {
        target: PowerMenuState
        function onOpenChanged() {
            if (!PowerMenuState.open) return
            LauncherState.close()
            AudioState.closePanel()
            NotificationState.closeHistory()
        }
    }
    Connections {
        target: AudioState
        function onPanelOpenChanged() {
            if (!AudioState.panelOpen) return
            root.audioOutput = NotificationState.targetOutput
            LauncherState.close()
            PowerMenuState.close()
            NotificationState.closeHistory()
        }
    }
    Connections {
        target: NotificationState
        function onHistoryOpenChanged() {
            if (!NotificationState.historyOpen) return
            LauncherState.close()
            PowerMenuState.close()
            AudioState.closePanel()
        }
    }
    IpcHandler {
        target: "appearance"
        function reducedMotion(enabled: bool) { Theme.reducedMotion = enabled }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            // Stable backing surface, with a mask that follows only the island.
            implicitHeight: screen.height
            color: "transparent"
            exclusiveZone: Theme.islandTop + Theme.islandHeight + Theme.space2
            WlrLayershell.namespace: "quickshell:niri-island"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: interactive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            readonly property bool showLauncher: LauncherState.open &&
                NotificationState.resolveOutput(LauncherState.targetOutput) === modelData.name
            readonly property bool showPower: PowerMenuState.open &&
                NotificationState.resolveOutput(PowerMenuState.targetOutput) === modelData.name
            readonly property bool showAudio: AudioState.panelOpen &&
                NotificationState.resolveOutput(root.audioOutput) === modelData.name
            readonly property bool showHistory: NotificationState.centerVisible &&
                NotificationState.centerOutput === modelData.name
            readonly property bool showPreview: !NotificationState.blocked && !!NotificationState.preview &&
                NotificationState.targetOutput === modelData.name
            readonly property bool showFeedback: root.feedbackArmed && AudioState.feedbackVisible &&
                !NotificationState.menuActive && !NotificationState.historyOpen && !NotificationState.fullscreen &&
                NotificationState.targetOutput === modelData.name
            readonly property string mode: showLauncher ? "launcher" : showPower ? "power" :
                showHistory ? "history" : showAudio ? "audio" : showPreview ? "preview" :
                showFeedback ? "feedback" : "bar"
            readonly property bool interactive: showLauncher || showPower || showAudio || showHistory
            property bool releaseFocusPending: false
            readonly property real compactWidth: 2 * Math.max(workspaceGroup.implicitWidth, statusRow.implicitWidth) + 112
            readonly property real targetWidth: Math.min(width - 24, widthFor(mode))
            readonly property real targetHeight: Math.min(height - Theme.islandTop - 16, heightFor(mode))

            function widthFor(value) {
                if (value === "launcher") return 600
                if (value === "history") return 520
                if (value === "power" || value === "audio") return 380
                if (value === "preview") return 460
                if (value === "feedback") return 300
                return compactWidth
            }
            function heightFor(value) {
                if (value === "launcher") return launcherContent.implicitHeight
                if (value === "history") return 500
                if (value === "power") return powerContent.implicitHeight
                if (value === "audio") return 188
                if (value === "preview") return Math.max(112, previewCard.implicitHeight + 8)
                if (value === "feedback") return 76
                return Theme.islandHeight
            }
            function closePanel() {
                if (showLauncher) LauncherState.close()
                else if (showPower) PowerMenuState.close()
                else if (showHistory) NotificationState.closeHistory()
                else if (showAudio) AudioState.closePanel()
            }
            function focusContent() {
                if (!interactive || content.displayMode !== mode) return
                if (showLauncher) launcherContent.takeFocus()
                else if (showPower) powerContent.takeFocus()
                else if (showHistory) historyContent.forceActiveFocus()
                else audioContent.takeFocus()
            }
            onInteractiveChanged: {
                if (interactive) releaseFocusPending = false
                else if (content.displayMode !== "bar") releaseFocusPending = true
            }
            onModeChanged: {
                transition.stop()
                content.opacity = 0
                content.y = Theme.reducedMotion ? 0 : 4
                content.displayMode = mode
                Qt.callLater(focusContent)
                transition.restart()
            }

            // While a panel is open, the existing per-output layer surface is
            // its modal input plane. This keeps click-away dismissal in the
            // shared morphing window; the mask contracts back to the island as
            // soon as the panel closes.
            mask: Region { item: root.interactiveOpen ? inputPlane : island; radius: root.interactiveOpen ? 0 : island.radius }
            IpcHandler {
                target: "island-" + window.modelData.name
                function status(): string {
                    return JSON.stringify({ mode: window.mode, displayed: content.displayMode,
                        width: island.width, height: island.height, x: island.x, y: island.y,
                        targetWidth: window.targetWidth, targetHeight: window.targetHeight,
                        opacity: content.opacity, transitioning: transition.running,
                        keyboard: window.interactive,
                        inputFocused: launcherContent.inputFocused,
                        query: LauncherState.query,
                        powerFocusedIndex: powerContent.focusedIndex,
                        selected: LauncherState.selectedIndex, results: LauncherState.results.length,
                        outputVolume: AudioState.outputVolume, outputPercent: AudioState.outputPercent,
                        inputVolume: AudioState.inputVolume, inputPercent: AudioState.inputPercent,
                        outputMuted: AudioState.outputMuted, inputMuted: AudioState.inputMuted,
                        reducedMotion: Theme.reducedMotion, fullscreen: NotificationState.fullscreen,
                        workspaces: workspaceBar.workspaces.map(w => ({ id: w.id, active: w.id === workspaceBar.activeWorkspaceId,
                            hasApp: !!WorkspaceState.appForWorkspace(w.id, w.active_window_id) })),
                        historyCount: NotificationState.history.length })
                }
            }

            Item {
                id: inputPlane
                anchors.fill: parent
                MouseArea {
                    anchors.fill: parent
                    enabled: root.interactiveOpen
                    acceptedButtons: Qt.AllButtons
                    onPressed: event => {
                        root.closeInteractive()
                        event.accepted = true
                    }
                }
            }

            Timer {
                id: releaseFocus
                interval: 1
                onTriggered: {
                    window.visible = false
                    restoreSurface.start()
                }
            }
            Timer {
                id: restoreSurface
                interval: 1
                onTriggered: {
                    window.visible = true
                    window.releaseFocusPending = false
                    root.restoreApplicationFocus()
                }
            }

            Rectangle {
                id: island
                anchors.horizontalCenter: parent.horizontalCenter
                y: Theme.islandTop
                width: window.targetWidth
                height: window.targetHeight
                radius: window.mode === "bar" ? Theme.radiusMedium : Theme.radiusLarge
                color: Qt.alpha(Theme.colSurface, Theme.panelOpacity)
                border.width: 1
                border.color: Qt.alpha(Theme.colBorder, 0.9)
                clip: true
                Behavior on width { NumberAnimation { duration: Theme.motionSlow; easing.type: Theme.easing } }
                Behavior on height { NumberAnimation { duration: Theme.motionSlow; easing.type: Theme.easing } }
                Behavior on radius { NumberAnimation { duration: Theme.motionSlow; easing.type: Theme.easing } }

                // Consume clicks on otherwise empty panel space without
                // preventing controls above it from receiving input.
                MouseArea {
                    anchors.fill: parent
                    enabled: window.interactive
                    acceptedButtons: Qt.AllButtons
                }

                FocusScope {
                    id: content
                    property string displayMode: "bar"
                    // Content has stable destination geometry while its enclosing surface morphs.
                    width: Math.min(window.width - 24, window.widthFor(displayMode))
                    height: Math.min(window.height - Theme.islandTop - 16, window.heightFor(displayMode))
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: displayMode === window.mode
                    Keys.onEscapePressed: event => {
                        if (window.interactive) { window.closePanel(); event.accepted = true }
                        else event.accepted = false
                    }

                    Item {
                        anchors.fill: parent
                        visible: content.displayMode === "bar"
                        Row {
                            id: workspaceGroup
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.space3
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.space1
                            NotificationButton {
                                symbol: "apps"; label: "Open launcher"
                                onClicked: LauncherState.openLauncher()
                            }
                            WorkspaceBar { id: workspaceBar; outputName: window.modelData.name }
                        }
                        Clock { anchors.centerIn: parent }
                        Row {
                            id: statusRow
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.space3
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.space1
                            BatteryWidget {}
                            NetworkWidget {}
                            AudioWidget {}
                            NotificationButton {
                                symbol: NotificationState.dnd ? "notifications_off" : "notifications"
                                label: "Notification history"
                                highlighted: NotificationState.dnd
                                onClicked: NotificationState.toggleHistory(window.modelData.name)
                            }
                            PowerButton { outputName: window.modelData.name }
                        }
                    }
                    LauncherOverlay {
                        id: launcherContent
                        anchors.fill: parent
                        visible: content.displayMode === "launcher"
                    }
                    PowerMenu {
                        id: powerContent
                        anchors.fill: parent
                        visible: content.displayMode === "power"
                    }
                    NotificationCenter {
                        id: historyContent
                        anchors.fill: parent
                        visible: content.displayMode === "history"
                    }
                    AudioPanel {
                        id: audioContent
                        anchors.fill: parent
                        visible: content.displayMode === "audio"
                    }
                    NotificationCard {
                        id: previewCard
                        width: parent.width
                        y: 4
                        visible: content.displayMode === "preview"
                        compact: true
                        property var retainedRecord: null
                        record: NotificationState.preview || retainedRecord
                        Connections {
                            target: NotificationState
                            function onPreviewChanged() {
                                if (NotificationState.preview) previewCard.retainedRecord = NotificationState.preview
                            }
                        }
                    }
                    VolumeFeedback {
                        anchors.fill: parent
                        visible: content.displayMode === "feedback"
                    }
                }
            }

            // The destination content is installed before the morph begins so
            // interactive modes can accept input immediately.
            ParallelAnimation {
                id: transition
                NumberAnimation { target: content; property: "opacity"; to: 1; duration: Theme.motionContent }
                NumberAnimation { target: content; property: "y"; to: 0; duration: Theme.motionContent; easing.type: Theme.easing }
                onFinished: {
                    window.focusContent()
                    if (window.releaseFocusPending && !window.interactive) releaseFocus.start()
                }
            }
        }
    }
}
