import Quickshell
import Quickshell.Wayland
import ".."

// Keep the output work area independent from the interactive island surface.
PanelWindow {
    implicitHeight: Theme.islandReservation
    color: "transparent"
    exclusiveZone: implicitHeight
    anchors { top: true; left: true; right: true }
    mask: Region {}
    WlrLayershell.namespace: "quickshell:niri-island-strut"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
}
