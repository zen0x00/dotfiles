import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    property real volume: 0
    property bool muted: false

    function getIcon(): string {
        if (root.muted) return "󰖁";
        if (root.volume < 0.33) return "󰕿";
        if (root.volume < 0.66) return "󰖀";
        return "󰕾";
    }

    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Output: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
                let out = this.text.trim();
                let parts = out.split(" ");
                if (parts.length >= 2) {
                    root.volume = parseFloat(parts[1]) || 0;
                    root.muted = out.includes("[MUTED]");
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeProc.running = true
    }

    Text {
        id: icon
        text: root.getIcon()
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 20
        color: Colors.fg0
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton) {
                muteProc.startDetached();
            } else {
                launchProc.startDetached();
            }
        }

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0)
                scrollUpProc.startDetached();
            else
                scrollDownProc.startDetached();
        }
    }

    Process {
        id: scrollUpProc
        command: ["quickshell", "ipc", "call", "osd", "volumeUp"]
    }

    Process {
        id: scrollDownProc
        command: ["quickshell", "ipc", "call", "osd", "volumeDown"]
    }

    Process {
        id: muteProc
        command: ["quickshell", "ipc", "call", "osd", "volumeMute"]
    }

    Process {
        id: launchProc
        command: ["zen0x-launch-or-focus-tui", "wiremix"]
    }
}
