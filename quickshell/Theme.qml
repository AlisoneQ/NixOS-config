pragma Singleton
import QtQuick

QtObject {
    readonly property color colBg: "#171a1d"
    readonly property color colBorder: "#3b4548"
    readonly property color colFg: "#f2eee5"
    readonly property color colMuted: "#899398"
    readonly property color colAccent: "#e3b86b"
    readonly property color colClock: "#e3b86b"
    readonly property color colDanger: "#e78383"
    readonly property color colTooltip: "#202529"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: "Material Symbols Rounded"
    readonly property int fontSize: 13
    readonly property int motionFast: 120
    readonly property int motionMedium: 180
    readonly property int motionSlow: 260
}
