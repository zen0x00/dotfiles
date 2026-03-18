pragma Singleton

import QtQuick

QtObject {
    // Background scale
    readonly property color bg0: "{{ bg0 }}"
    readonly property color bg1: "{{ bg1 }}"
    readonly property color bg2: "{{ bg2 }}"
    readonly property color bg3: "{{ bg3 }}"
    readonly property color bg4: "{{ bg4 }}"

    // Foreground scale
    readonly property color fg0: "{{ fg0 }}"
    readonly property color fg1: "{{ fg1 }}"
    readonly property color fg2: "{{ fg2 }}"

    // Semantic
    readonly property color accent: "{{ accent }}"
    readonly property color red: "{{ red }}"
    readonly property color green: "{{ green }}"
    readonly property color yellow: "{{ yellow }}"
    readonly property color blue: "{{ blue }}"
    readonly property color cyan: "{{ cyan }}"
    readonly property color purple: "{{ purple }}"
}
