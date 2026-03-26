import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "zen0x-wallpicker"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property string currentWallpaper: ""
    property var walls: []
    property int selectedIndex: 0
    property real cardWidth: 280
    property real cardHeight: 380
    property real skew: -12

    // --- Resolve current wallpaper path ---
    Process {
        id: wallpaperResolver
        command: ["bash", "-c", "readlink -f \"$HOME/.current_wallpaper\""]
        stdout: StdioCollector {
            onStreamFinished: {
                let path = this.text.trim();
                if (path.length > 0) root.currentWallpaper = "file://" + path;
            }
        }
    }

    // --- Load walls from current theme ---
    Process {
        id: wallLoader
        command: ["bash", "-c",
            "find \"$HOME/.config/themes/current/wallpapers\" " +
            "-maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) " +
            "| sort"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n").filter(l => l.length > 0);
                root.walls = lines.map(p => ({ path: p, name: p.split("/").pop().replace(/\.[^/.]+$/, "") }));
                root.selectedIndex = 0;
            }
        }
    }

    // --- Apply wallpaper ---
    Process {
        id: wallApply
        command: []
    }

    function applyWall(wall) {
        wallApply.command = ["bash", "-c",
            "awww img '" + wall.path + "' --transition-type grow --transition-duration 2 --transition-fps 60; " +
            "ln -sf '" + wall.path + "' \"$HOME/.current_wallpaper\""
        ];
        wallApply.running = true;
        root.hide();
    }

    function show() {
        wallpaperResolver.running = true;
        wallLoader.running = true;
        root.visible = true;
        keyHandler.forceActiveFocus();
    }

    function hide() {
        root.visible = false;
    }

    IpcHandler {
        target: "wallpicker"
        function toggle(): void {
            if (root.visible) root.hide();
            else root.show();
        }
    }

    // --- Blurred background ---
    Image {
        id: bgImage
        anchors.fill: parent
        source: root.currentWallpaper
        fillMode: Image.PreserveAspectCrop
        visible: false
        cache: false
    }

    MultiEffect {
        anchors.fill: bgImage
        source: bgImage
        blurEnabled: true
        blurMax: 64
        blur: 1.0
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
    }

    // --- Keyboard ---
    Item {
        id: keyHandler
        focus: true
        anchors.fill: parent

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.hide();
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                if (root.selectedIndex > 0) root.selectedIndex--;
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                if (root.selectedIndex < root.walls.length - 1) root.selectedIndex++;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (root.walls.length > 0) root.applyWall(root.walls[root.selectedIndex]);
                event.accepted = true;
            }
        }
    }

    // Click outside carousel to close
    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
    }

    // --- Wallpaper name ---
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: carousel.top
        anchors.bottomMargin: -20
        text: root.walls.length > 0 ? root.walls[root.selectedIndex].name : ""
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 14
        font.weight: Font.Medium
        color: "white"
    }

    // --- Counter ---
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: carousel.top
        anchors.bottomMargin: -40
        text: root.walls.length > 0 ? (root.selectedIndex + 1) + " / " + root.walls.length : ""
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 11
        color: Qt.rgba(1, 1, 1, 0.6)
    }

    // --- Carousel ---
    Item {
        id: carousel
        anchors.centerIn: parent
        width: parent.width
        height: root.cardHeight

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Repeater {
            model: root.walls.length

            Item {
                id: card

                property int offset: index - root.selectedIndex
                property bool isCurrent: offset === 0
                property real spacing: 200
                property var wall: root.walls[index]

                visible: Math.abs(offset) <= 4

                x: carousel.width / 2 - root.cardWidth / 2 + offset * spacing
                y: (carousel.height - root.cardHeight) / 2
                width: root.cardWidth
                height: root.cardHeight
                z: 100 - Math.abs(offset)

                opacity: isCurrent ? 1.0 : Math.max(0.2, 1.0 - Math.abs(offset) * 0.25)
                scale: isCurrent ? 1.0 : Math.max(0.75, 1.0 - Math.abs(offset) * 0.08)

                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                transform: Matrix4x4 {
                    matrix: {
                        let m = Qt.matrix4x4();
                        m.m12 = Math.tan(root.skew * Math.PI / 180);
                        return m;
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#111"
                    border.color: card.isCurrent ? "white" : "transparent"
                    border.width: 2
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: card.visible && card.wall ? "file://" + card.wall.path : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 400
                        sourceSize.height: 540
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        color: Qt.rgba(0, 0, 0, card.isCurrent ? 0 : 0.4)
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (card.isCurrent) root.applyWall(card.wall);
                        else root.selectedIndex = index;
                    }
                }
            }
        }
    }
}
