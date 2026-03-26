import Quickshell
import Quickshell.Io
import "modules"

ShellRoot {
    id: shell

    property string activeBar: "island"
    property string activeMode: "eye-candy"  // "eye-candy" or "minimal"

    IpcHandler {
        target: "bar"
        function switchToIsland(): void { shell.activeBar = "island"; }
        function switchToClassic(): void { shell.activeBar = "classic"; }
        function toggle(): void { shell.activeBar = shell.activeBar === "island" ? "classic" : "island"; }
    }

    IpcHandler {
        target: "mode"
        function setMode(mode: string): void { shell.activeMode = mode; }
        function getMode(): string { return shell.activeMode; }
    }

    IpcHandler {
        target: "shell"
        function reload(): void { Quickshell.reload(); }
    }

    Launcher {}
    Bar { visible: shell.activeBar === "classic" }
    IslandBar { visible: shell.activeBar === "island" }
    IslandTray { visible: shell.activeBar === "island" }
    ZenMenu {}
    NotificationPopup {}
    Osd {}
    PowerMenu {}
}
