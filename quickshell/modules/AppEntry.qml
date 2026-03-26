import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var app
    property bool selected: false

    signal clicked()

    implicitHeight: 44

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        radius: 8
        color: root.selected ? Colors.outlineVariant : mouseArea.containsMouse ? Colors.surfaceContainerHigh : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            Image {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                source: root.app && root.app.icon ? "image://icon/" + root.app.icon : ""
                sourceSize: Qt.size(24, 24)
                visible: status === Image.Ready
            }

            Text {
                Layout.fillWidth: true
                text: root.app ? root.app.name : ""
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 14
                color: root.selected ? Colors.primary : Colors.contentSurface
                elide: Text.ElideRight
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
