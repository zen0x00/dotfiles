import QtQuick

Item {
    id: root

    property string icon: ""
    property string label: ""
    property string shortcut: ""

    signal clicked()

    implicitWidth: 140
    implicitHeight: 160

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"
        border.color: Colors.outlineVariant
        border.width: 2
        radius: 12

        states: State {
            name: "hovered"
            when: mouseArea.containsMouse
            PropertyChanges { target: bg; color: Colors.primary; border.color: Colors.primary }
            PropertyChanges { target: iconText; font.pixelSize: 48; color: Colors.surface }
            PropertyChanges { target: labelText; color: Colors.surface }
            PropertyChanges { target: shortcutText; color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.6) }
        }

        transitions: Transition {
            from: ""; to: "hovered"; reversible: true
            ParallelAnimation {
                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { properties: "font.pixelSize"; duration: 200; easing.type: Easing.OutBack }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                id: iconText
                text: root.icon
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 36
                color: Colors.onSurface
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on font.pixelSize {
                    NumberAnimation { duration: 200; easing.type: Easing.OutBack }
                }
            }

            Text {
                id: labelText
                text: root.label
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
                color: Colors.onSurfaceVariant
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: shortcutText
                text: root.shortcut
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 11
                color: Colors.onSurfaceVariant
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
