# Dynamic Island Bar — Design Spec

## Overview

A compact floating pill bar centered at the top of the screen, inspired by Apple's Dynamic Island. It dynamically shrinks/expands based on whether media is playing. A separate tray panel floats at the top-right corner. The existing classic bar (Bar.qml) is preserved — an IPC mechanism allows switching between the two.

## Layout

### Island Bar (centered, floating pill)

Three sections separated by 1px `bg2` vertical dividers, left to right:

1. **Media** (only visible when media is playing)
   - Play/pause icon in a small rounded square (album art placeholder)
   - Song title (single line, ellipsis overflow, max ~140px)
   - Artist name (smaller, muted color)
   - Click anywhere on section → play/pause toggle via `playerctl play-pause`
   - Uses `playerctl metadata --follow` via a long-running Process for event-driven updates (no polling)
   - When no media is playing, this section is hidden and the pill animates narrower

2. **Workspaces**
   - Reuses existing `BarWorkspaces` component
   - Click to switch workspace via `Hyprland.dispatch`

3. **Clock + Status**
   - Reuses existing `BarClock` component
   - Dot separator
   - Reuses existing `BarNetwork` component (click opens wifi launcher, same as current bar)
   - Reuses existing `BarBluetooth` component
   - Reuses existing `BarVolume` component (left-click → control center, middle-click → mute, scroll → volume)

### Island Tray (top-right corner, separate panel)

- Separate `PanelWindow` with `anchors.top: true; anchors.right: true`
- Own layershell namespace (`zen0x-island-tray`)
- Small rounded pill containing system tray icons
- Reuses existing `BarTray` component logic
- Explicit width/height based on content

## Visual Design

- **Shape**: Rounded pill (border-radius ~22px)
- **Background**: `bg0` at 0.95 opacity
- **Border**: 1px `bg2`
- **Blur**: Hyprland layerrule blur on namespaces `zen0x-island` and `zen0x-island-tray`
- **Position**: Centered horizontally, ~8px from top edge
- **Exclusion mode**: `ExclusionMode.Ignore` — island floats over content, does not push windows down
- **Section dividers**: 1px `bg2` vertical lines
- **No hover expansion** — control center (Super+N) for details
- **Monitor**: `screen: Quickshell.screens[0]` (primary monitor only, same as classic bar)

## Animation

The `PanelWindow` is anchored full-width at the top (transparent). The inner pill `Rectangle` is centered within it and its `implicitWidth` is driven by content. A `Behavior on implicitWidth` with ~300ms `Easing.OutCubic` animates the pill when the media section appears/disappears. This avoids layer shell resize flicker.

Note: BarClock will no longer be absolutely centered on screen — it shifts based on whether media is visible. This is intentional and matches the Dynamic Island aesthetic.

## New Files

| File | Purpose |
|------|---------|
| `quickshell/modules/IslandBar.qml` | Main island PanelWindow — layout, pill container, media visibility |
| `quickshell/modules/IslandMedia.qml` | Media section — `playerctl --follow`, play/pause, animated visibility |
| `quickshell/modules/IslandTray.qml` | Separate tray PanelWindow at top-right corner |

## Modified Files

| File | Change |
|------|--------|
| `quickshell/shell.qml` | Add `IslandBar {}`, `IslandTray {}`, shared `activeBar` property, IPC handler for switching |
| `quickshell/modules/qmldir` | Register IslandBar, IslandMedia, IslandTray |
| `hypr/apps/quickshell.conf` | Add blur layerrules for `zen0x-island` and `zen0x-island-tray` |

## Unchanged Files (reused directly)

- `BarWorkspaces.qml` — workspace list with click-to-switch
- `BarClock.qml` — time display
- `BarNetwork.qml` — network icon with wifi launcher on click
- `BarBluetooth.qml` — bluetooth icon
- `BarVolume.qml` — volume icon with control center / mute / scroll
- `BarTray.qml` — system tray icons
- `Bar.qml` — classic bar, hidden when island is active (binds `visible` to shared property)

## Bar Switching

A shared property in `shell.qml` controls which bar is active:

```qml
property string activeBar: "island"

IpcHandler {
    target: "bar"
    function switchToIsland(): void { activeBar = "island"; }
    function switchToClassic(): void { activeBar = "classic"; }
}
```

Both bars bind their `visible` to this property:
- `Bar { visible: activeBar === "classic" }`
- `IslandBar { visible: activeBar === "island" }`
- `IslandTray { visible: activeBar === "island" }`

When `Bar.qml` has `visible: false`, its `PanelWindow` is removed from the layer shell, releasing its exclusive zone. Default on startup: island bar.

## Interactions

| Element | Left Click | Middle Click | Scroll |
|---------|-----------|-------------|--------|
| Media section | Play/pause | — | — |
| Workspace | Switch to workspace | — | — |
| Volume icon | Open control center | Mute toggle | Volume up/down |
| Network icon | Open wifi launcher | — | — |
| Tray icons | Activate/show menu | Secondary activate | Scroll |

## Data Sources

- **Media**: `playerctl metadata --follow --format '{{title}}\n{{artist}}\n{{status}}'` via long-running Process with `StdioCollector` reading streaming stdout. Event-driven, no polling.
- **Volume/Network/Bluetooth**: Existing polling from BarVolume/BarNetwork/BarBluetooth
- **Workspaces**: `Hyprland.workspaces` from QuickShell Hyprland integration
- **Tray**: `SystemTray.items` from QuickShell SystemTray service
