import GLib from "gi://GLib"
import { App } from "astal/gtk4"
import Bar from "./widget/Bar"
import Launcher from "./widget/Launcher"
import NotificationPopup from "./widget/NotificationPopup"
import NotificationCenter from "./widget/NotificationCenter"
import Osd from "./widget/Osd"

const HOME = GLib.get_home_dir()

function loadCss() {
  App.apply_css(`${HOME}/.config/ags/colors.css`, true)
  App.apply_css(`${HOME}/.config/ags/style/bar.css`, false)
  App.apply_css(`${HOME}/.config/ags/style/launcher.css`, false)
  App.apply_css(`${HOME}/.config/ags/style/notifications.css`, false)
  App.apply_css(`${HOME}/.config/ags/style/osd.css`, false)
}

App.start({
  instanceName: "zen0x",
  requestHandler(request, res) {
    if (request === "reload-css") {
      loadCss()
      res("ok")
    } else if (request === "toggle-launcher") {
      const win = App.get_window("zen0x-launcher")
      if (win) win.visible ? (win as any).__hide() : (win as any).__show()
      res("ok")
    } else if (request === "toggle-nc") {
      const win = App.get_window("zen0x-nc")
      if (win) win.visible = !win.visible
      res("ok")
    } else {
      res("unknown request")
    }
  },
  main() {
    loadCss()
    const monitors = App.get_monitors()
    monitors.map(Bar)
    monitors.map(Launcher)
    monitors.map(NotificationPopup)
    monitors.map(NotificationCenter)
    monitors.map(Osd)
  },
})
