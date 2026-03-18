import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Row {
    id: root
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property var modelData

            property bool focused: modelData.focused
            property bool hovered: mouseArea.containsMouse

            width: focused ? 32 : 16
            height: 22

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 4
                height: 8
                radius: 4
                color: focused ? Colors.accent : (hovered ? Qt.rgba(Colors.fg0.r, Colors.fg0.g, Colors.fg0.b, 0.45) : Qt.rgba(Colors.fg0.r, Colors.fg0.g, Colors.fg0.b, 0.2))

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
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
