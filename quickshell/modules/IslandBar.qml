import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Eye-candy mode: centered floating pill
PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 52
    color: "transparent"
    exclusionMode: ExclusionMode.Auto

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "zen0x-island"

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8
        height: 38
        width: pillContent.implicitWidth + 32
        radius: 24
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.85)
        border.color: Colors.outlineVariant
        border.width: 1

        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        RowLayout {
            id: pillContent
            anchors.centerIn: parent
            height: parent.height
            spacing: 0

            IslandMedia {
                id: mediaSection
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 4
            }

            Text {
                visible: mediaSection.hasMedia
                text: "·"
                font.pixelSize: 18
                font.weight: 800
                color: Colors.outlineVariant
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }

            BarWorkspaces {
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "·"
                font.pixelSize: 18
                font.weight: 800
                color: Colors.outlineVariant
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }

            BarClock {
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "·"
                font.pixelSize: 18
                font.weight: 800
                color: Colors.outlineVariant
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }

            BarStats {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 4
            }
        }
    }
}
