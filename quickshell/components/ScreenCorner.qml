import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

// One shallow overlay surface draws both corners of an output edge. This keeps
// the buffers tiny while avoiding a full-screen transparent window.
PanelWindow {
    id: cornerWindow

    required property string edge
    readonly property int cornerRadius: Theme.screenCornerRadius

    implicitHeight: cornerRadius
    color: "transparent"
    exclusiveZone: 0
    anchors {
        top: edge !== "bottom"
        bottom: edge === "bottom"
        left: true
        right: true
    }
    WlrLayershell.namespace: "quickshell:screen-corners-" + edge
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // The decoration is never interactive.
    mask: Region {}

    function paintCorner(canvas) {
        const context = canvas.getContext("2d")
        context.clearRect(0, 0, canvas.width, canvas.height)
        context.globalCompositeOperation = "source-over"
        context.fillStyle = Theme.colBg
        context.fillRect(0, 0, canvas.width, canvas.height)
        context.globalCompositeOperation = "destination-out"
        context.beginPath()
        context.arc(canvas.width, canvas.height, canvas.width, 0, Math.PI * 2)
        context.fill()
        context.globalCompositeOperation = "source-over"
    }

    Canvas {
        id: leftCorner
        anchors.left: parent.left
        width: cornerWindow.cornerRadius
        height: cornerWindow.cornerRadius
        rotation: cornerWindow.edge === "top" ? 0 : 270
        onPaint: cornerWindow.paintCorner(leftCorner)
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Canvas {
        id: rightCorner
        anchors.right: parent.right
        width: cornerWindow.cornerRadius
        height: cornerWindow.cornerRadius
        rotation: cornerWindow.edge === "top" ? 90 : 180
        onPaint: cornerWindow.paintCorner(rightCorner)
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
}
