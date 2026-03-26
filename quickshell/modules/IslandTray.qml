import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Eye-candy mode: top-right tray pill
PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.right: true
    implicitHeight: 52
    implicitWidth: content.implicitWidth + 24
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-island-tray"

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 8
        implicitWidth: content.implicitWidth + 20
        height: 38
        radius: 24
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.85)
        border.color: Colors.outlineVariant
        border.width: 1

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 10

            BarTray {
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "·"
                font.pixelSize: 16
                font.weight: 800
                color: Colors.outlineVariant
                anchors.verticalCenter: parent.verticalCenter
            }

            BarNetwork { anchors.verticalCenter: parent.verticalCenter }
            BarBluetooth { anchors.verticalCenter: parent.verticalCenter }
            BarVolume { anchors.verticalCenter: parent.verticalCenter }

            Text {
                text: "·"
                font.pixelSize: 16
                font.weight: 800
                color: Colors.outlineVariant
                anchors.verticalCenter: parent.verticalCenter
            }

            // Control center button
            Text {
                text: "󰂜"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 16
                color: Colors.onSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ccProc.running = true
                }

                Process {
                    id: ccProc
                    command: ["qs", "ipc", "call", "controlcenter", "toggle"]
                }
            }
        }
    }
}
