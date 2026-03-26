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

            width: 28
            height: 28

            // Workspace number
            Text {
                id: label
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: focused ? -2 : 0
                text: modelData.name
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: focused ? 13 : 11
                font.weight: focused ? 900 : 600
                color: focused ? Colors.primary : (hovered ? Colors.contentSurface : Colors.contentSurfaceVariant)

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                }
                Behavior on font.pixelSize {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }

            // Underline indicator
            Rectangle {
                id: underline
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
                height: 2
                radius: 1
                width: focused ? 14 : (hovered ? 6 : 0)
                color: focused ? Colors.primary : Colors.contentSurfaceVariant
                opacity: focused ? 1.0 : (hovered ? 0.6 : 0)

                Behavior on width {
                    NumberAnimation { duration: 350; easing.type: Easing.OutBack }
                }
                Behavior on opacity {
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
