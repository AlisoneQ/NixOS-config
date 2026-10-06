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
    property int selectedIndex: 0
    property int resultLimit: 12

    readonly property string appPrefix: ">"
    readonly property string mode: query.startsWith(appPrefix) ? "apps" : "apps"
    readonly property string searchText: query.startsWith(appPrefix) ? query.slice(appPrefix.length).trim() : query.trim()
    readonly property var applications: Array.from(DesktopEntries.applications.values)
        .filter(entry => entry && entry.name)
        .sort((left, right) => left.name.localeCompare(right.name))
    readonly property var results: matchingApplications(searchText).slice(0, resultLimit)

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

    function moveSelection(delta) {
        if (results.length === 0) return
        selectedIndex = (selectedIndex + delta + results.length) % results.length
    }

    function activateSelected() {
        const entry = results[selectedIndex]
        if (!entry) return
        close()
        entry.execute()
    }

    function openLauncher() {
        query = ""
        selectedIndex = 0
        focusOutputProcess.running = true
    }

    function toggle() {
        if (open) close()
        else openLauncher()
    }

    function close() {
        open = false
        query = ""
        selectedIndex = 0
    }

    Process {
        id: focusOutputProcess
        command: ["niri", "msg", "-j", "focused-output"]
        property string output: ""

        stdout: SplitParser {
            onRead: data => focusOutputProcess.output += data
        }

        onRunningChanged: {
            if (running) {
                output = ""
                return
            }

            try {
                const focusedOutput = JSON.parse(output)
                state.targetOutput = focusedOutput.name || ""
            } catch (error) {
                state.targetOutput = ""
            }
            state.open = true
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle() { state.toggle() }
        function open() { if (!state.open) state.openLauncher() }
        function close() { state.close() }
    }
}
