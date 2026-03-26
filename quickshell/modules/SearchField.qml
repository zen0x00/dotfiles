import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias query: input.text

    signal accepted()
    signal moveUp()
    signal moveDown()

    implicitHeight: 44

    function clear() {
        input.text = "";
    }

    function forceActiveFocus() {
        input.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.surfaceContainerLow
        radius: 8

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            verticalAlignment: TextInput.AlignVCenter

            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 16
            color: Colors.onSurface
            selectionColor: Colors.primary
            selectedTextColor: Colors.surface

            Keys.onUpPressed: root.moveUp()
            Keys.onDownPressed: root.moveDown()
            Keys.onReturnPressed: root.accepted()

            // Placeholder
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: "  Search applications..."
                font: input.font
                color: Colors.onSurfaceVariant
                visible: !input.text
            }
        }
    }
}
