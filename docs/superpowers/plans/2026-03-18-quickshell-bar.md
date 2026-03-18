# QuickShell Bar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a floating pill-style top bar in QuickShell with workspaces, clock, volume, network, and bluetooth modules, replacing Waybar.

**Architecture:** A `PanelWindow` anchored top/left/right with margins for the floating pill effect. Child widgets are modular QML components arranged in a `RowLayout` (left: workspaces, center: clock, right: volume/network/bluetooth). Status widgets poll external commands via `Process` + `Timer` + `StdioCollector`.

**Tech Stack:** QuickShell 0.2.1, QML/Qt6, Hyprland IPC, wpctl, nmcli, bluetoothctl

**Spec:** `docs/superpowers/specs/2026-03-18-quickshell-bar-design.md`

---

### Task 1: Bar Shell + Clock (Minimal Visible Bar)

Build the bar panel and clock first to get something visible on screen immediately.

**Files:**
- Create: `quickshell/modules/Bar.qml`
- Create: `quickshell/modules/BarClock.qml`
- Modify: `quickshell/modules/qmldir`
- Modify: `quickshell/shell.qml`

- [ ] **Step 1: Create BarClock.qml**

```qml
import QtQuick

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string timeText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let now = new Date();
            let hours = now.getHours();
            let ampm = hours >= 12 ? "PM" : "AM";
            hours = hours % 12;
            if (hours === 0) hours = 12;
            let minutes = now.getMinutes().toString().padStart(2, '0');
            root.timeText = hours + ":" + minutes + " " + ampm;
        }
    }

    Text {
        id: label
        text: root.timeText
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 13
        color: Colors.fg0
    }
}
```

- [ ] **Step 2: Create Bar.qml**

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.top: 8
    margins.left: 8
    margins.right: 8

    height: 36
    color: "transparent"
    exclusionMode: ExclusionMode.Auto

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-bar"

    Rectangle {
        id: pill
        anchors.fill: parent
        color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.95)
        radius: 18
        border.color: Colors.bg2
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 0

            // Left spacer
            Item { Layout.fillWidth: true }

            BarClock {}

            // Right spacer
            Item { Layout.fillWidth: true }
        }
    }
}
```

- [ ] **Step 3: Register in qmldir**

Add to `quickshell/modules/qmldir` after existing entries:

```
Bar 1.0 Bar.qml
BarClock 1.0 BarClock.qml
```

- [ ] **Step 4: Add Bar to shell.qml**

```qml
import Quickshell
import Quickshell.Io
import "modules"

ShellRoot {
    Launcher {}
    Bar {}
}
```

- [ ] **Step 5: Add layerrules for zen0x-bar**

Append to `hypr/apps/quickshell.conf`:

```
layerrule = blur on, match:namespace zen0x-bar
layerrule = ignore_alpha 0.3, match:namespace zen0x-bar
```

- [ ] **Step 6: Test — restart QuickShell and verify bar appears**

```bash
pkill -x quickshell; uwsm-app -- quickshell -d &
```

Expected: floating pill bar at top of screen with centered clock. Windows should not overlap the bar.

- [ ] **Step 7: Commit**

```bash
git add quickshell/modules/Bar.qml quickshell/modules/BarClock.qml quickshell/modules/qmldir quickshell/shell.qml hypr/apps/quickshell.conf
git commit -m "feat: add quickshell bar with clock widget"
```

---

### Task 2: Workspace Indicators

**Files:**
- Create: `quickshell/modules/BarWorkspaces.qml`
- Modify: `quickshell/modules/Bar.qml`
- Modify: `quickshell/modules/qmldir`

- [ ] **Step 1: Create BarWorkspaces.qml**

```qml
import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property var modelData

            width: modelData.focused ? 16 : 8
            height: 8
            radius: 4
            color: modelData.focused ? Colors.accent : Colors.fg1

            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}
