import { bind, Variable } from "astal"
import Battery from "gi://AstalBattery?version=0.1"

const ICONS = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

export default function BatteryIcon() {
  const bat = Battery.get_default()
  if (!bat) return <box />

  const icon = Variable.derive(
    [bind(bat, "percentage"), bind(bat, "charging"), bind(bat, "isPresent")],
    (pct, charging, present) => {
      if (!present) return ""
      if (charging) return "󰂄"
      return ICONS[Math.min(Math.floor(pct * 10), 9)]
    },
  )

  const cls = Variable.derive(
    [bind(bat, "percentage"), bind(bat, "charging")],
    (pct, charging) => {
      if (charging) return ["battery", "charging"]
      if (pct < 0.15) return ["battery", "critical"]
      if (pct < 0.3) return ["battery", "warning"]
      return ["battery"]
    },
  )

  return (
    <label
      cssClasses={cls()}
      label={icon()}
      tooltipText={bind(bat, "percentage").as(
        (p) => `${Math.round(p * 100)}%`,
      )}
      onDestroy={() => {
        icon.drop()
        cls.drop()
      }}
    />
  )
}
