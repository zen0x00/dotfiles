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

            width: focused ? 36 : 28
            height: 28

            Behavior on width {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            // Gradient pill background (active only)
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                opacity: focused ? 1.0 : 0.0
                visible: opacity > 0

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Colors.primary }
                    GradientStop { position: 1.0; color: Colors.secondary }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }

            // Hover background (inactive)
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(Colors.contentSurface.r, Colors.contentSurface.g, Colors.contentSurface.b, 0.08)
                opacity: (!focused && hovered) ? 1.0 : 0.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            Text {
                anchors.centerIn: parent
                text: modelData.name
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: focused ? 13 : 11
                font.weight: focused ? 900 : 600
                color: focused ? Colors.surface : (hovered ? Colors.contentSurface : Colors.contentSurfaceVariant)

                Behavior on font.pixelSize {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
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
