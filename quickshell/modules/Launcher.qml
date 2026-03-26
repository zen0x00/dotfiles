import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    width: 600
    height: wrapper.implicitHeight
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "zen0x-launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.visible = !root.visible;
            if (root.visible) {
                searchField.clear();
                appList.filter("");
                searchField.forceActiveFocus();
            }
        }
    }

    Shortcut {
        sequences: ["Escape"]
        onActivated: root.visible = false
    }

    Rectangle {
        id: wrapper
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: innerColumn.implicitHeight + 24
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.95)
        radius: 12
        border.color: Colors.outlineVariant
        border.width: 2

        ColumnLayout {
            id: innerColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            SearchField {
                id: searchField
                Layout.fillWidth: true

                onAccepted: appList.launchSelected()
                onQueryChanged: appList.filter(query)
                onMoveUp: appList.selectPrevious()
                onMoveDown: appList.selectNext()
            }

            AppList {
                id: appList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(implicitHeight, 400)

                onLaunched: root.visible = false
            }
        }
    }
}
