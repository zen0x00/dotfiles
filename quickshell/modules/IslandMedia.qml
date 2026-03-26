import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root

    property bool hasMedia: false
    property string title: ""
    property string artist: ""
    property string status: "Stopped"

    implicitWidth: hasMedia ? content.implicitWidth : 0
    implicitHeight: parent ? parent.height : 36
    visible: hasMedia

    clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    // --- playerctl --follow for event-driven updates ---
    Process {
        id: playerFollow
        command: ["playerctl", "metadata", "--follow", "--format", "{{title}}\n{{artist}}\n{{status}}"]
        running: true
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                let lines = data.trim().split("\n");
                if (lines.length >= 3) {
                    root.title = lines[0] || "";
                    root.artist = lines[1] || "";
                    root.status = lines[2] || "Stopped";
                    root.hasMedia = root.status !== "Stopped" && root.title.length > 0;
                }
            }
        }
    }

    // --- Play/pause ---
    Process {
        id: playPause
        command: ["playerctl", "play-pause"]
    }

    RowLayout {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 8

        // Play/pause icon
        Rectangle {
            width: 26
            height: 26
            radius: 6
            color: Colors.primary
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: root.status === "Playing" ? 0 : 1
                anchors.verticalCenterOffset: 1
                text: root.status === "Playing" ? "󰏤" : "󰐊"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 14
                color: Colors.surface
            }
        }

        // Title + Artist
        Column {
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                text: root.title
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 11
                font.weight: 600
                color: Colors.contentSurface
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 140)
            }

            Text {
                text: root.artist
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 9
                color: Colors.contentSurfaceVariant
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 140)
                visible: text.length > 0
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: playPause.running = true
    }
}
