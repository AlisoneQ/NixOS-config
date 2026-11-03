import Quickshell
import Quickshell.Wayland
import ".."

// Keep the output work area stable while the interactive island surface is
// briefly recreated to release its layer-shell keyboard grab.
PanelWindow {
    implicitHeight: Theme.islandTop + Theme.islandHeight + Theme.space2
    color: "transparent"
    exclusiveZone: implicitHeight
    anchors { top: true; left: true; right: true }
    mask: Region {}
    WlrLayershell.namespace: "quickshell:niri-island-strut"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
}
