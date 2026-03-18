import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.right: true
    implicitHeight: 44
    implicitWidth: topRow.width + 24
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-island-tray"

    Item {
        id: topRow
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: rowContent.width
        height: parent.height

        Row {
            id: rowContent
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            BarTray {
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "·"
                font.pixelSize: 28
                font.weight: 800
                color: Colors.fg2
                anchors.verticalCenter: parent.verticalCenter
            }

            BarNetwork {
                anchors.verticalCenter: parent.verticalCenter
            }
            BarBluetooth {
                anchors.verticalCenter: parent.verticalCenter
            }
            BarVolume {
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
