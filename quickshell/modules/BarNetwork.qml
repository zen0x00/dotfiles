import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    property string status: "disconnected"
    property int wifiSignal: 0

    function getIcon(): string {
        if (root.status === "ethernet") return "󰀂";
        if (root.status === "disconnected") return "󰤮";
        // wifi signal strength icons
        if (root.wifiSignal < 20) return "󰤯";
        if (root.wifiSignal < 40) return "󰤟";
        if (root.wifiSignal < 60) return "󰤢";
        if (root.wifiSignal < 80) return "󰤥";
        return "󰤨";
    }

    Process {
        id: netProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                let lines = out.split("\n");
                let found = false;
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length < 2) continue;
                    let type = parts[0];
                    let state = parts[1];
                    if (state !== "connected") continue;

                    if (type === "ethernet") {
                        root.status = "ethernet";
                        root.wifiSignal = 0;
                        found = true;
                        break;
                    } else if (type === "wifi") {
                        root.status = "wifi";
                        found = true;
                        wifiSignalProc.running = true;
                        break;
                    }
                }
                if (!found) root.status = "disconnected";
            }
        }
    }

    Process {
        id: wifiSignalProc
        command: ["bash", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\\*' | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiSignal = parseInt(this.text.trim()) || 0;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Text {
        id: icon
        text: root.getIcon()
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 20
        color: Colors.onSurface
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: launchProc.running = true
    }

    Process {
        id: launchProc
        command: ["zen0x-launch-wifi"]
    }
}
