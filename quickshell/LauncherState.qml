pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: state
    visible: false

    property bool open: false
    property string query: ""
    property string targetOutput: ""
    property int outputRequestSerial: 0
    property int selectedIndex: 0
    property int resultLimit: 12
    property bool clipboardSession: false

    readonly property string appPrefix: ">"
    readonly property string clipboardPrefix: ";"
    readonly property bool clipboardMode: clipboardSession || query.startsWith(clipboardPrefix)
    readonly property string mode: clipboardMode ? "clipboard" : "apps"
    readonly property string searchText: clipboardMode ? (query.startsWith(clipboardPrefix) ? query.slice(clipboardPrefix.length).trim() : query.trim()) :
                                      (query.startsWith(appPrefix) ? query.slice(appPrefix.length).trim() : query.trim())
    readonly property var applications: Array.from(DesktopEntries.applications.values)
        .filter(entry => entry && entry.name)
        .sort((left, right) => left.name.localeCompare(right.name))
    property var clipboardEntries: []
    readonly property var results: (clipboardMode ? matchingClipboard(searchText) : matchingApplications(searchText))
        .slice(0, resultLimit)

    onQueryChanged: selectedIndex = 0
    onResultsChanged: {
        if (selectedIndex >= results.length)
            selectedIndex = Math.max(0, results.length - 1)
    }

    function scoreMatch(needle, haystack) {
        const queryText = needle.toLowerCase()
        const candidate = haystack.toLowerCase()
        if (queryText === "") return 0

        const substringIndex = candidate.indexOf(queryText)
        if (substringIndex >= 0) return 10000 - substringIndex

        let score = 0
        let position = 0
        for (let i = 0; i < queryText.length; i++) {
            const found = candidate.indexOf(queryText[i], position)
            if (found < 0) return -1
            score += 100 - found
            if (found === position) score += 25
            position = found + 1
        }
        return score
    }

    function matchingApplications(text) {
        const ranked = applications.map(entry => {
            const nameScore = scoreMatch(text, entry.name || "")
            const genericScore = scoreMatch(text, entry.genericName || "")
            const keywordScore = scoreMatch(text, (entry.keywords || []).join(" "))
            return {
                entry: entry,
                score: Math.max(nameScore, genericScore, keywordScore)
            }
        }).filter(result => result.score >= 0)

        ranked.sort((left, right) => {
            if (right.score !== left.score) return right.score - left.score
            return left.entry.name.localeCompare(right.entry.name)
        })
        return ranked.map(result => result.entry)
    }

    function cleanClipboardEntry(entry) {
        return entry.replace(/^\d+\t/, "")
    }

    function matchingClipboard(text) {
        const seen = new Set()
        const matches = []
        for (const rawEntry of clipboardEntries) {
            const cleaned = cleanClipboardEntry(rawEntry)
            const key = cleaned
            if (seen.has(key) || scoreMatch(text, cleaned) < 0) continue
            seen.add(key)
            matches.push({ kind: "clipboard", name: cleaned, rawEntry: rawEntry })
        }
        return matches
    }

    function moveSelection(delta) {
        if (results.length === 0) return
        selectedIndex = (selectedIndex + delta + results.length) % results.length
    }

    function activateSelected() {
        const entry = results[selectedIndex]
        if (!entry) return
        close()
        if (entry.kind === "clipboard") copyClipboard(entry.rawEntry)
        else entry.execute()
    }

    function openLauncher(output) {
        openWithQuery("", output || "")
    }

    function openClipboard(output) {
        refreshClipboard()
        openWithQuery(clipboardPrefix, output || "")
    }

    function openWithQuery(initialQuery, output) {
        clipboardSession = initialQuery.startsWith(clipboardPrefix)
        query = initialQuery
        selectedIndex = 0
        outputRequestSerial++
        if (output) {
            targetOutput = output
            open = true
            return
        }
        focusOutputProcess.requestSerial = outputRequestSerial
        focusOutputProcess.running = true
    }

    function toggle() {
        if (open) close()
        else openLauncher()
    }

    function close() {
        outputRequestSerial++
        open = false
        query = ""
        clipboardSession = false
        selectedIndex = 0
    }

    function refreshClipboard() {
        clipboardRefreshPending = true
        if (clipboardReadProcess.running) return
        clipboardReadProcess.running = true
    }

    function copyClipboard(entry) {
        Quickshell.execDetached(["sh", "-c", "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "quickshell-clipboard", String(entry)])
    }

    Process {
        id: focusOutputProcess
        command: ["niri", "msg", "-j", "focused-output"]
        property string output: ""
        property int requestSerial: 0

        stdout: SplitParser {
            onRead: data => focusOutputProcess.output += data
        }

        onRunningChanged: {
            if (running) {
                output = ""
                return
            }

            if (requestSerial !== state.outputRequestSerial) return

            try {
                const focusedOutput = JSON.parse(output)
                state.targetOutput = focusedOutput.name || ""
            } catch (error) {
                state.targetOutput = ""
            }
            state.open = true
        }
    }

    Process {
        id: clipboardReadProcess
        command: ["cliphist", "list"]
        property var buffer: []

        stdout: SplitParser {
            onRead: line => clipboardReadProcess.buffer.push(line)
        }

        onRunningChanged: {
            if (running) {
                buffer = []
                return
            }
            clipboardEntries = buffer
            if (clipboardRefreshPending) {
                clipboardRefreshPending = false
                if (open && clipboardMode) clipboardReadProcess.running = true
            }
        }
    }

    property bool clipboardRefreshPending: false

    Timer {
        interval: 750
        running: state.open && state.clipboardMode
        repeat: true
        onTriggered: state.refreshClipboard()
    }

    IpcHandler {
        target: "launcher"

        function toggle() { state.toggle() }
        function open() { if (!state.open) state.openLauncher("") }
        function close() { state.close() }
        function clipboardToggle() {
            if (state.open && state.clipboardMode) state.close()
            else state.openClipboard("")
        }
        function clipboardOpen() { state.openClipboard("") }
    }
}
