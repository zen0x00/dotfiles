import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: 8

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property var modelData

            width: modelData.focused ? 22 : 10
            height: 10
            radius: 5
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
