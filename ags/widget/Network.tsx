import { bind, subprocess, Variable } from "astal"
import Network from "gi://AstalNetwork?version=0.1"

const WIFI_ICONS = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

export default function NetworkIcon() {
  const net = Network.get_default()

  const icon = Variable.derive(
    [bind(net, "primary"), bind(net, "wifi")],
    (primary, wifi) => {
      if (primary === Network.Primary.ETHERNET) return "󰀂"
      if (primary === Network.Primary.WIFI && wifi) {
        const idx = Math.min(Math.floor((wifi.strength / 100) * 5), 4)
        return WIFI_ICONS[idx]
      }
      return "󰤮"
    },
  )

  return (
    <button
      cssClasses={["network"]}
      tooltipText={bind(net, "wifi").as((w) => w?.ssid || "No connection")}
      onClicked={() => subprocess(["nm-connection-editor"])}
      onDestroy={() => icon.drop()}
    >
      <label label={icon()} />
    </button>
  )
}
