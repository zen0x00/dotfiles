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
        border.color: Colors.bg2
        border.width: 2
        radius: 0

        states: State {
            name: "hovered"
            when: mouseArea.containsMouse
            PropertyChanges { target: bg; color: Colors.accent; border.color: Colors.accent }
            PropertyChanges { target: iconText; font.pixelSize: 48; color: Colors.bg0 }
            PropertyChanges { target: labelText; color: Colors.bg0 }
            PropertyChanges { target: shortcutText; color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.6) }
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
                color: Colors.fg0
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
                color: Colors.fg1
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: shortcutText
                text: root.shortcut
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 11
                color: Colors.fg2
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
