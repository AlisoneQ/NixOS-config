pragma Singleton
import QtQuick

QtObject {
    readonly property color colBg: "#000000"
    readonly property color colBorder: "#171b1d"
    readonly property color colFg: "#e8eaeb"
    readonly property color colMuted: "#555d61"
    readonly property color colAccent: "#b88645"
    readonly property color colClock: "#b88645"
    readonly property color colDanger: "#a95f5f"
    readonly property color colTooltip: "#080a0b"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: "Material Symbols Rounded"
    readonly property int fontSize: 13
    readonly property int motionFast: 120
    readonly property int motionMedium: 180
    readonly property int motionSlow: 260
}
