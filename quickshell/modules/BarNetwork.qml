import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    property string status: "disconnected"
    property int signal: 0

    function getIcon(): string {
        if (root.status === "ethernet") return "󰀂";
        if (root.status === "disconnected") return "󰤮";
        // wifi signal strength icons
        if (root.signal < 20) return "󰤯";
        if (root.signal < 40) return "󰤟";
        if (root.signal < 60) return "󰤢";
        if (root.signal < 80) return "󰤥";
        return "󰤨";
    }

    Process {
        id: netProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,SIGNAL", "device"]
        stdout: StdioCollector {
            id: collector
            onDataChanged: {
                let text = collector.text.trim();
                let lines = text.split("\n");
                let found = false;
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length < 3) continue;
                    let type = parts[0];
                    let state = parts[1];
                    if (state !== "connected") continue;

                    if (type === "wifi") {
                        root.status = "wifi";
                        root.signal = parseInt(parts[3]) || 0;
                        found = true;
                        break;
                    } else if (type === "ethernet") {
                        root.status = "ethernet";
                        found = true;
                        break;
                    }
                }
                if (!found) root.status = "disconnected";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.exec()
    }

    Text {
        id: icon
        text: root.getIcon()
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 16
        color: Colors.fg0
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: launchProc.startDetached()
    }

    Process {
        id: launchProc
        command: ["zen0x-launch-wifi"]
    }
}
