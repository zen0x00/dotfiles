import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.bottom: true
    margins.bottom: 80

    width: 240
    height: 64

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "zen0x-osd"

    property string mode: "volume"  // "volume" or "brightness"
    property real value: 0.0
    property bool muted: false

    function getVolumeIcon(): string {
        if (root.muted) return "󰖁";
        if (root.value < 0.33) return "󰕿";
        if (root.value < 0.66) return "󰖀";
        return "󰕾";
    }

    function getBrightnessIcon(): string {
        if (root.value < 0.3) return "󰃞";
        if (root.value < 0.7) return "󰃟";
        return "󰃠";
    }

    // ── Volume actions ──
    function volumeUp() {
        volUpProc.running = true;
        showOsd("volume");
    }

    function volumeDown() {
        volDownProc.running = true;
        showOsd("volume");
    }

    function volumeMute() {
        volMuteProc.running = true;
        showOsd("volume");
    }

    // ── Brightness actions ──
    function brightnessUp() {
        brightUpProc.running = true;
        showOsd("brightness");
    }

    function brightnessDown() {
        brightDownProc.running = true;
        showOsd("brightness");
    }

    function showOsd(type: string) {
        root.mode = type;
        // Poll current value after a small delay to let the command take effect
        pollDelay.restart();
        root.visible = true;
        hideTimer.restart();
    }

    Timer {
        id: pollDelay
        interval: 50
        onTriggered: {
            if (root.mode === "volume") volPoll.running = true;
            else brightPoll.running = true;
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible = false
    }

    // ── Pollers ──
    Process {
        id: volPoll
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                let parts = out.split(" ");
                if (parts.length >= 2) {
                    root.value = parseFloat(parts[1]) || 0;
                    root.muted = out.includes("[MUTED]");
                }
            }
        }
    }

    Process {
        id: brightPoll
        command: ["bash", "-c", "brightnessctl info -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo '0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let pct = parseInt(this.text.trim()) || 0;
                root.value = pct / 100;
            }
        }
    }

    // ── Action processes ──
    Process {
        id: volUpProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+", "-l", "1.0"]
    }

    Process {
        id: volDownProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
    }

    Process {
        id: volMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
    }

    Process {
        id: brightUpProc
        command: ["brightnessctl", "set", "5%+"]
    }

    Process {
        id: brightDownProc
        command: ["brightnessctl", "set", "5%-"]
    }

    // ── IPC ──
    IpcHandler {
        target: "osd"

        function volumeUp(): void { root.volumeUp(); }
        function volumeDown(): void { root.volumeDown(); }
        function volumeMute(): void { root.volumeMute(); }
        function brightnessUp(): void { root.brightnessUp(); }
        function brightnessDown(): void { root.brightnessDown(); }
    }

    // ── Visual ──
    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: 0
        color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.95)
        border.color: Colors.bg2
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Text {
                text: root.mode === "volume" ? root.getVolumeIcon() : root.getBrightnessIcon()
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 22
                color: root.mode === "volume" ? (root.muted ? Colors.fg2 : Colors.accent) : Colors.yellow
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 6

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 0
                    color: Colors.bg3

                    Rectangle {
                        width: Math.min(root.value, 1.0) * parent.width
                        height: parent.height
                        radius: 0
                        color: root.mode === "volume" ? (root.muted ? Colors.fg2 : Colors.accent) : Colors.yellow

                        Behavior on width {
                            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }

            Text {
                text: Math.round(root.value * 100) + "%"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 12
                font.weight: 700
                color: Colors.fg0
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 36
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
