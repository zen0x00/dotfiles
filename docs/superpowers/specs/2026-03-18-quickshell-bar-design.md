# QuickShell Bar — Design Spec

## Overview

Replace Waybar with a QuickShell-based top bar. Floating pill style, themed via zen0x. Initial modules: Hyprland workspaces, clock, volume, network, bluetooth. More modules added incrementally.

## Architecture

The bar is a `PanelWindow` anchored to the top edge, with margins on all sides to create the floating pill appearance. It lives alongside the existing Launcher in the same QuickShell process.

### Entry Point

`shell.qml` gains a `Bar {}` component next to the existing `Launcher {}`.

### File Structure

```
quickshell/modules/
├── Bar.qml              # Main bar panel (PanelWindow)
├── BarWorkspaces.qml    # Hyprland workspace dot indicators
├── BarClock.qml         # Clock widget
├── BarVolume.qml        # Volume icon + scroll control
├── BarNetwork.qml       # Network status icon
├── BarBluetooth.qml     # Bluetooth status icon
├── qmldir               # Updated with new components
└── (existing files unchanged)
```

### Module Registry (`qmldir` additions)

```
Bar 1.0 Bar.qml
BarWorkspaces 1.0 BarWorkspaces.qml
BarClock 1.0 BarClock.qml
BarVolume 1.0 BarVolume.qml
BarNetwork 1.0 BarNetwork.qml
BarBluetooth 1.0 BarBluetooth.qml
```

## Components

### Bar.qml — Main Panel

- **Type:** `PanelWindow`
- **Anchors:** `anchors.top: true`, `anchors.left: true`, `anchors.right: true`
- **Margins:** `margins.top: 8`, `margins.left: 8`, `margins.right: 8`, `margins.bottom: 0`
- **Exclusion:** `exclusionMode: ExclusionMode.Auto` (reserves space so windows don't overlap)
- **Layer:** `WlrLayershell.layer: WlrLayer.Top` (below overlay launcher, above normal windows)
- **Namespace:** `WlrLayershell.namespace: "zen0x-bar"`
- **Imports:** `Quickshell`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `QtQuick`, `QtQuick.Layouts`
- **Color:** `"transparent"`
- **Height:** Fixed ~36px

**Inner structure:**
```
Rectangle (pill background: Colors.bg0 @ 0.95 opacity, radius: 18, border: Colors.bg2)
  └── RowLayout (fill, margins: 4 horizontal / 0 vertical)
        ├── BarWorkspaces { Layout.alignment: Qt.AlignLeft }
        ├── Item { Layout.fillWidth: true }  // spacer
        ├── BarClock { Layout.alignment: Qt.AlignCenter }
        ├── Item { Layout.fillWidth: true }  // spacer
        └── Row { spacing: 12; Layout.alignment: Qt.AlignRight }
              ├── BarVolume {}
              ├── BarNetwork {}
              └── BarBluetooth {}
```

### BarWorkspaces.qml — Workspace Indicators

- **Data source:** `Hyprland.workspaces` from `Quickshell.Hyprland`
- **Display:** Only occupied workspaces shown, sorted by ID
- **Style:** Small rounded rectangles (dots/pills)
  - Active workspace: `Colors.accent`, width 16px, height 8px (pill shape)
  - Occupied inactive: `Colors.fg1`, width 8px, height 8px (dot)
- **Click:** Switch to workspace via `workspace.activate()` method on the `HyprlandWorkspace` object
- **Sorting:** `Hyprland.workspaces` is an `UntypedObjectModel` — sort by `id` in JS if order is not guaranteed
- **Animation:** Smooth width transition on active change (150ms)

### BarClock.qml — Clock

- **Method:** QML `Timer` with 1000ms interval + JS `new Date()` formatting
- **Format:** `hh:mm AP` (12-hour, matching Waybar's `%I:%M %p`)
- **Font:** JetBrainsMono Nerd Font Mono, 13px
- **Color:** `Colors.fg0`

### BarVolume.qml — Volume

- **Data:** `Process` (from `Quickshell.Io`) + `Timer` polling `wpctl get-volume @DEFAULT_AUDIO_SINK@` every 2 seconds. Wire: Timer triggers `process.exec()`, attach `StdioCollector` to `process.stdout`, parse `StdioCollector.text` on `process.exited` signal.
- **Icons** (from Waybar `pulseaudio` module):
  - Muted: `""`
  - Low (0-33%): `""`
  - Medium (34-66%): `""`
  - High (67-100%): `""`
- **Interactions:**
  - Scroll up: `swayosd-client --output-volume raise`
  - Scroll down: `swayosd-client --output-volume lower`
  - Click: `zen0x-launch-or-focus-tui wiremix`
  - Middle click: `swayosd-client --output-volume mute`
- **Font:** JetBrainsMono Nerd Font Mono, 16px for icon
- **Color:** `Colors.fg0`

### BarNetwork.qml — Network

- **Data:** `Process` polling `nmcli -t -f TYPE,STATE,CONNECTION,SIGNAL device` every 5 seconds
- **Icons** (from Waybar `network` module):
  - WiFi signal strength: `"󰤯"` `"󰤟"` `"󰤢"` `"󰤥"` `"󰤨"` (0/25/50/75/100%)
  - Ethernet: `"󰀂"`
  - Disconnected: `"󰤮"`
- **Interactions:**
  - Click: `zen0x-launch-wifi`
- **Font:** JetBrainsMono Nerd Font Mono, 16px
- **Color:** `Colors.fg0`

### BarBluetooth.qml — Bluetooth

- **Data:** `Process` polling `bluetoothctl show` every 5 seconds, and `bluetoothctl devices Connected` for connection count
- **Icons** (from Waybar `bluetooth` module):
  - Connected: `""`
  - On (no connections): `""`
  - Disabled/off: `"󰂲"`
- **Interactions:**
  - Click: `zen0x-launch-bluetooth`
- **Font:** JetBrainsMono Nerd Font Mono, 16px
- **Color:** `Colors.fg0`

## Hyprland Integration

### Layer Rules (`hypr/apps/quickshell.conf`)

Add rules for the bar namespace:

```
layerrule = blur on, match:namespace zen0x-bar
layerrule = ignore_alpha 0.3, match:namespace zen0x-bar
```

No `no_anim` for the bar — it can animate normally.

### Exec Config

No changes needed — QuickShell is already launched via `exec-once = uwsm-app -- quickshell`. The bar loads automatically as part of `shell.qml`.

### Waybar Removal

- Remove `exec-once = uwsm-app -- waybar` from `hypr/configs/execs.conf`
- In `bin/zen0x-theme-reload`: remove `killall -9 waybar` (line 3) and `waybar &` (line 5), update notification text to remove "Waybar" mention

## Theme Integration

The bar uses the existing `Colors` singleton, which is already driven by the zen0x template system (`quickshell-colors.qml.tpl`). No new templates needed.

## Scope Boundaries

**In scope (this spec):**
- Bar panel with floating pill style
- Workspaces, clock, volume, network, bluetooth modules
- Hyprland layerrules for bar
- Waybar removal from exec/reload scripts

**Out of scope (future iterations):**
- System tray
- Media player controls
- Notification center toggle
- Battery indicator
- Click-to-expand drawers
- Multi-monitor support (uses default monitor for now)
