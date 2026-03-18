import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property var modelData

            width: modelData.focused ? 16 : 8
            height: 8
            radius: 4
            color: modelData.focused ? Colors.accent : Colors.fg1

            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}
