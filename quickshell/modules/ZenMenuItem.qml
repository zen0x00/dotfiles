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
        color: root.selected ? Colors.primary : mouseArea.containsMouse ? Qt.rgba(Colors.contentSurface.r, Colors.contentSurface.g, Colors.contentSurface.b, 0.08) : "transparent"

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
                color: root.selected ? Colors.surface : Colors.contentSurface
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root.label
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
                font.weight: 500
                color: root.selected ? Colors.surface : Colors.contentSurface
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "›"
                font.pixelSize: 14
                color: root.selected ? Colors.surface : Colors.contentSurfaceVariant
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
