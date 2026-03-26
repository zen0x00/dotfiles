import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Eye-candy mode: full-width floating pill
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
            anchors.centerIn: parent
            property string rawTitle: Hyprland.activeToplevel?.title ?? ""
            text: rawTitle.length > 40 ? rawTitle.slice(0, 40) + "…" : rawTitle
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 13
            font.weight: 600
            color: Qt.rgba(Colors.secondary.r, Colors.secondary.g, Colors.secondary.b, 0.85)
            horizontalAlignment: Text.AlignHCenter
        }

        // ── Right: tray · stats+clock ──
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

            BarStats { anchors.verticalCenter: parent.verticalCenter }
        }
    }
}
