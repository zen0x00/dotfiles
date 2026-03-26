import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "zen0x-powermenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            root.visible = !root.visible;
        }
    }

    Shortcut {
        sequences: ["Escape"]
        onActivated: root.visible = false
    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.55)

        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            PowerMenuButton {
                icon: "⏻"
                label: "Shutdown"
                shortcut: "S"
                onClicked: { shutdownProc.running = true; root.visible = false; }
            }

            PowerMenuButton {
                icon: "󰜉"
                label: "Reboot"
                shortcut: "R"
                onClicked: { rebootProc.running = true; root.visible = false; }
            }

            PowerMenuButton {
                icon: "󰍃"
                label: "Logout"
                shortcut: "E"
                onClicked: { logoutProc.running = true; root.visible = false; }
            }

            PowerMenuButton {
                icon: "󰒲"
                label: "Hibernate"
                shortcut: "H"
                onClicked: { hibernateProc.running = true; root.visible = false; }
            }

            PowerMenuButton {
                icon: "󰌾"
                label: "Lock"
                shortcut: "L"
                onClicked: { lockProc.running = true; root.visible = false; }
            }
        }
    }

    // Keyboard shortcuts
    Shortcut { sequences: ["S"]; onActivated: { shutdownProc.running = true; root.visible = false; } }
    Shortcut { sequences: ["R"]; onActivated: { rebootProc.running = true; root.visible = false; } }
    Shortcut { sequences: ["E"]; onActivated: { logoutProc.running = true; root.visible = false; } }
    Shortcut { sequences: ["H"]; onActivated: { hibernateProc.running = true; root.visible = false; } }
    Shortcut { sequences: ["L"]; onActivated: { lockProc.running = true; root.visible = false; } }

    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: logoutProc; command: ["bash", "-c", "loginctl kill-session $XDG_SESSION_ID"] }
    Process { id: hibernateProc; command: ["bash", "-c", "hyprlock & systemctl hibernate"] }
    Process { id: lockProc; command: ["hyprlock"] }
}
