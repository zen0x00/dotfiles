import Quickshell
import Quickshell.Io
import "modules"

ShellRoot {
    id: shell

    property string activeBar: "island"

    IpcHandler {
        target: "bar"
        function switchToIsland(): void { shell.activeBar = "island"; }
        function switchToClassic(): void { shell.activeBar = "classic"; }
        function toggle(): void { shell.activeBar = shell.activeBar === "island" ? "classic" : "island"; }
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
