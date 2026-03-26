import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
    id: root

    property var historyList: []
    property int unreadCount: 0
    property bool dndEnabled: false

    // ── System state ──
    property real volumeLevel: 0.0
    property bool volumeMuted: false
    property string networkState: "disconnected"
    property string networkName: ""
    property string btState: "off"
    property string btDevice: ""
    property real brightnessLevel: 1.0
    property real brightnessMax: 1.0

    // ── Media state ──
    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaStatus: ""  // Playing, Paused, Stopped, ""

    NotificationServer {
        id: server
        bodyHyperlinksSupported: true
        bodyMarkupSupported: true
        keepOnReload: true

        onNotification: (notification) => {
            if (root.dndEnabled) {
                // Still save to history but don't show popup
                notification.tracked = true;
                root.historyList = [{
                    appName: notification.appName ?? "Notification",
                    appIcon: notification.appIcon ?? "",
                    summary: notification.summary ?? "",
                    body: notification.body ?? "",
                    time: new Date()
                }].concat(root.historyList).slice(0, 100);
                root.unreadCount++;
                return;
            }

            notifModel.insert(0, { notif: notification });
            notification.tracked = true;

            root.historyList = [{
                appName: notification.appName ?? "Notification",
                appIcon: notification.appIcon ?? "",
                summary: notification.summary ?? "",
                body: notification.body ?? "",
                time: new Date()
            }].concat(root.historyList).slice(0, 100);
            root.unreadCount++;
        }
    }

    ListModel {
        id: notifModel
    }

    // ── Pollers ──

    Process {
        id: volumePoll
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                let parts = out.split(" ");
                if (parts.length >= 2) {
                    root.volumeLevel = parseFloat(parts[1]);
                    root.volumeMuted = out.includes("[MUTED]");
                }
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: volumePoll.running = true
    }

    Process {
        id: networkPoll
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device | head -5"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                let lines = out.split("\n");
                root.networkState = "disconnected";
                root.networkName = "";
                for (let line of lines) {
                    let parts = line.split(":");
                    if (parts[1] === "connected") {
                        root.networkState = parts[0] === "ethernet" ? "ethernet" : "wifi";
                        root.networkName = parts[2] ?? "";
                        break;
                    }
                }
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: networkPoll.running = true
    }

    Process {
        id: btPoll
        command: ["bash", "-c", "systemctl is-active bluetooth > /dev/null 2>&1 && bluetoothctl show | grep 'Powered:' || echo 'Powered: no'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                if (out.includes("yes")) {
                    root.btState = "on";
                    btDevicePoll.running = true;
                } else {
                    root.btState = "off";
                    root.btDevice = "";
                }
            }
        }
    }

    Process {
        id: btDevicePoll
        command: ["bash", "-c", "bluetoothctl devices Connected | head -1 | cut -d' ' -f3-"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                if (out.length > 0) {
                    root.btState = "connected";
                    root.btDevice = out;
                }
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: btPoll.running = true
    }

    Process {
        id: brightnessPoll
        command: ["bash", "-c", "brightnessctl info -m 2>/dev/null | cut -d, -f2,5 || echo '0,0'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                // format: "current,max" or percentage
                let parts = out.split(",");
                if (parts.length >= 2) {
                    root.brightnessLevel = parseInt(parts[0]) || 0;
                    root.brightnessMax = parseInt(parts[1]) || 1;
                }
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: brightnessPoll.running = true
    }

    Process {
        id: mediaPoll
        command: ["bash", "-c", "playerctl metadata --format '{{title}}\\n{{artist}}\\n{{status}}' 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                let lines = out.split("\n");
                root.mediaTitle = lines[0] ?? "";
                root.mediaArtist = lines[1] ?? "";
                root.mediaStatus = lines[2] ?? "";
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: mediaPoll.running = true
    }

    // ── Action processes ──
    Process {
        id: volumeSet
        property string cmd: ""
        command: ["bash", "-c", cmd]
    }

    Process {
        id: brightnessSet
        property string cmd: ""
        command: ["bash", "-c", cmd]
    }

    Process {
        id: mediaCmd
        property string cmd: ""
        command: ["bash", "-c", cmd]
    }

    Process {
        id: btToggle
        property string cmd: ""
        command: ["bash", "-c", cmd]
    }

    Process {
        id: networkCmd
        property string cmd: ""
        command: ["bash", "-c", cmd]
    }

    // ── Live notification popups (top-right) ──
    PanelWindow {
        id: popup

        screen: Quickshell.screens[0]

        anchors.top: true
        anchors.right: true
        margins.top: 52
        margins.right: 12

        width: 380
        height: Math.min(notifColumn.implicitHeight, 600)

        visible: notifModel.count > 0 && !center.visible
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "zen0x-notifications"

        ColumnLayout {
            id: notifColumn
            width: parent.width
            spacing: 8

            Repeater {
                model: notifModel

                delegate: Rectangle {
                    id: card
                    required property var notif
                    required property int index

                    Layout.fillWidth: true
                    implicitHeight: cardContent.implicitHeight + 24
                    radius: 12
                    color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.95)
                    border.color: Colors.outlineVariant
                    border.width: 1
                    opacity: 0
                    x: 40

                    Component.onCompleted: {
                        opacity = 1;
                        x = 0;

                        if (notif.expireTimeout > 0) {
                            dismissTimer.interval = notif.expireTimeout;
                        } else {
                            dismissTimer.interval = 5000;
                        }
                        dismissTimer.start();
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }

                    Behavior on x {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }

                    Timer {
                        id: dismissTimer
                        onTriggered: {
                            card.opacity = 0;
                            card.x = 40;
                            removeTimer.start();
                        }
                    }

                    Timer {
                        id: removeTimer
                        interval: 250
                        onTriggered: {
                            notif.dismiss();
                            notifModel.remove(card.index);
                        }
                    }

                    ColumnLayout {
                        id: cardContent
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        RowLayout {
                            spacing: 8
                            Layout.fillWidth: true

                            Image {
                                source: notif.appIcon ?? ""
                                sourceSize.width: 20
                                sourceSize.height: 20
                                visible: status === Image.Ready
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: notif.appName ?? "Notification"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 11
                                font.weight: 600
                                color: Colors.contentSurfaceVariant
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "✕"
                                font.pixelSize: 12
                                color: Colors.contentSurfaceVariant
                                Layout.alignment: Qt.AlignVCenter

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        notif.dismiss();
                                        notifModel.remove(card.index);
                                    }
                                }
                            }
                        }

                        Text {
                            text: notif.summary ?? ""
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 13
                            font.weight: 700
                            color: Colors.contentSurface
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            visible: text.length > 0
                        }

                        Text {
                            text: notif.body ?? ""
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 12
                            font.weight: 400
                            color: Colors.contentSurfaceVariant
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            visible: text.length > 0
                        }

                        RowLayout {
                            spacing: 6
                            Layout.fillWidth: true
                            visible: notif.actions.length > 0

                            Repeater {
                                model: notif.actions

                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 28
                                    radius: 12
                                    color: actionMouse.containsMouse ? Colors.primary : Colors.surfaceContainer

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 11
                                        font.weight: 600
                                        color: actionMouse.containsMouse ? Colors.surface : Colors.contentSurface
                                    }

                                    MouseArea {
                                        id: actionMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            modelData.invoke();
                                            notifModel.remove(card.index);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onClicked: {
                            if (notif.actions.length > 0) {
                                notif.actions[0].invoke();
                            }
                            notifModel.remove(card.index);
                        }
                    }
                }
            }
        }
    }

    // ── Control Center (fullscreen overlay) ──
    PanelWindow {
        id: center

        screen: Quickshell.screens[0]

        anchors.top: true
        anchors.left: true
        anchors.right: true
        anchors.bottom: true

        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "zen0x-control-center"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        function show() {
            root.unreadCount = 0;
            volumePoll.running = true;
            networkPoll.running = true;
            btPoll.running = true;
            brightnessPoll.running = true;
            mediaPoll.running = true;
            center.visible = true;
            centerKey.forceActiveFocus();
        }

        function hide() {
            center.visible = false;
        }

        IpcHandler {
            target: "controlcenter"

            function toggle(): void {
                if (center.visible) center.hide();
                else center.show();
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: center.hide()
        }

        Item {
            id: centerKey
            focus: true
            anchors.fill: parent
            Keys.onEscapePressed: center.hide()
        }

        // Right-side panel
        Rectangle {
            id: panel
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: 52
            anchors.bottomMargin: 12
            anchors.rightMargin: 12
            width: 420
            radius: 12
            color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.95)
            border.color: Colors.outlineVariant
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: (event) => event.accepted = true
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentHeight: mainColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: mainColumn
                    width: parent.width
                    spacing: 12

                    // ── Header ──
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Control Center"
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 16
                            font.weight: 700
                            color: Colors.contentSurface
                            Layout.fillWidth: true
                        }

                        // DND Toggle
                        Rectangle {
                            width: dndRow.implicitWidth + 16
                            height: 28
                            radius: 12
                            color: root.dndEnabled ? Colors.primary : (dndMouse.containsMouse ? Colors.surfaceContainer : Colors.surfaceContainerLow)

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Row {
                                id: dndRow
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: root.dndEnabled ? "󰂛" : "󰂚"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 14
                                    color: root.dndEnabled ? Colors.surface : Colors.contentSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "DND"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 11
                                    font.weight: 600
                                    color: root.dndEnabled ? Colors.surface : Colors.contentSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: dndMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dndEnabled = !root.dndEnabled
                            }
                        }
                    }

                    // ── Quick Toggles ──
                    Row {
                        Layout.fillWidth: true
                        spacing: 8

                        // WiFi/Network toggle
                        Rectangle {
                            width: (panel.width - 32 - 16) / 3
                            height: 72
                            radius: 12
                            color: root.networkState !== "disconnected" ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15) : Colors.surfaceContainerLow

                            Behavior on color { ColorAnimation { duration: 120 } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: root.networkState === "ethernet" ? "󰈀" : root.networkState === "wifi" ? "󰤨" : "󰤭"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 22
                                    color: root.networkState !== "disconnected" ? Colors.primary : Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: root.networkState === "disconnected" ? "Network" : root.networkName || (root.networkState === "ethernet" ? "Ethernet" : "WiFi")
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 10
                                    font.weight: 600
                                    color: root.networkState !== "disconnected" ? Colors.primary : Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.maximumWidth: parent.parent.width - 16
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    networkCmd.cmd = "uwsm-app -- kitty -e nmtui";
                                    networkCmd.running = true;
                                    center.hide();
                                }
                            }
                        }

                        // Bluetooth toggle
                        Rectangle {
                            width: (panel.width - 32 - 16) / 3
                            height: 72
                            radius: 12
                            color: root.btState !== "off" ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15) : Colors.surfaceContainerLow

                            Behavior on color { ColorAnimation { duration: 120 } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: root.btState === "connected" ? "󰂱" : root.btState === "on" ? "󰂯" : "󰂲"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 22
                                    color: root.btState !== "off" ? Colors.primary : Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: root.btState === "connected" ? root.btDevice : root.btState === "on" ? "Bluetooth" : "Bluetooth"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 10
                                    font.weight: 600
                                    color: root.btState !== "off" ? Colors.primary : Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.maximumWidth: parent.parent.width - 16
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.btState === "off") {
                                        btToggle.cmd = "bluetoothctl power on";
                                    } else {
                                        btToggle.cmd = "bluetoothctl power off";
                                    }
                                    btToggle.running = true;
                                    btPoll.running = true;
                                }
                            }
                        }

                        // DND toggle (big)
                        Rectangle {
                            width: (panel.width - 32 - 16) / 3
                            height: 72
                            radius: 12
                            color: root.dndEnabled ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15) : Colors.surfaceContainerLow

                            Behavior on color { ColorAnimation { duration: 120 } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: root.dndEnabled ? "󰂛" : "󰂚"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 22
                                    color: root.dndEnabled ? Colors.primary : Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: root.dndEnabled ? "DND On" : "DND Off"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 10
                                    font.weight: 600
                                    color: root.dndEnabled ? Colors.primary : Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dndEnabled = !root.dndEnabled
                            }
                        }
                    }

                    // ── Volume Slider ──
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: volumeSliderLayout.implicitHeight + 24
                        radius: 12
                        color: Colors.surfaceContainerLow

                        ColumnLayout {
                            id: volumeSliderLayout
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: root.volumeMuted ? "󰖁" : root.volumeLevel < 0.33 ? "󰕿" : root.volumeLevel < 0.66 ? "󰖀" : "󰕾"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 18
                                    color: root.volumeMuted ? Colors.contentSurfaceVariant : Colors.primary
                                    Layout.alignment: Qt.AlignVCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            volumeSet.cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                                            volumeSet.running = true;
                                            volumePoll.running = true;
                                        }
                                    }
                                }

                                Text {
                                    text: "Volume"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 12
                                    font.weight: 600
                                    color: Colors.contentSurface
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: Math.round(root.volumeLevel * 100) + "%"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 11
                                    color: Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // Slider track
                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 12
                                color: Colors.surfaceContainer

                                Rectangle {
                                    width: Math.min(root.volumeLevel, 1.0) * parent.width
                                    height: parent.height
                                    radius: 12
                                    color: root.volumeMuted ? Colors.contentSurfaceVariant : Colors.primary

                                    Behavior on width {
                                        NumberAnimation { duration: 100 }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        let vol = Math.max(0, Math.min(1, mouse.x / width));
                                        volumeSet.cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + vol.toFixed(2);
                                        volumeSet.running = true;
                                        root.volumeLevel = vol;
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (pressed) {
                                            let vol = Math.max(0, Math.min(1, mouse.x / width));
                                            volumeSet.cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + vol.toFixed(2);
                                            volumeSet.running = true;
                                            root.volumeLevel = vol;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Brightness Slider ──
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: brightnessSliderLayout.implicitHeight + 24
                        radius: 12
                        color: Colors.surfaceContainerLow
                        visible: root.brightnessMax > 0

                        ColumnLayout {
                            id: brightnessSliderLayout
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: root.brightnessMax > 0 && (root.brightnessLevel / root.brightnessMax) < 0.5 ? "󰃞" : "󰃠"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 18
                                    color: Colors.tertiary
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: "Brightness"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 12
                                    font.weight: 600
                                    color: Colors.contentSurface
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: root.brightnessMax > 0 ? Math.round((root.brightnessLevel / root.brightnessMax) * 100) + "%" : "N/A"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 11
                                    color: Colors.contentSurfaceVariant
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 12
                                color: Colors.surfaceContainer

                                Rectangle {
                                    width: root.brightnessMax > 0 ? (root.brightnessLevel / root.brightnessMax) * parent.width : 0
                                    height: parent.height
                                    radius: 12
                                    color: Colors.tertiary

                                    Behavior on width {
                                        NumberAnimation { duration: 100 }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        let pct = Math.max(0.01, Math.min(1, mouse.x / width));
                                        brightnessSet.cmd = "brightnessctl set " + Math.round(pct * 100) + "%";
                                        brightnessSet.running = true;
                                        root.brightnessLevel = pct * root.brightnessMax;
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (pressed) {
                                            let pct = Math.max(0.01, Math.min(1, mouse.x / width));
                                            brightnessSet.cmd = "brightnessctl set " + Math.round(pct * 100) + "%";
                                            brightnessSet.running = true;
                                            root.brightnessLevel = pct * root.brightnessMax;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Media Player ──
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: mediaLayout.implicitHeight + 24
                        radius: 12
                        color: Colors.surfaceContainerLow
                        visible: root.mediaTitle.length > 0

                        ColumnLayout {
                            id: mediaLayout
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "󰎈"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 18
                                    color: Colors.secondary
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: root.mediaTitle
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 12
                                        font.weight: 700
                                        color: Colors.contentSurface
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: root.mediaArtist
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 11
                                        color: Colors.contentSurfaceVariant
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                    }
                                }
                            }

                            // Controls
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 24

                                Text {
                                    text: "󰒮"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 22
                                    color: prevMouse.containsMouse ? Colors.contentSurface : Colors.contentSurfaceVariant

                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    MouseArea {
                                        id: prevMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            mediaCmd.cmd = "playerctl previous";
                                            mediaCmd.running = true;
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 12
                                    color: playMouse.containsMouse ? Colors.primary : Colors.surfaceContainer

                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 20
                                        color: playMouse.containsMouse ? Colors.surface : Colors.contentSurface
                                    }

                                    MouseArea {
                                        id: playMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            mediaCmd.cmd = "playerctl play-pause";
                                            mediaCmd.running = true;
                                        }
                                    }
                                }

                                Text {
                                    text: "󰒭"
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 22
                                    color: nextMouse.containsMouse ? Colors.contentSurface : Colors.contentSurfaceVariant

                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    MouseArea {
                                        id: nextMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            mediaCmd.cmd = "playerctl next";
                                            mediaCmd.running = true;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Separator ──
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.outlineVariant
                    }

                    // ── Notifications Header ──
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Notifications"
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 14
                            font.weight: 700
                            color: Colors.contentSurface
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: clearText.implicitWidth + 16
                            height: 26
                            radius: 12
                            color: clearAllMouse.containsMouse ? Colors.surfaceContainer : "transparent"
                            visible: root.historyList.length > 0

                            Text {
                                id: clearText
                                anchors.centerIn: parent
                                text: "Clear all"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 10
                                font.weight: 600
                                color: Colors.contentSurfaceVariant
                            }

                            MouseArea {
                                id: clearAllMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.historyList = []
                            }
                        }
                    }

                    // ── Empty state ──
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 120
                        visible: root.historyList.length === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "󰂚"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 36
                                color: Colors.surfaceContainerHigh
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "No notifications"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 12
                                color: Colors.contentSurfaceVariant
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // ── Notification history ──
                    Repeater {
                        model: root.historyList

                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            implicitHeight: historyContent.implicitHeight + 20
                            radius: 12
                            color: historyMouse.containsMouse ? Colors.surfaceContainer : Qt.rgba(Colors.surfaceContainerLow.r, Colors.surfaceContainerLow.g, Colors.surfaceContainerLow.b, 0.5)

                            Behavior on color { ColorAnimation { duration: 120 } }

                            ColumnLayout {
                                id: historyContent
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 3

                                RowLayout {
                                    spacing: 8
                                    Layout.fillWidth: true

                                    Image {
                                        source: modelData.appIcon ?? ""
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        visible: status === Image.Ready
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: modelData.appName
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 10
                                        font.weight: 600
                                        color: Colors.contentSurfaceVariant
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: formatTime(modelData.time)
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 9
                                        color: Colors.surfaceContainerHigh
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: "✕"
                                        font.pixelSize: 10
                                        color: Colors.contentSurfaceVariant
                                        opacity: historyMouse.containsMouse ? 1 : 0
                                        Layout.alignment: Qt.AlignVCenter

                                        Behavior on opacity { NumberAnimation { duration: 100 } }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                let arr = root.historyList.slice();
                                                arr.splice(index, 1);
                                                root.historyList = arr;
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: modelData.summary
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 11
                                    font.weight: 700
                                    color: Colors.contentSurface
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                }

                                Text {
                                    text: modelData.body
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    font.pixelSize: 10
                                    color: Colors.contentSurfaceVariant
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: historyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                z: -1
                            }
                        }
                    }

                    // Bottom padding
                    Item { Layout.fillWidth: true; implicitHeight: 8 }
                }
            }
        }
    }

    function formatTime(date: var): string {
        if (!date) return "";
        let now = new Date();
        let diff = Math.floor((now - date) / 1000);

        if (diff < 60) return "now";
        if (diff < 3600) return Math.floor(diff / 60) + "m ago";
        if (diff < 86400) return Math.floor(diff / 3600) + "h ago";
        return Math.floor(diff / 86400) + "d ago";
    }
}
