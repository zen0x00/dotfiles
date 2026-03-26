import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Row {
    id: root
    spacing: 2

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property var modelData

            property bool focused: modelData.focused
            property bool hovered: mouseArea.containsMouse

            width: focused ? label.implicitWidth + 16 : 28
            height: 28

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            // Active pill background (gradient: tertiary → primary)
            Rectangle {
                anchors.fill: parent
                radius: 20
                visible: focused
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Colors.tertiary }
                    GradientStop { position: 1.0; color: Colors.primary }
                }
                opacity: focused ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: modelData.name
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 13
                font.weight: focused ? 900 : 600
                color: focused ? Colors.surface : (hovered ? Colors.contentSurface : Colors.contentSurfaceVariant)

                Behavior on color { ColorAnimation { duration: 200 } }
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
