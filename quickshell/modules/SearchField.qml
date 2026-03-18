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
        color: Colors.bg1
        radius: 8

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            verticalAlignment: TextInput.AlignVCenter

            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 16
            color: Colors.fg0
            selectionColor: Colors.accent
            selectedTextColor: Colors.bg0

            Keys.onUpPressed: root.moveUp()
            Keys.onDownPressed: root.moveDown()
            Keys.onReturnPressed: root.accepted()

            // Placeholder
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: "  Search applications..."
                font: input.font
                color: Colors.fg2
                visible: !input.text
            }
        }
    }
}
