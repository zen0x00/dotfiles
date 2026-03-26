import QtQuick

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string timeText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let now = new Date();
            let hours = now.getHours();
            let ampm = hours >= 12 ? "PM" : "AM";
            hours = hours % 12;
            if (hours === 0) hours = 12;
            let minutes = now.getMinutes().toString().padStart(2, '0');
            root.timeText = hours + ":" + minutes + " " + ampm;
        }
    }

    Text {
        id: label
        text: root.timeText
        anchors.verticalCenter: parent.verticalCenter
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 13
        font.weight: 800
        color: Colors.onSurface
    }
}
