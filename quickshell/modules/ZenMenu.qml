import QtQuick
import QtQuick.Layouts
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

    property var wallpapers: []
    property int selectedIndex: 0
    property real cardWidth: 280
    property real cardHeight: 380
    property real skew: -12

    function show() {
        wallpaperLoader.running = true;
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

    // --- Load wallpapers ---
    Process {
        id: wallpaperLoader
        command: ["bash", "-c", "find -L \"$HOME/.config/walls\" -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                if (out.length > 0) {
                    root.wallpapers = out.split("\n");
                    root.selectedIndex = 0;
                }
            }
        }
    }

    // --- Apply wallpaper ---
    Process {
        id: wallpaperApply
        command: []
    }

    function applyWallpaper(filePath: string): void {
        wallpaperApply.command = ["bash", "-c",
            "awww img '" + filePath + "' " +
            "--transition-type grow " +
            "--transition-duration 2 " +
            "--transition-fps 60 && " +
            "ln -sf '" + filePath + "' \"$HOME/.current_wallpaper\""
        ];
        wallpaperApply.running = true;
        root.hide();
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
                if (root.selectedIndex < root.wallpapers.length - 1) root.selectedIndex++;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (root.selectedIndex >= 0 && root.selectedIndex < root.wallpapers.length) {
                    root.applyWallpaper(root.wallpapers[root.selectedIndex]);
                }
                event.accepted = true;
            }
        }
    }

    // --- Click outside to close ---
    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
    }

    // --- Filename label ---
    Text {
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -(root.cardHeight / 2) - 40
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.wallpapers.length > 0 ? root.wallpapers[root.selectedIndex].split("/").pop() : ""
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 14
        font.weight: 500
        color: Colors.fg0

        Behavior on text {
            enabled: false
        }
    }

    // --- Counter ---
    Text {
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -(root.cardHeight / 2) - 64
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.wallpapers.length > 0 ? (root.selectedIndex + 1) + " / " + root.wallpapers.length : ""
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 11
        color: Colors.fg2
    }

    // --- Carousel ---
    Item {
        id: carousel
        anchors.centerIn: parent
        width: parent.width
        height: root.cardHeight

        MouseArea {
            anchors.fill: parent
            onClicked: {} // absorb clicks on carousel area
        }

        Repeater {
            model: root.wallpapers

            Item {
                id: card
                required property string modelData
                required property int index

                property int offset: index - root.selectedIndex
                property bool isCurrent: offset === 0
                property real spacing: 200

                visible: Math.abs(offset) <= 4

                x: carousel.width / 2 - root.cardWidth / 2 + offset * spacing
                y: (carousel.height - root.cardHeight) / 2
                width: root.cardWidth
                height: root.cardHeight
                z: 100 - Math.abs(offset)

                opacity: isCurrent ? 1.0 : Math.max(0.15, 1.0 - Math.abs(offset) * 0.25)
                scale: isCurrent ? 1.0 : Math.max(0.75, 1.0 - Math.abs(offset) * 0.08)

                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                transform: Matrix4x4 {
                    matrix: {
                        let m = Qt.matrix4x4();
                        let rad = root.skew * Math.PI / 180;
                        // Skew Y to create parallelogram effect
                        m.m12 = Math.tan(rad);
                        return m;
                    }
                }

                // Card shape
                Rectangle {
                    anchors.fill: parent
                    color: Colors.bg0
                    border.color: card.isCurrent ? Colors.accent : "transparent"
                    border.width: 2

                    // Wallpaper image
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: card.visible ? "file://" + card.modelData : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 400
                        sourceSize.height: 540
                    }

                    // Darken non-selected
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        color: Qt.rgba(0, 0, 0, card.isCurrent ? 0 : 0.4)

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (card.isCurrent) {
                            root.applyWallpaper(card.modelData);
                        } else {
                            root.selectedIndex = card.index;
                        }
                    }
                }
            }
        }
    }
}
