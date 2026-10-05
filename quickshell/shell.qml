import Quickshell
import QtQuick
import qs.modules

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData

            barScreen: modelData
        }
    }
}