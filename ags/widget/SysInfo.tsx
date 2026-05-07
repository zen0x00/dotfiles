import { subprocess } from "astal"
import SystemTray from "./Tray"
import Volume from "./Volume"
import NetworkIcon from "./Network"
import BatteryIcon from "./Battery"
import Clock from "./Clock"

export default function SysInfo() {
  return (
    <box cssClasses={["sys-info"]} halign={2} spacing={0}>
      <SystemTray />
      <Volume />
      <NetworkIcon />
      <BatteryIcon />
      <Clock />
      <button
        cssClasses={["cc-button"]}
        onClicked={() => subprocess(["astal", "-i", "zen0x", "toggle-nc"])}
        tooltipText="Notifications"
      >
        <label label="󰂚" />
      </button>
    </box>
  )
}
