pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

Item {
    id: notifications
    visible: false
    property bool dnd: false
    property bool historyOpen: false
    property string historyOutput: ""
    property var history: []
    property var queue: []
    property var preview: null
    property int defaultTimeout: 5000
    property int criticalPreviewTimeout: 6000
    property int maxHistory: 100
    property int maxQueue: 20
    property double previewDeadline: 0
    property int previewRemaining: 0
    readonly property bool menuActive: LauncherState.open || PowerMenuState.open || AudioState.panelOpen
    readonly property bool fullscreen: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.fullscreen : false
    readonly property bool blocked: menuActive || historyOpen || fullscreen || dnd || targetOutput === ""
    readonly property string targetOutput: resolveOutput(WorkspaceState.focusedOutput)
    readonly property string centerOutput: resolveOutput(historyOutput)
    readonly property bool centerVisible: historyOpen && !menuActive

    function resolveOutput(preferred) {
        const screens = Quickshell.screens
        if (screens.find(screen => screen.name === preferred)) return preferred
        return screens.length ? screens[0].name : ""
    }
    function schedule() { Qt.callLater(notifications.advance) }
    function advance() {
        if (blocked) return
        if (!preview) {
            const next = queue.slice()
            while (next.length && !next[0].live) next.shift()
            if (!next.length) { queue = []; return }
            preview = next.shift()
            queue = next
            previewRemaining = preview.critical ? criticalPreviewTimeout :
                               Math.min(10000, preview.timeout > 0 ? preview.timeout : defaultTimeout)
        }
        if (!previewTimer.running) {
            previewDeadline = Date.now() + Math.max(1, previewRemaining)
            previewTimer.interval = Math.max(1, previewRemaining)
            previewTimer.start()
        }
    }
    onBlockedChanged: {
        if (blocked && previewTimer.running) {
            previewRemaining = Math.max(1, previewDeadline - Date.now())
            previewTimer.stop()
        }
        schedule()
    }
    onDndChanged: {
        if (dnd) {
            for (const record of queue) record.startExpiry()
            if (preview) preview.startExpiry()
            queue = []; preview = null; previewTimer.stop()
        }
        schedule()
    }
    onFullscreenChanged: {
        if (fullscreen) {
            for (const record of queue) if (!record.critical) record.startExpiry()
            queue = queue.filter(record => record.critical)
            if (preview && !preview.critical) { preview.startExpiry(); finishPreview() }
        }
        schedule()
    }
    function finishPreview(expired = false) {
        previewTimer.stop()
        const finished = preview
        preview = null
        previewRemaining = 0
        if (expired && finished && finished.live && !finished.critical && finished.timeout > 0)
            finished.live.expire()
        schedule()
    }
    function removeQueued(record) {
        queue = queue.filter(item => item !== record)
        if (preview === record) finishPreview()
    }
    function enqueue(record) {
        if (dnd || (fullscreen && !record.critical)) { record.startExpiry(); return }
        if (preview === record) {
            previewTimer.stop()
            previewRemaining = record.critical ? criticalPreviewTimeout : Math.min(10000, record.timeout > 0 ? record.timeout : defaultTimeout)
        } else if (!queue.includes(record)) {
            const next = queue.concat([record])
            if (next.length > maxQueue) next.shift().startExpiry()
            queue = next
        }
        schedule()
    }
    function addNotification(notification) {
        notification.tracked = true
        let record = history.find(item => item.notificationId === notification.id)
        if (record) { record.sync(); return }
        record = recordComponent.createObject(notifications, { live: notification, notificationId: notification.id })
        record.sync(false)
        history = [record].concat(history)
        while (history.length > maxHistory) dismissHistory(history[history.length - 1])
        if (!notification.lastGeneration) enqueue(record)
        else record.startExpiry()
    }
    function dismissHistory(record) {
        if (!record) return
        removeQueued(record)
        history = history.filter(item => item !== record)
        if (record.live) record.live.dismiss()
        record.destroy()
    }
    function clearHistory() {
        for (const record of history.slice()) dismissHistory(record)
    }
    function toggleHistory(output) {
        if (historyOpen) historyOpen = false
        else { historyOutput = output || targetOutput; historyOpen = true }
    }
    function closeHistory() { historyOpen = false }
    function toggleDnd() { dnd = !dnd }
    function invoke(record, identifier) {
        if (!record || !record.live) return
        const action = Array.from(record.live.actions).find(item => item.identifier === identifier)
        if (action) action.invoke()
        removeQueued(record)
    }

    // Display snapshots outlive native Notification objects, which are destroyed on close.
    Component {
        id: recordComponent
        Item {
            id: record
            visible: false
            property int notificationId: 0
            property var live: null
            property string appName: ""
            property string appIcon: ""
            property string summary: ""
            property string body: ""
            property bool critical: false
            property double timestamp: 0
            property int timeout: 0
            property var actions: []
            function sync(requeue = true) {
                if (!live) return
                appName = live.appName || "Notification"
                appIcon = live.appIcon || ""
                summary = live.summary || ""
                body = live.body || ""
                critical = live.urgency === NotificationUrgency.Critical
                timestamp = Date.now()
                // Verified against the installed Quickshell 0.3.1: milliseconds.
                timeout = live.expireTimeout < 0 ? notifications.defaultTimeout : live.expireTimeout
                actions = Array.from(live.actions).map(action => ({ identifier: action.identifier, text: action.text }))
                expiry.stop()
                if (requeue) notifications.enqueue(record)
            }
            function startExpiry() {
                if (live && !critical && timeout > 0) { expiry.interval = timeout; expiry.restart() }
            }
            Timer { id: update; interval: 0; onTriggered: record.sync() }
            Timer { id: expiry; onTriggered: { if (record.live) record.live.expire() } }
            Connections {
                target: record.live
                function onSummaryChanged() { update.restart() }
                function onBodyChanged() { update.restart() }
                function onAppNameChanged() { update.restart() }
                function onAppIconChanged() { update.restart() }
                function onUrgencyChanged() { update.restart() }
                function onExpireTimeoutChanged() { update.restart() }
                function onActionsChanged() { update.restart() }
                function onClosed() {
                    update.stop()
                    expiry.stop()
                    record.live = null
                    record.actions = []
                    notifications.removeQueued(record)
                }
            }
        }
    }
    Timer { id: previewTimer; onTriggered: notifications.finishPreview(true) }
    NotificationServer {
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        actionsSupported: true
        bodyMarkupSupported: false
        bodyImagesSupported: false
        actionIconsSupported: false
        imageSupported: false
        onNotification: notification => notifications.addNotification(notification)
    }
    IpcHandler {
        target: "notifications"
        function history() { notifications.toggleHistory("") }
        function closeHistory() { notifications.closeHistory() }
        function toggleDnd() { notifications.toggleDnd() }
        function clear() { notifications.clearHistory() }
        // Diagnostics deliberately omit application names and private body text.
        function status(): string {
            return JSON.stringify({ output: notifications.targetOutput, centerOutput: notifications.centerOutput,
                historyOpen: notifications.historyOpen, centerVisible: notifications.centerVisible, dnd: notifications.dnd,
                menuActive: notifications.menuActive, fullscreen: notifications.fullscreen, blocked: notifications.blocked,
                preview: notifications.preview ? notifications.preview.notificationId : null, queued: notifications.queue.map(item => item.notificationId),
                history: notifications.history.map(item => ({ id: item.notificationId, live: !!item.live, critical: item.critical, timeout: item.timeout })) })
        }
    }
}
