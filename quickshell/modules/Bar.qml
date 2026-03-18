import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true
    height: 36
    color: "transparent"
    exclusionMode: ExclusionMode.Auto

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-bar"

    Rectangle {
        id: pill
        anchors.fill: parent
        color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.95)
        radius: 0

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Colors.fg0
        }

        BarClock {
            anchors.centerIn: parent
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 0

            Text {
                text: "󰣇"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 22
                font.weight: 800
                color: Colors.accent
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 14
            }

            BarWorkspaces {
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            BarTray {
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "·"
                font.pixelSize: 20
                font.weight: 800
                color: Colors.fg2
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }

            Row {
                spacing: 14
                Layout.alignment: Qt.AlignVCenter

                BarNetwork {}
                BarBluetooth {}
                BarVolume {}
            }
        }
    }
}
