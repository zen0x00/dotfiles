import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    property string status: "off"  // "on", "off", "connected"

    function getIcon(): string {
        if (root.status === "connected") return "󰂯";
        if (root.status === "off") return "󰂲";
        return "󰂯";
    }

    Process {
        id: btProc
        command: ["bash", "-c", "systemctl is-active bluetooth >/dev/null 2>&1 && bluetoothctl show 2>/dev/null || echo 'Powered: no'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text;
                if (out.includes("Powered: yes")) {
                    connectedProc.running = true;
                } else {
                    root.status = "off";
                }
            }
        }
    }

    Process {
        id: connectedProc
        command: ["bash", "-c", "bluetoothctl devices Connected 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                root.status = out.length > 0 ? "connected" : "on";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: btProc.running = true
    }

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: root.getIcon()
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 20
        color: Colors.onSurface
        scale: 0.65
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: launchProc.running = true
    }

    Process {
        id: launchProc
        command: ["zen0x-launch-bluetooth"]
    }
}
