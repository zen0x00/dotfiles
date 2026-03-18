import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 44
    color: "transparent"
    exclusionMode: ExclusionMode.Auto

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-island"

    // --- Pill container ---
    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8
        height: 36
        width: pillContent.implicitWidth + 24
        radius: 22
        color: Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.95)
        border.color: Colors.bg2
        border.width: 1

        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        RowLayout {
            id: pillContent
            anchors.centerIn: parent
            height: parent.height
            spacing: 0

            // --- Media section ---
            IslandMedia {
                id: mediaSection
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 4
            }

            // --- Divider after media ---
            Text {
                visible: mediaSection.hasMedia
                text: "·"
                font.pixelSize: 20
                font.weight: 800
                color: Colors.fg2
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }

            // --- Workspaces ---
            BarWorkspaces {
                Layout.alignment: Qt.AlignVCenter
            }

            // --- Divider ---
            Text {
                text: "·"
                font.pixelSize: 20
                font.weight: 800
                color: Colors.fg2
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }

            // --- Clock ---
            BarClock {
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
