import { bind, subprocess } from "astal"
import { Gtk } from "astal/gtk4"
import Wp from "gi://AstalWp?version=0.1"

export default function Volume() {
  const speaker = Wp.get_default()?.audio?.defaultSpeaker
  if (!speaker) return <label cssClasses={["volume"]} label="󰕾" />

  return (
    <button
      cssClasses={["volume"]}
      tooltipText={bind(speaker, "volume").as((v) => `Volume: ${Math.round(v * 100)}%`)}
      onClicked={() => subprocess(["pavucontrol"])}
      setup={(self) => {
        const rightClick = new Gtk.GestureClick()
        rightClick.set_button(3)
        rightClick.connect("released", () => { speaker.mute = !speaker.mute })
        self.add_controller(rightClick)

        const scroll = new Gtk.EventControllerScroll()
        scroll.set_flags(Gtk.EventControllerScrollFlags.VERTICAL)
        scroll.connect("scroll", (_self, _dx, dy) => {
          speaker.volume = Math.max(0, Math.min(1, speaker.volume - dy * 0.05))
        })
        self.add_controller(scroll)
      }}
    >
      <label label={bind(speaker, "mute").as((muted) => (muted ? "󰝟" : "󰕾"))} />
    </button>
  )
}
