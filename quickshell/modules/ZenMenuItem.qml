import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string icon: ""
    property string label: ""
    property bool selected: false

    signal clicked()

    implicitHeight: 38

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.selected ? Colors.accent : mouseArea.containsMouse ? Qt.rgba(Colors.fg0.r, Colors.fg0.g, Colors.fg0.b, 0.08) : "transparent"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Text {
                text: root.icon
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 16
                color: root.selected ? Colors.bg0 : Colors.fg0
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root.label
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
                font.weight: 500
                color: root.selected ? Colors.bg0 : Colors.fg0
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "›"
                font.pixelSize: 14
                color: root.selected ? Colors.bg0 : Colors.fg2
                Layout.alignment: Qt.AlignVCenter
                visible: root.selected
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
