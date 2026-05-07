import { App, Astal, Gdk } from "astal/gtk4"
import Workspaces from "./Workspaces"
import WindowTitle from "./WindowTitle"
import SysInfo from "./SysInfo"

export default function Bar(monitor: Gdk.Monitor) {
  return (
    <window
      cssClasses={["bar"]}
      namespace="zen0x"
      gdkmonitor={monitor}
      application={App}
      visible={true}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT
      }
    >
      <box cssClasses={["bar-inner"]} hexpand={true}>
        <centerbox hexpand={true}>
          <Workspaces />
          <WindowTitle />
          <SysInfo />
        </centerbox>
      </box>
    </window>
  )
}
