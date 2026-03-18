import QtQuick
import Quickshell.Services.SystemTray

Row {
    id: root
    spacing: 8

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayDelegate
            required property var modelData
            width: 14
            height: 14

            Image {
                anchors.fill: parent
                source: trayDelegate.modelData.icon
                sourceSize.width: 14
                sourceSize.height: 14
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor

                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        if (trayDelegate.modelData.onlyMenu && trayDelegate.modelData.hasMenu) {
                            trayDelegate.modelData.display(root, mouse.x, mouse.y);
                        } else {
                            trayDelegate.modelData.activate();
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayDelegate.modelData.hasMenu) {
                            trayDelegate.modelData.display(root, mouse.x, mouse.y);
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayDelegate.modelData.secondaryActivate();
                    }
                }

                onWheel: (wheel) => {
                    trayDelegate.modelData.scroll(wheel.angleDelta.y, false);
                }
            }

        }
    }
}
