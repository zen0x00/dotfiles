import { bind } from "astal"
import Wp from "gi://AstalWp?version=0.1"

export default function Volume() {
  const speaker = Wp.get_default()?.audio?.defaultSpeaker
  if (!speaker) return <label cssClasses={["volume"]} label="󰕾" />

  return (
    <label
      cssClasses={["volume"]}
      label={bind(speaker, "mute").as((muted) => (muted ? "󰝟" : "󰕾"))}
      tooltipText={bind(speaker, "volume").as(
        (v) => `Volume: ${Math.round(v * 100)}%`,
      )}
    />
  )
}
