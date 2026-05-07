import { bind } from "astal"
import { Gtk } from "astal/gtk4"
import Tray from "gi://AstalTray?version=0.1"

const tray = Tray.get_default()

function TrayItem({ item }: { item: InstanceType<typeof Tray.TrayItem> }) {
  return (
    <menubutton
      cssClasses={["tray-item"]}
      tooltipMarkup={bind(item, "tooltipMarkup")}
      usePopover={false}
      menuModel={bind(item, "menuModel")}
      setup={(self) => {
        bind(item, "actionGroup").subscribe((ag) => {
          self.insert_action_group("dbusmenu", ag)
        })
        self.insert_action_group("dbusmenu", item.actionGroup)
        self.connect("notify::active", () => {
          if (self.active) item.about_to_show()
        })
      }}
    >
      <image gicon={bind(item, "gicon")} pixelSize={16} />
    </menubutton>
  )
}

export default function SystemTray() {
  return (
    <box cssClasses={["tray"]} spacing={2}>
      {bind(tray, "items").as((items) =>
        items.map((item) => <TrayItem item={item} />),
      )}
    </box>
  )
}
