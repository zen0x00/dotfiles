import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: 2

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property var modelData

            width: modelData.focused ? 36 : 28
            height: 22
            radius: 0
            color: modelData.focused ? Colors.accent : "transparent"

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            Text {
                anchors.centerIn: parent
                text: modelData.name
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
                font.weight: 700
                color: modelData.focused ? Colors.bg0 : Qt.rgba(Colors.fg0.r, Colors.fg0.g, Colors.fg0.b, 0.5)

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: modelData.activate()

                onEntered: {
                    if (!modelData.focused) parent.color = Qt.rgba(Colors.fg0.r, Colors.fg0.g, Colors.fg0.b, 0.1);
                }
                onExited: {
                    if (!modelData.focused) parent.color = "transparent";
                }
            }
        }
    }
}
