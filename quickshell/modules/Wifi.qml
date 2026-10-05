import Quickshell.Networking
import QtQuick

Text {
    font.pixelSize: 15

    text: {
        for (const device of Networking.devices) {
            if (!device.connected)
                continue

            if (device.networks.length === 0)
                continue

            for (const network of device.networks) {
                if (network.connected)
                    return "󰤨 " + network.name
            }
        }

        return "󰤭 Offline"
    }
}
