import GLib from "gi://GLib"
import { App } from "astal/gtk4"
import Bar from "./widget/Bar"

const HOME = GLib.get_home_dir()

function loadCss() {
  App.apply_css(`${HOME}/.config/ags/colors.css`, true)
  App.apply_css(`${HOME}/.config/ags/style/bar.css`, false)
}

App.start({
  instanceName: "zen0x",
  requestHandler(request, res) {
    if (request === "reload-css") {
      loadCss()
      res("ok")
    } else {
      res("unknown request")
    }
  },
  main() {
    loadCss()
    App.get_monitors().map(Bar)
  },
})
