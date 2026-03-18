import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    property string status: "on"  // "on", "off", "connected"

    function getIcon(): string {
        if (root.status === "connected") return "";
        if (root.status === "off") return "󰂲";
        return "";
    }

    Process {
        id: btProc
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            id: showCollector
            onDataChanged: {
                let text = showCollector.text;
                if (text.includes("Powered: yes")) {
                    // Check for connected devices
                    connectedProc.exec();
                } else {
                    root.status = "off";
                }
            }
        }
    }

    Process {
        id: connectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: StdioCollector {
            id: connCollector
            onDataChanged: {
                let text = connCollector.text.trim();
                root.status = text.length > 0 ? "connected" : "on";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: btProc.exec()
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
        command: ["zen0x-launch-bluetooth"]
    }
}
