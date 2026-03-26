pragma Singleton
import QtQuick

QtObject {
    // Surface scale
    readonly property color surface:                   "{{colors.surface.default.hex}}"
    readonly property color surfaceDim:                "{{colors.surface_dim.default.hex}}"
    readonly property color surfaceBright:             "{{colors.surface_bright.default.hex}}"
    readonly property color surfaceContainerLowest:    "{{colors.surface_container_lowest.default.hex}}"
    readonly property color surfaceContainerLow:       "{{colors.surface_container_low.default.hex}}"
    readonly property color surfaceContainer:          "{{colors.surface_container.default.hex}}"
    readonly property color surfaceContainerHigh:      "{{colors.surface_container_high.default.hex}}"
    readonly property color surfaceContainerHighest:   "{{colors.surface_container_highest.default.hex}}"

    // Content on surfaces (Material "on" tokens — renamed to avoid QML signal handler conflicts)
    readonly property color contentSurface:            "{{colors.on_surface.default.hex}}"
    readonly property color contentSurfaceVariant:     "{{colors.on_surface_variant.default.hex}}"
    readonly property color inverseSurface:            "{{colors.inverse_surface.default.hex}}"
    readonly property color inverseContentSurface:     "{{colors.inverse_on_surface.default.hex}}"

    // Primary
    readonly property color primary:                   "{{colors.primary.default.hex}}"
    readonly property color contentPrimary:            "{{colors.on_primary.default.hex}}"
    readonly property color primaryContainer:          "{{colors.primary_container.default.hex}}"
    readonly property color contentPrimaryContainer:   "{{colors.on_primary_container.default.hex}}"
    readonly property color inversePrimary:            "{{colors.inverse_primary.default.hex}}"

    // Secondary
    readonly property color secondary:                 "{{colors.secondary.default.hex}}"
    readonly property color contentSecondary:          "{{colors.on_secondary.default.hex}}"
    readonly property color secondaryContainer:        "{{colors.secondary_container.default.hex}}"
    readonly property color contentSecondaryContainer: "{{colors.on_secondary_container.default.hex}}"

    // Tertiary
    readonly property color tertiary:                  "{{colors.tertiary.default.hex}}"
    readonly property color contentTertiary:           "{{colors.on_tertiary.default.hex}}"
    readonly property color tertiaryContainer:         "{{colors.tertiary_container.default.hex}}"
    readonly property color contentTertiaryContainer:  "{{colors.on_tertiary_container.default.hex}}"

    // Error
    readonly property color error:                     "{{colors.error.default.hex}}"
    readonly property color contentError:              "{{colors.on_error.default.hex}}"
    readonly property color errorContainer:            "{{colors.error_container.default.hex}}"
    readonly property color contentErrorContainer:     "{{colors.on_error_container.default.hex}}"

    // Outline
    readonly property color outline:                   "{{colors.outline.default.hex}}"
    readonly property color outlineVariant:            "{{colors.outline_variant.default.hex}}"

    // Misc
    readonly property color shadow:                    "{{colors.shadow.default.hex}}"
    readonly property color scrim:                     "{{colors.scrim.default.hex}}"
}
