pragma Singleton
import QtQuick

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
    readonly property int controlSize: 30
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 18
    readonly property real surfaceOpacity: 0.96
    readonly property real panelOpacity: 0.985

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: "Material Symbols Rounded"
    readonly property int fontSize: 13
    readonly property int motionFast: 120
    readonly property int motionMedium: 180
    readonly property int motionSlow: 260
    readonly property int motionContent: 160
}
