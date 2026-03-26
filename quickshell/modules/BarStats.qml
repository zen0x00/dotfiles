import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// System stats: CPU, Memory, Disk — compact for bar use
Item {
    id: root

    property int cpu: 0
    property int mem: 0
    property int disk: 0

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Process {
        id: statsPoll
        command: ["bash", "-c",
            "cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'); " +
            "mem=$(free | awk '/^Mem/{printf \"%d\", $3/$2*100}'); " +
            "disk=$(df / | awk 'NR==2{printf \"%d\", $5}'); " +
            "echo \"$cpu $mem $disk\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split(" ");
                if (parts.length >= 3) {
                    root.cpu  = parseInt(parts[0]) || 0;
                    root.mem  = parseInt(parts[1]) || 0;
                    root.disk = parseInt(parts[2]) || 0;
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsPoll.running = true
    }

    Row {
        id: row
        spacing: 12
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: " " + root.cpu + "%"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 12
            color: Colors.secondary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: " " + root.mem + "%"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 12
            color: Colors.tertiary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "󰋊 " + root.disk + "%"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 12
            color: Colors.onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: btopProc.running = true
    }

    Process {
        id: btopProc
        command: ["zen0x-launch-or-focus-tui", "btop"]
    }
}
