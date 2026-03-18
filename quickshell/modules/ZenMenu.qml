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
    WlrLayershell.namespace: "zen0x-theme-switcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property var themeList: []
    property string currentTheme: ""
    property int selectedIndex: 0

    function show() {
        selectedIndex = 0;
        themeLoader.running = true;
        currentThemeLoader.running = true;
        root.visible = true;
        keyHandler.forceActiveFocus();
    }

    function hide() {
        root.visible = false;
    }

    IpcHandler {
        target: "themeswitcher"

        function toggle(): void {
            if (root.visible) root.hide();
            else root.show();
        }
    }

    Shortcut {
        sequences: ["Escape"]
        onActivated: root.hide()
    }

    Process {
        id: themeLoader
        command: ["bash", "-c", "ls -1 \"$HOME/.config/themes/colorschemes\" | grep -v current"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim();
                if (out.length > 0) {
                    root.themeList = out.split("\n");
                }
            }
        }
    }

    Process {
        id: currentThemeLoader
        command: ["bash", "-c", "basename \"$(readlink -f \"$HOME/.config/themes/colorschemes/current\")\""]
        stdout: StdioCollector {
            onStreamFinished: {
                root.currentTheme = this.text.trim();
            }
        }
    }

    Process {
        id: themeApply
        property string themeName: ""
        command: ["bash", "-c", "THEME='" + themeName + "'; THEMES=\"$HOME/.config/themes/colorschemes\"; ln -sfn \"$THEMES/$THEME\" \"$THEMES/current\" && zen0x-theme-generate \"$THEME\" && zen0x-apply-generated-theme && zen0x-theme-gtk && zen0x-theme-set-vscode && zen0x-theme-wallpaper \"$THEME\" && zen0x-theme-reload"]
    }

    function applyTheme(index: int): void {
        if (index >= 0 && index < themeList.length) {
            themeApply.themeName = themeList[index];
            themeApply.running = true;
            root.hide();
        }
    }

    Item {
        id: keyHandler
        focus: true
        anchors.fill: parent

        Keys.onUpPressed: {
            if (root.selectedIndex > 0) root.selectedIndex--;
        }
        Keys.onDownPressed: {
            if (root.selectedIndex < root.themeList.length - 1) root.selectedIndex++;
        }
        Keys.onReturnPressed: root.applyTheme(root.selectedIndex)
        Keys.onEscapePressed: root.hide()
    }

    Rectangle {
        id: wrapper
        anchors.centerIn: parent
        width: 360
        implicitHeight: content.implicitHeight + 24
        color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.95)
        radius: 16
        border.color: Colors.bg2
        border.width: 1

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4

            Text {
                text: "Theme Switcher"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 16
                font.weight: 700
                color: Colors.fg2
                Layout.bottomMargin: 4
                Layout.alignment: Qt.AlignHCenter
            }

            Repeater {
                model: root.themeList

                delegate: ZenMenuItem {
                    required property var modelData
                    required property int index
                    icon: modelData === root.currentTheme ? "󰄬" : "󰏘"
                    label: modelData
                    selected: root.selectedIndex === index
                    Layout.fillWidth: true
                    onClicked: root.applyTheme(index)
                }
            }
        }
    }
}
