import QtQuick
import Quickshell

Item {
    id: root

    signal launched()

    property int selectedIndex: 0
    property var filteredEntries: []

    implicitHeight: listView.contentHeight

    function filter(query: string): void {
        let results = [];
        let q = query.toLowerCase();

        for (let i = 0; i < DesktopEntries.applications.values.length; i++) {
            let app = DesktopEntries.applications.values[i];
            if (app.noDisplay) continue;

            let name = app.name.toLowerCase();
            let generic = (app.genericName || "").toLowerCase();
            if (name.includes(q) || generic.includes(q)) {
                results.push(app);
            }
        }

        results.sort((a, b) => a.name.localeCompare(b.name));
        filteredEntries = results;
        selectedIndex = 0;
    }

    function launchSelected(): void {
        if (filteredEntries.length > 0 && selectedIndex < filteredEntries.length) {
            filteredEntries[selectedIndex].execute();
            root.launched();
        }
    }

    function selectNext(): void {
        if (selectedIndex < filteredEntries.length - 1) {
            selectedIndex++;
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }
    }

    function selectPrevious(): void {
        if (selectedIndex > 0) {
            selectedIndex--;
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }
    }

    Component.onCompleted: filter("")

    ListView {
        id: listView
        anchors.fill: parent
        model: root.filteredEntries
        clip: true

        delegate: AppEntry {
            required property var modelData
            required property int index

            width: listView.width
            app: modelData
            selected: index === root.selectedIndex

            onClicked: {
                root.selectedIndex = index;
                root.launchSelected();
            }
        }
    }
}
