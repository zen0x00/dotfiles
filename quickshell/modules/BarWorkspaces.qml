import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Row {
    id: root
    spacing: 0

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property var modelData

            property bool focused: modelData.focused
            property bool hovered: mouseArea.containsMouse

            width: focused ? 28 : 22
            height: 22

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 4
                height: 18
                radius: 9
                color: focused ? Colors.accent : "transparent"

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 12
                    font.weight: 800
                    color: focused ? Colors.bg0 : (hovered ? Colors.fg0 : Colors.fg1)

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: Hyprland.dispatch("workspace " + modelData.name)
            }
        }
    }
}
