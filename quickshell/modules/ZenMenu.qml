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

    // --- Background wallpaper with blur ---
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

    // Dim overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
    }

    // Each entry: { name: "Abyssal", wallpaper: "/path/to/wallpaper.jpg", dir: "/path/to/theme" }
    property var themes: []
    property int selectedIndex: 0
    property real cardWidth: 280
    property real cardHeight: 380
    property real skew: -12

    function show() {
        wallpaperResolver.running = true;
        themeLoader.running = true;
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

    // --- Load themes ---
    Process {
        id: themeLoader
        command: ["bash", "-c", "for d in \"$HOME/.config/themes/colorschemes\"/*/; do [ -f \"$d/wallpapers/wallpaper.jpg\" ] && echo \"$(basename \"$d\")|$d/wallpapers/wallpaper.jpg|$d\"; done | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                if (out.length > 0) {
                    let lines = out.split("\n");
                    let result = [];
                    for (let i = 0; i < lines.length; i++) {
                        let parts = lines[i].split("|");
                        if (parts.length >= 3) {
                            result.push({ name: parts[0], wallpaper: parts[1], dir: parts[2] });
                        }
                    }
                    root.themes = result;
                    root.selectedIndex = 0;
                }
            }
        }
    }

    // --- Apply theme ---
    Process {
        id: wallpaperApply
        command: []
    }

    Process {
        id: themeApply
        command: []
    }

    function applyTheme(theme: var): void {
        // Set wallpaper with transition
        wallpaperApply.command = ["bash", "-c",
            "awww img '" + theme.wallpaper + "' " +
            "--transition-type grow " +
            "--transition-duration 2 " +
            "--transition-fps 60 && " +
            "ln -sf '" + theme.wallpaper + "' \"$HOME/.current_wallpaper\""
        ];
        wallpaperApply.running = true;

        // Apply full theme: symlink current, generate, apply, reload
        themeApply.command = ["bash", "-c",
            "ln -sfn '" + theme.dir + "' \"$HOME/.config/themes/current\" && " +
            "zen0x-theme-generate '" + theme.name + "' && " +
            "zen0x-apply-generated-theme && " +
            "zen0x-theme-gtk && " +
            "zen0x-theme-set-vscode && " +
            "zen0x-theme-nvim && " +
            "setsid zen0x-theme-reload >/dev/null 2>&1 &"
        ];
        themeApply.running = true;

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
                if (root.selectedIndex < root.themes.length - 1) root.selectedIndex++;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (root.selectedIndex >= 0 && root.selectedIndex < root.themes.length) {
                    root.applyTheme(root.themes[root.selectedIndex]);
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

    // --- Theme name label ---
    Text {
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -(root.cardHeight / 2) - 40
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.themes.length > 0 ? root.themes[root.selectedIndex].name : ""
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
        text: root.themes.length > 0 ? (root.selectedIndex + 1) + " / " + root.themes.length : ""
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
            model: root.themes.length

            Item {
                id: card

                property int offset: index - root.selectedIndex
                property bool isCurrent: offset === 0
                property real spacing: 200
                property var theme: root.themes[index]

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

                    // Theme wallpaper preview
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: card.visible && card.theme ? "file://" + card.theme.wallpaper : ""
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
                            root.applyTheme(card.theme);
                        } else {
                            root.selectedIndex = card.index;
                        }
                    }
                }
            }
        }
    }
}
