import { bind } from "astal"
import Hyprland from "gi://AstalHyprland?version=0.1"

const hypr = Hyprland.get_default()

export default function WindowTitle() {
  return (
    <label
      cssClasses={["window-title"]}
      label={bind(hypr, "focusedClient").as(
        (c) => c?.title?.slice(0, 60) || "Desktop",
      )}
      maxWidthChars={60}
      ellipsize={3}
    />
  )
}
