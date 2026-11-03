pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: state
    visible: false

    property real maxVolume: 1.0
    property real volumeStep: 0.05
    property bool panelOpen: false
    property bool feedbackVisible: false
    property int feedbackVolume: 0
    property bool feedbackMuted: false

    readonly property var outputDevice: Pipewire.defaultAudioSink
    readonly property var inputDevice: Pipewire.defaultAudioSource
    readonly property var outputAudio: outputDevice && outputDevice.audio ? outputDevice.audio : null
    readonly property var inputAudio: inputDevice && inputDevice.audio ? inputDevice.audio : null
    readonly property real outputVolume: outputAudio ? clamp(outputAudio.volume) : 0
    readonly property real inputVolume: inputAudio ? clamp(inputAudio.volume) : 0
    readonly property int outputPercent: Math.round(outputVolume * 100)
    readonly property int inputPercent: Math.round(inputVolume * 100)
    readonly property bool outputMuted: outputAudio ? outputAudio.muted : false
    readonly property bool inputMuted: inputAudio ? inputAudio.muted : false
    readonly property bool ready: Pipewire.ready && ((outputDevice && outputDevice.ready) || (inputDevice && inputDevice.ready))

    function clamp(value) { return Math.max(0, Math.min(maxVolume, Number(value) || 0)) }

    function showFeedback() {
        feedbackVolume = Math.round(outputVolume * 100)
        feedbackMuted = outputMuted
        feedbackVisible = true
        feedbackTimer.restart()
    }

    function setOutputVolume(value) {
        if (!outputAudio || !outputDevice.ready) return
        outputAudio.volume = clamp(value)
        showFeedback()
    }

    function setOutputPercent(percent) {
        const maximum = Math.round(maxVolume * 100)
        setOutputVolume(Math.max(0, Math.min(maximum, Math.round(percent))) / 100)
    }

    function adjustOutputVolume(delta) {
        setOutputVolume(outputVolume + delta)
    }

    function toggleOutputMute() {
        if (!outputAudio || !outputDevice.ready) return
        outputAudio.muted = !outputAudio.muted
        showFeedback()
    }

    function setInputVolume(value) {
        if (inputAudio && inputDevice.ready) inputAudio.volume = clamp(value)
    }

    function setInputPercent(percent) {
        const maximum = Math.round(maxVolume * 100)
        setInputVolume(Math.max(0, Math.min(maximum, Math.round(percent))) / 100)
    }

    function toggleInputMute() {
        if (inputAudio && inputDevice.ready) inputAudio.muted = !inputAudio.muted
    }

    PwObjectTracker {
        objects: [outputDevice, inputDevice].filter(device => device !== null)
    }

    function togglePanel() { panelOpen = !panelOpen }
    function closePanel() { panelOpen = false }

    Timer {
        id: feedbackTimer
        interval: 900
        repeat: false
        onTriggered: state.feedbackVisible = false
    }

    Connections {
        target: state.outputAudio
        function onVolumesChanged() { state.showFeedback() }
        function onMutedChanged() { state.showFeedback() }
    }

    IpcHandler {
        target: "audio"
        function toggle() { state.togglePanel() }
        function close() { state.closePanel() }
        function volumeUp() { state.adjustOutputVolume(state.volumeStep) }
        function volumeDown() { state.adjustOutputVolume(-state.volumeStep) }
        function toggleMute() { state.toggleOutputMute() }
        function micMute() { state.toggleInputMute() }
    }
}
