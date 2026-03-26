import Quickshell
import Quickshell.Io
import "modules"

ShellRoot {
    id: shell

    IpcHandler {
        target: "shell"
        function reload(): void { Quickshell.reload(); }
    }

    Launcher {}
    AppMenu {}
    IslandBar {}
    ZenMenu {}
    NotificationPopup {}
    Osd {}
    PowerMenu {}
}
