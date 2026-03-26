import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Eye-candy mode: full-width floating pill matching waybar eye-candy layout
PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 52
    color: "transparent"
    exclusionMode: ExclusionMode.Auto

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-island"

    Rectangle {
        id: pill
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        height: 38
        radius: 14
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.75)
        border.color: Qt.rgba(Colors.contentSurfaceVariant.r, Colors.contentSurfaceVariant.g, Colors.contentSurfaceVariant.b, 0.15)
        border.width: 1

        // ── Left: workspaces ──
        BarWorkspaces {
            id: workspaces
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        // ── Center: active window title ──
        Text {
            id: windowTitle
            anchors.centerIn: parent
            text: Hyprland.activeToplevel?.title ?? ""
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 13
            font.weight: 600
            color: Qt.rgba(Colors.secondary.r, Colors.secondary.g, Colors.secondary.b, 0.85)
            elide: Text.ElideRight
            maximumLineCount: 1
            // Constrain so it doesn't overlap left/right sections
            width: Math.min(implicitWidth, pill.width - workspaces.width - rightRow.width - 60)
            horizontalAlignment: Text.AlignHCenter
        }

        // ── Right: tray · volume · stats · clock ──
        Row {
            id: rightRow
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            BarTray { anchors.verticalCenter: parent.verticalCenter }

            Text {
                text: "·"
                font.pixelSize: 16
                font.weight: 800
                color: Colors.outlineVariant
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 8
                rightPadding: 8
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
                leftPadding: 8
                rightPadding: 8
            }

            BarStats { anchors.verticalCenter: parent.verticalCenter }

            Text {
                text: "·"
                font.pixelSize: 16
                font.weight: 800
                color: Colors.outlineVariant
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 8
                rightPadding: 8
            }

            BarClock { anchors.verticalCenter: parent.verticalCenter }
        }
    }
}
