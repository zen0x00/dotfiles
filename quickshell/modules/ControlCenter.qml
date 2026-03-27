import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    implicitWidth: 460
    implicitHeight: wrapper.implicitHeight
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "zen0x-controlcenter"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    IpcHandler {
        target: "controlcenter"
        function toggle(): void {
            root.visible = !root.visible;
            if (root.visible) {
                wrapper.opacity = 1;
                refreshStatus();
            } else {
                wrapper.opacity = 0;
            }
        }
    }

    Shortcut { sequences: ["Escape"]; onActivated: root.visible = false }

    // ── Helpers ──
    property string wifiToggleLabel: "Wi-Fi: Unknown"
    property string btToggleLabel: "Bluetooth: Unknown"
    property string wifiIcon: ""
    property string btIcon: ""

    function setVolume(v) {
        volProc.command = ["bash", "-c",
            "wpctl set-volume @DEFAULT_SINK@ " + v + "% 2>/dev/null || " +
            "pactl set-sink-volume @DEFAULT_SINK@ " + v + "% 2>/dev/null || true"
        ];
        volProc.running = true;
    }

    function setBrightness(v) {
        brightProc.command = ["bash", "-c",
            "brightnessctl set " + v + "% 2>/dev/null || " +
            "xbacklight -set " + v + " 2>/dev/null || true"
        ];
        brightProc.running = true;
    }

    function toggleWifi() {
        wifiProc.command = ["bash", "-c", "nmcli radio wifi toggle 2>/dev/null || true"];
        wifiProc.running = true;
    }

    function toggleBluetooth() {
        btProc.command = ["bash", "-c",
            "state=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2}'); " +
            "[ \"$state\" = \"yes\" ] && bluetoothctl power off || bluetoothctl power on"
        ];
        btProc.running = true;
    }

    function refreshStatus() {
        volRead.command = ["bash", "-c",
            "wpctl get-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print int($2*100)}' || " +
            "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '/\\//{print int($5)}' || echo 100"
        ];
        volRead.running = true;

        brightRead.command = ["bash", "-c",
            "brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,\"\",$4); print int($4)}' || " +
            "xbacklight -get 2>/dev/null | awk '{print int($1)}' || echo 50"
        ];
        brightRead.running = true;

        wifiRead.command = ["bash", "-c", "nmcli radio wifi 2>/dev/null || echo unknown"];
        wifiRead.running = true;

        btRead.command = ["bash", "-c",
            "bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2}' || echo unknown"
        ];
        btRead.running = true;
    }

    // ── Processes ──
    Process { id: volProc }
    Process { id: brightProc }
    Process { id: wifiProc }
    Process { id: btProc }
    Process { id: networkSettingsProc; command: ["nm-connection-editor"] }
    Process { id: bluetoothSettingsProc; command: ["blueman-manager"] }
    Process { id: lockProc; command: ["bash", "-c", "hyprlock"] }

    Process {
        id: volRead
        stdout: StdioCollector {
            onStreamFinished: {
                let v = parseInt(this.text.trim()) || 100;
                volPercentText.text = v + "%";
                volSlider.value = v;
            }
        }
    }
    Process {
        id: brightRead
        stdout: StdioCollector {
            onStreamFinished: {
                let v = parseInt(this.text.trim()) || 50;
                brightPercentText.text = v + "%";
                brightSlider.value = v;
            }
        }
    }
    Process {
        id: wifiRead
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiToggleLabel = "Wi-Fi: " + (this.text.trim() || "unknown");
            }
        }
    }
    Process {
        id: btRead
        stdout: StdioCollector {
            onStreamFinished: {
                root.btToggleLabel = "BT: " + (this.text.trim() || "unknown");
            }
        }
    }

    // ── UI ──
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: wrapper
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6
        width: 460
        implicitHeight: innerColumn.implicitHeight + 28
        radius: 16
        color: Qt.rgba(Colors.surfaceContainerHighest.r, Colors.surfaceContainerHighest.g, Colors.surfaceContainerHighest.b, 0.92)
        border.color: Qt.rgba(Colors.outlineVariant.r, Colors.outlineVariant.g, Colors.outlineVariant.b, 0.22)
        border.width: 1
        opacity: 0.0

        MouseArea { anchors.fill: parent }

        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        ColumnLayout {
            id: innerColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Control Center"
                    color: Colors.contentSurface
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 14
                    font.weight: 600
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 28; height: 28
                    radius: 8
                    color: closeHover.containsMouse
                        ? Qt.rgba(Colors.surfaceContainer.r, Colors.surfaceContainer.g, Colors.surfaceContainer.b, 0.3)
                        : "transparent"
                    Text { anchors.centerIn: parent; text: "✕"; color: Colors.contentSurfaceVariant; font.pixelSize: 12 }
                    MouseArea { id: closeHover; anchors.fill: parent; hoverEnabled: true; onClicked: root.visible = false }
                }
            }

            // Quick toggles
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: [
                        { icon: root.wifiIcon,  label: root.wifiToggleLabel, action: "wifi" },
                        { icon: root.btIcon,    label: root.btToggleLabel,   action: "bt" },
                        { icon: "󰂛",            label: "Do Not Disturb",      action: "" },
                        { icon: "󰌦",            label: "Lock",                action: "lock" }
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        radius: 12
                        color: toggleHover.containsMouse
                            ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.08)
                            : Qt.rgba(Colors.surfaceContainer.r, Colors.surfaceContainer.g, Colors.surfaceContainer.b, 0.4)
                        border.color: Qt.rgba(Colors.outlineVariant.r, Colors.outlineVariant.g, Colors.outlineVariant.b, 0.15)

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                font.pixelSize: 20
                                color: Colors.primary
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                color: Colors.contentSurface
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: toggleHover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.action === "wifi") root.toggleWifi();
                                else if (modelData.action === "bt") root.toggleBluetooth();
                                else if (modelData.action === "lock") lockProc.running = true;
                            }
                        }
                    }
                }
            }

            // Volume
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: ""; font.pixelSize: 16; color: Colors.primary }
                    Text { text: "Volume"; color: Colors.contentSurface; font.family: "JetBrainsMono Nerd Font Mono"; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Text { id: volPercentText; text: "--%"; color: Colors.contentSurfaceVariant; font.family: "JetBrainsMono Nerd Font Mono"; font.pixelSize: 12 }
                }
                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    from: 0; to: 150; value: 100
                    onMoved: { volPercentText.text = Math.round(value) + "%"; root.setVolume(Math.round(value)); }
                }
            }

            // Brightness
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: ""; font.pixelSize: 16; color: Colors.tertiary }
                    Text { text: "Brightness"; color: Colors.contentSurface; font.family: "JetBrainsMono Nerd Font Mono"; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Text { id: brightPercentText; text: "--%"; color: Colors.contentSurfaceVariant; font.family: "JetBrainsMono Nerd Font Mono"; font.pixelSize: 12 }
                }
                Slider {
                    id: brightSlider
                    Layout.fillWidth: true
                    from: 1; to: 100; value: 50
                    onMoved: { brightPercentText.text = Math.round(value) + "%"; root.setBrightness(Math.round(value)); }
                }
            }
        }
    }
}
