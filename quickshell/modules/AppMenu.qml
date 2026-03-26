import QtQuick
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
    WlrLayershell.namespace: "zen0x-appmenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    IpcHandler {
        target: "appmenu"
        function toggle(): void {
            if (root.visible) root.close();
            else root.open();
        }
    }

    Shortcut {
        sequences: ["Escape"]
        onActivated: root.close()
    }

    // ── State ──
    property string screen: "main"
    property var listItems: []
    property int selectedIndex: 0
    property var filteredItems: []

    onListItemsChanged: filteredItems = listItems.slice()

    function open(): void {
        screen = "main";
        selectedIndex = 0;
        listItems = ["Theme", "Wallpaper", "Font", "Mode"];
        filteredItems = ["Theme", "Wallpaper", "Font", "Mode"];
        visible = true;
        listView.forceActiveFocus();
    }

    function close(): void {
        visible = false;
    }

    function confirm(): void {
        let item = filteredItems[selectedIndex];
        if (!item) return;

        if (screen === "main") {
            if (item === "Wallpaper") {
                close();
                wallpickerIpc.running = true;
            } else if (item === "Theme") {
                loader.targetScreen = "theme";
                loader.command = ["bash", "-c", "ls -1 \"$HOME/hyprdots/themes/colorschemes\""];
                loader.running = true;
            } else if (item === "Font") {
                loader.targetScreen = "font";
                loader.command = ["bash", "-c", "fc-list --format='%{family[0]}\\n' | sort -u"];
                loader.running = true;
            } else if (item === "Mode") {
                loader.targetScreen = "mode";
                loader.command = ["bash", "-c", "ls -1 \"$HOME/.config/modes\""];
                loader.running = true;
            }
        } else if (screen === "theme") {
            applyThemeProc.command = ["bash", "-c",
                "THEME='" + item + "'; " +
                "THEMES=\"$HOME/hyprdots/themes/colorschemes\"; " +
                "CURRENT=\"$HOME/.config/themes/current\"; " +
                "ln -sfn \"$THEMES/$THEME\" \"$CURRENT\"; " +
                "zen0x-theme-generate \"$THEME\"; " +
                "zen0x-apply-generated-theme; " +
                "zen0x-theme-gtk; " +
                "zen0x-theme-set-vscode; " +
                "zen0x-theme-reload"
            ];
            applyThemeProc.running = true;
            close();
        } else if (screen === "font") {
            applyFontProc.command = ["bash", "-c",
                "FONT='" + item + "'; " +
                "CONFIG=\"$HOME/.config\"; " +
                "sed -i \"s|^font_family.*|font_family      family=\\\"$FONT\\\"|\" \"$CONFIG/kitty/kitty.conf\"; " +
                "mkdir -p \"$CONFIG/gtk-3.0\"; " +
                "grep -q 'gtk-font-name' \"$CONFIG/gtk-3.0/settings.ini\" 2>/dev/null && " +
                "sed -i \"s|^gtk-font-name=.*|gtk-font-name=$FONT 11|\" \"$CONFIG/gtk-3.0/settings.ini\" || " +
                "printf '[Settings]\\ngtk-font-name=$FONT 11\\n' > \"$CONFIG/gtk-3.0/settings.ini\"; " +
                "pkill -SIGUSR1 kitty"
            ];
            applyFontProc.running = true;
            close();
        } else if (screen === "mode") {
            applyModeProc.command = ["zen0x-mode", item];
            applyModeProc.running = true;
            close();
        }
    }

    // ── Loader (single reusable process) ──
    Process {
        id: loader
        property string targetScreen: ""
        stdout: StdioCollector {
            onStreamFinished: {
                root.listItems = this.text.trim().split("\n").filter(s => s.length > 0);
                root.screen = loader.targetScreen;
                root.selectedIndex = 0;
                listView.forceActiveFocus();
            }
        }
        onRunningChanged: if (!running) running = false
    }

    Process { id: wallpickerIpc; command: ["qs", "ipc", "call", "wallpicker", "toggle"] }
    Process { id: applyThemeProc }
    Process { id: applyFontProc }
    Process { id: applyModeProc }

    // ── UI ──
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Invisible measurer for dynamic width
    Text {
        id: textMeasure
        visible: false
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 13
        font.weight: 700
        text: root.filteredItems.reduce((a, s) => s.length > a.length ? s : a, "")
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: textMeasure.implicitWidth + 48
        height: root.filteredItems.length * 40 + 16
        radius: 10
        color: Colors.surface
        border.color: Colors.outlineVariant
        border.width: 1

        MouseArea { anchors.fill: parent }

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 8
            clip: true
            model: root.filteredItems
            focus: root.visible

            Keys.onUpPressed:   { if (root.selectedIndex > 0) root.selectedIndex-- }
            Keys.onDownPressed: { if (root.selectedIndex < root.filteredItems.length - 1) root.selectedIndex++ }
            Keys.onReturnPressed: root.confirm()
            Keys.onEscapePressed: root.close()

            delegate: Rectangle {
                required property string modelData
                required property int index

                width: listView.width
                height: 40
                radius: 6
                color: index === root.selectedIndex
                    ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15)
                    : (hoverArea.containsMouse
                        ? Qt.rgba(Colors.contentSurface.r, Colors.contentSurface.g, Colors.contentSurface.b, 0.05)
                        : "transparent")

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: modelData
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 13
                    font.weight: index === root.selectedIndex ? 700 : 400
                    color: index === root.selectedIndex ? Colors.primary : Colors.contentSurface
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedIndex = index;
                        root.confirm();
                    }
                }
            }
        }
    }
}
