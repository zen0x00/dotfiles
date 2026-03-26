pragma Singleton
import QtQuick

QtObject {
    // Surface scale
    readonly property color surface:                   "#111418"
    readonly property color surfaceDim:                "#111418"
    readonly property color surfaceBright:             "#36393e"
    readonly property color surfaceContainerLowest:    "#0b0e13"
    readonly property color surfaceContainerLow:       "#191c20"
    readonly property color surfaceContainer:          "#1d2024"
    readonly property color surfaceContainerHigh:      "#272a2f"
    readonly property color surfaceContainerHighest:   "#32353a"

    // Content on surfaces (Material "on" tokens — renamed to avoid QML signal handler conflicts)
    readonly property color contentSurface:            "#e1e2e8"
    readonly property color contentSurfaceVariant:     "#c3c7cf"
    readonly property color inverseSurface:            "#e1e2e8"
    readonly property color inverseContentSurface:     "#2e3135"

    // Primary
    readonly property color primary:                   "#a0cafd"
    readonly property color contentPrimary:            "#003258"
    readonly property color primaryContainer:          "#194975"
    readonly property color contentPrimaryContainer:   "#d1e4ff"
    readonly property color inversePrimary:            "#35618e"

    // Secondary
    readonly property color secondary:                 "#bbc7db"
    readonly property color contentSecondary:          "#253140"
    readonly property color secondaryContainer:        "#3b4858"
    readonly property color contentSecondaryContainer: "#d6e3f7"

    // Tertiary
    readonly property color tertiary:                  "#d6bee4"
    readonly property color contentTertiary:           "#3b2948"
    readonly property color tertiaryContainer:         "#523f5f"
    readonly property color contentTertiaryContainer:  "#f2daff"

    // Error
    readonly property color error:                     "#ffb4ab"
    readonly property color contentError:              "#690005"
    readonly property color errorContainer:            "#93000a"
    readonly property color contentErrorContainer:     "#ffdad6"

    // Outline
    readonly property color outline:                   "#8d9199"
    readonly property color outlineVariant:            "#42474e"

    // Misc
    readonly property color shadow:                    "#000000"
    readonly property color scrim:                     "#000000"
}
