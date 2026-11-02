pragma Singleton
import QtQuick
import Quickshell

QtObject {
    // Core palette: surfaces stay near-black while the warm accent carries focus.
    readonly property color colBg: "#000000"
    readonly property color colSurface: "#0a0c0d"
    readonly property color colSurfaceRaised: "#111416"
    readonly property color colBorder: "#252a2c"
    readonly property color colFg: "#e8eaeb"
    readonly property color colMuted: "#7b8589"
    readonly property color colAccent: "#b88645"
    readonly property color colClock: "#b88645"
    readonly property color colDanger: "#a95f5f"
    readonly property color colTooltip: "#0d1011"

    // Shared geometry keeps the bar and its panels visually related.
    readonly property int space1: 4
    readonly property int space2: 8
    readonly property int space3: 12
    readonly property int space4: 16
    readonly property int islandHeight: 44
    readonly property int islandTop: 8
    readonly property int controlSize: 30
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 18
    readonly property real surfaceOpacity: 0.96
    readonly property real panelOpacity: 0.985

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: "Material Symbols Rounded"
    readonly property int fontSize: 13
    property bool reducedMotion: Quickshell.env("QS_REDUCED_MOTION") === "1"
    readonly property int motionFast: reducedMotion ? 0 : 120
    readonly property int motionMedium: reducedMotion ? 0 : 180
    readonly property int motionSlow: reducedMotion ? 0 : 260
    readonly property int motionContent: reducedMotion ? 0 : 160
    readonly property int easing: Easing.OutCubic
}
