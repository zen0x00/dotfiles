import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.height

    property int vol: 0
    property bool muted: false
    property int cpu: 0
    property int mem: 0
    property int disk: 0
    property string netDown: "0KB"
    property string netUp: "0KB"
    property string timeText: ""

    function fmtBytes(kb: real): string {
        if (kb >= 1024) return (kb / 1024).toFixed(1) + "MB";
        return Math.round(kb) + "KB";
    }

    // ── Volume ──
    Process {
        id: volPoll
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split(" ");
                if (parts.length >= 2) {
                    root.vol = Math.round((parseFloat(parts[1]) || 0) * 100);
                    root.muted = this.text.includes("[MUTED]");
                }
            }
        }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: volPoll.running = true }

    // ── CPU / MEM / DISK ──
    Process {
        id: sysPoll
        command: ["bash", "-c",
            "cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'); " +
            "mem=$(free | awk '/^Mem/{printf \"%d\", $3/$2*100}'); " +
            "disk=$(df / | awk 'NR==2{printf \"%d\", $5}'); " +
            "echo \"$cpu $mem $disk\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let p = this.text.trim().split(" ");
                if (p.length >= 3) {
                    root.cpu  = parseInt(p[0]) || 0;
                    root.mem  = parseInt(p[1]) || 0;
                    root.disk = parseInt(p[2]) || 0;
                }
            }
        }
    }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: sysPoll.running = true }

    // ── Network speed ──
    property real _prevRx: 0
    property real _prevTx: 0

    Process {
        id: netPoll
        command: ["bash", "-c",
            "iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"dev\") print $(i+1)}' | head -1); " +
            "[ -z \"$iface\" ] && echo '0 0' && exit; " +
            "rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0); " +
            "tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0); " +
            "echo \"$rx $tx\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let p = this.text.trim().split(" ");
                if (p.length >= 2) {
                    let rx = parseFloat(p[0]) || 0;
                    let tx = parseFloat(p[1]) || 0;
                    if (root._prevRx > 0) {
                        let downKb = (rx - root._prevRx) / 1024 / 2;  // 2s interval
                        let upKb   = (tx - root._prevTx) / 1024 / 2;
                        root.netDown = root.fmtBytes(Math.max(0, downKb));
                        root.netUp   = root.fmtBytes(Math.max(0, upKb));
                    }
                    root._prevRx = rx;
                    root._prevTx = tx;
                }
            }
        }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: netPoll.running = true }

    // ── Clock ──
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let now = new Date();
            let h = now.getHours();
            let ampm = h >= 12 ? "PM" : "AM";
            h = h % 12 || 12;
            let m = now.getMinutes().toString().padStart(2, "0");
            root.timeText = h + ":" + m + " " + ampm;
        }
    }

    Row {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        // ── VOL: clickable + scrollable ──
        Text {
            id: volText
            anchors.verticalCenter: parent.verticalCenter
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 12
            font.weight: 600
            color: Colors.contentSurface
            text: root.muted ? "VOL: MUTE" : "VOL: " + root.vol + "%"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                onClicked: audioLauncher.running = true
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) volUp.running = true;
                    else volDown.running = true;
                }
            }
        }

        // ── Rest: CPU/MEM/DISK/ETH/clock — click opens btop ──
        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 12
            font.weight: 600
            color: Colors.contentSurface
            text: "   CPU: " + root.cpu + "%" +
                  "   MEM: " + root.mem + "%" +
                  "   DISK: " + root.disk + "%" +
                  "   ETH: ↓" + root.netDown + " ↑" + root.netUp +
                  "   " + root.timeText

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: btopProc.running = true
            }
        }
    }

    Process { id: audioLauncher; command: ["zen0x-launch-audio"] }
    Process { id: volUp;   command: ["qs", "ipc", "call", "osd", "volumeUp"] }
    Process { id: volDown; command: ["qs", "ipc", "call", "osd", "volumeDown"] }
    Process { id: btopProc; command: ["kitty", "--", "btop"] }
}
