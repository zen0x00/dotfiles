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

    NotificationServer {
        id: server
        bodyHyperlinksSupported: true
        bodyMarkupSupported: true
        keepOnReload: true

        onNotification: (notification) => {
            notifModel.insert(0, { notif: notification });
            notification.tracked = true;

            // Add to history
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
                    radius: 14
                    color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.95)
                    border.color: Colors.bg2
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
                                color: Colors.fg2
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "✕"
                                font.pixelSize: 12
                                color: Colors.fg2
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
                            color: Colors.fg0
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            visible: text.length > 0
                        }

                        Text {
                            text: notif.body ?? ""
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 12
                            font.weight: 400
                            color: Colors.fg1
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
                                    radius: 8
                                    color: actionMouse.containsMouse ? Colors.accent : Colors.bg3

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 11
                                        font.weight: 600
                                        color: actionMouse.containsMouse ? Colors.bg0 : Colors.fg0
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

    // ── Notification Center (fullscreen overlay) ──
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
        WlrLayershell.namespace: "zen0x-notification-center"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        function show() {
            root.unreadCount = 0;
            center.visible = true;
            centerKey.forceActiveFocus();
        }

        function hide() {
            center.visible = false;
        }

        IpcHandler {
            target: "notifications"

            function toggle(): void {
                if (center.visible) center.hide();
                else center.show();
            }
        }

        // Dismiss on click outside panel
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
            width: 400
            radius: 16
            color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.95)
            border.color: Colors.bg2
            border.width: 1

            // Prevent clicks on panel from closing
            MouseArea {
                anchors.fill: parent
                onClicked: (event) => event.accepted = true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 0

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Notifications"
                        font.family: "JetBrainsMono Nerd Font Mono"
                        font.pixelSize: 16
                        font.weight: 700
                        color: Colors.fg0
                        Layout.fillWidth: true
                    }

                    // Clear all button
                    Rectangle {
                        width: clearRow.implicitWidth + 16
                        height: 28
                        radius: 8
                        color: clearMouse.containsMouse ? Colors.bg3 : "transparent"
                        visible: root.historyList.length > 0

                        Row {
                            id: clearRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "Clear"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 11
                                font.weight: 600
                                color: Colors.fg2
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.historyList = [];
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    height: 1
                    color: Colors.bg2
                }

                // Empty state
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.historyList.length === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "󰂚"
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 48
                            color: Colors.bg4
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "No notifications"
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 13
                            color: Colors.fg2
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Notification list
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: historyColumn.implicitHeight
                    clip: true
                    visible: root.historyList.length > 0
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: historyColumn
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: root.historyList

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                implicitHeight: historyContent.implicitHeight + 24
                                radius: 12
                                color: historyMouse.containsMouse ? Colors.bg3 : Qt.rgba(Colors.bg1.r, Colors.bg1.g, Colors.bg1.b, 0.4)

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                ColumnLayout {
                                    id: historyContent
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 4

                                    RowLayout {
                                        spacing: 8
                                        Layout.fillWidth: true

                                        Image {
                                            source: modelData.appIcon ?? ""
                                            sourceSize.width: 16
                                            sourceSize.height: 16
                                            visible: status === Image.Ready
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Text {
                                            text: modelData.appName
                                            font.family: "JetBrainsMono Nerd Font Mono"
                                            font.pixelSize: 10
                                            font.weight: 600
                                            color: Colors.fg2
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: formatTime(modelData.time)
                                            font.family: "JetBrainsMono Nerd Font Mono"
                                            font.pixelSize: 10
                                            color: Colors.bg4
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Text {
                                            text: "✕"
                                            font.pixelSize: 11
                                            color: Colors.fg2
                                            opacity: historyMouse.containsMouse ? 1 : 0
                                            Layout.alignment: Qt.AlignVCenter

                                            Behavior on opacity {
                                                NumberAnimation { duration: 100 }
                                            }

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
                                        font.pixelSize: 12
                                        font.weight: 700
                                        color: Colors.fg0
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                    }

                                    Text {
                                        text: modelData.body
                                        font.family: "JetBrainsMono Nerd Font Mono"
                                        font.pixelSize: 11
                                        color: Colors.fg1
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                        maximumLineCount: 3
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
                    }
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