```

- [ ] **Step 2: Add workspaces to Bar.qml layout**

Replace the RowLayout contents in Bar.qml:

```qml
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 0

            BarWorkspaces {
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            BarClock {
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
        }
```

- [ ] **Step 3: Register in qmldir**

Add to `quickshell/modules/qmldir`:

```
BarWorkspaces 1.0 BarWorkspaces.qml
```

- [ ] **Step 4: Test — restart QuickShell, switch workspaces**

```bash
pkill -x quickshell; uwsm-app -- quickshell -d &
```

Expected: dot indicators on left, active workspace shows as wider accent-colored pill. Clicking dots switches workspace. Animation on focus change.

- [ ] **Step 5: Commit**

```bash
git add quickshell/modules/BarWorkspaces.qml quickshell/modules/Bar.qml quickshell/modules/qmldir
git commit -m "feat: add workspace indicators to bar"
```

---

### Task 3: Volume Widget

**Files:**
- Create: `quickshell/modules/BarVolume.qml`
- Modify: `quickshell/modules/Bar.qml`
- Modify: `quickshell/modules/qmldir`

- [ ] **Step 1: Create BarVolume.qml**

```qml
import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    property real volume: 0
    property bool muted: false

    function getIcon(): string {
        if (root.muted) return "";
        if (root.volume < 0.33) return "";
        if (root.volume < 0.66) return "";
        return "";
    }

    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            id: collector
            onDataChanged: {
                // Output: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
                let text = collector.text.trim();
                let parts = text.split(" ");
                if (parts.length >= 2) {
                    root.volume = parseFloat(parts[1]) || 0;
                    root.muted = text.includes("[MUTED]");
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeProc.exec()
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
        command: ["swayosd-client", "--output-volume", "raise"]
    }

    Process {
        id: scrollDownProc
        command: ["swayosd-client", "--output-volume", "lower"]
    }

    Process {
        id: muteProc
        command: ["swayosd-client", "--output-volume", "mute"]
    }

    Process {
        id: launchProc
        command: ["zen0x-launch-or-focus-tui", "wiremix"]
    }
}
```

- [ ] **Step 2: Add volume to Bar.qml right section**

Update the RowLayout in Bar.qml — add a right-side `Row` after the second spacer:

```qml
            Item { Layout.fillWidth: true }

            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                BarVolume {}
            }
```

- [ ] **Step 3: Register in qmldir**

Add to `quickshell/modules/qmldir`:

```
BarVolume 1.0 BarVolume.qml
```

- [ ] **Step 4: Test — restart, scroll to change volume, click to open wiremix**

```bash
pkill -x quickshell; uwsm-app -- quickshell -d &
```

Expected: volume icon on right side. Scroll changes volume via swayosd. Click opens wiremix. Icon changes based on level.

- [ ] **Step 5: Commit**

```bash
git add quickshell/modules/BarVolume.qml quickshell/modules/Bar.qml quickshell/modules/qmldir
git commit -m "feat: add volume widget to bar"
```

---

### Task 4: Network Widget

**Files:**
- Create: `quickshell/modules/BarNetwork.qml`
- Modify: `quickshell/modules/Bar.qml`
- Modify: `quickshell/modules/qmldir`

- [ ] **Step 1: Create BarNetwork.qml**

```qml
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
```

- [ ] **Step 2: Add BarNetwork to Bar.qml right Row**

In Bar.qml, add `BarNetwork {}` inside the right-side `Row`:

```qml
            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                BarVolume {}
                BarNetwork {}
            }
```

- [ ] **Step 3: Register in qmldir**

Add to `quickshell/modules/qmldir`:

```
BarNetwork 1.0 BarNetwork.qml
```

- [ ] **Step 4: Test — restart, verify icon matches connection type**

```bash
pkill -x quickshell; uwsm-app -- quickshell -d &
```

Expected: wifi signal icon or ethernet icon on right. Click opens wifi manager.

- [ ] **Step 5: Commit**

```bash
git add quickshell/modules/BarNetwork.qml quickshell/modules/Bar.qml quickshell/modules/qmldir
git commit -m "feat: add network widget to bar"
```

---

### Task 5: Bluetooth Widget

**Files:**
- Create: `quickshell/modules/BarBluetooth.qml`
- Modify: `quickshell/modules/Bar.qml`
- Modify: `quickshell/modules/qmldir`

- [ ] **Step 1: Create BarBluetooth.qml**

```qml
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
```

- [ ] **Step 2: Add BarBluetooth to Bar.qml right Row**

```qml
            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                BarVolume {}
                BarNetwork {}
                BarBluetooth {}
            }
```

- [ ] **Step 3: Register in qmldir**

Add to `quickshell/modules/qmldir`:

```
BarBluetooth 1.0 BarBluetooth.qml
```

- [ ] **Step 4: Test — restart, verify bluetooth icon state**

```bash
pkill -x quickshell; uwsm-app -- quickshell -d &
```

Expected: bluetooth icon on right side. Shows connected/on/off state. Click opens bluetooth manager.

- [ ] **Step 5: Commit**

```bash
git add quickshell/modules/BarBluetooth.qml quickshell/modules/Bar.qml quickshell/modules/qmldir
git commit -m "feat: add bluetooth widget to bar"
```

---

### Task 6: Remove Waybar

**Files:**
- Modify: `hypr/configs/execs.conf`
- Modify: `bin/zen0x-theme-reload`

- [ ] **Step 1: Remove waybar from execs.conf**

Remove line 3: `exec-once = uwsm-app -- waybar`

- [ ] **Step 2: Remove waybar from zen0x-theme-reload**

Remove `killall -9 waybar 2>/dev/null` (line 3) and `waybar &` (line 5). Update notification text from `"Waybar, SwayNC, SwayOSD, Kitty and QuickShell"` to `"SwayNC, SwayOSD, Kitty and QuickShell"`.

- [ ] **Step 3: Commit**

```bash
git add hypr/configs/execs.conf bin/zen0x-theme-reload
git commit -m "chore: remove waybar, quickshell bar is the replacement"
```
