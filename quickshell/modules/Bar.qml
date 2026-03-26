import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Minimal mode: full-width flat bar
PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true
    height: 32
    color: "transparent"
    exclusionMode: ExclusionMode.Auto

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-bar"

    Rectangle {
        anchors.fill: parent
        color: Colors.surface

        // Bottom border
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Colors.outlineVariant
            opacity: 0.5
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 0

            // Arch icon / launcher button
            Text {
                text: "󰣇"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 18
                font.weight: 800
                color: Colors.primary
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 12

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launcherProc.running = true
                }

                Process {
                    id: launcherProc
                    command: ["qs", "ipc", "call", "launcher", "toggle"]
                }
            }

            BarWorkspaces {
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            BarStats {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 10
            }

            Text {
                text: "·"
                font.pixelSize: 16
                color: Colors.outlineVariant
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 4
                Layout.rightMargin: 10
            }

            BarTray {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
            }

            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                BarNetwork {}
                BarBluetooth {}
                BarVolume {}
            }

            Text {
                text: "·"
                font.pixelSize: 16
                color: Colors.outlineVariant
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 10
                Layout.rightMargin: 10
            }

            BarClock {
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
