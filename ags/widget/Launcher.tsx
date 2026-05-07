import { Variable } from "astal"
import { App, Astal, Gdk, Gtk } from "astal/gtk4"
import AstalApps from "gi://AstalApps?version=0.1"

const apps = new AstalApps.Apps()

function AppItem({ app, onSelect }: { app: AstalApps.Application; onSelect: () => void }) {
  return (
    <button
      cssClasses={["launcher-item"]}
      onClicked={() => {
        app.launch()
        onSelect()
      }}
    >
      <box spacing={10}>
        <image iconName={app.iconName} pixelSize={22} />
        <box vertical={true} valign={Gtk.Align.CENTER} spacing={1}>
          <label
            cssClasses={["launcher-app-name"]}
            label={app.name}
            halign={Gtk.Align.START}
            ellipsize={3}
            maxWidthChars={32}
          />
          {app.description ? (
            <label
              cssClasses={["launcher-app-desc"]}
              label={app.description}
              halign={Gtk.Align.START}
              ellipsize={3}
              maxWidthChars={40}
            />
          ) : <box />}
        </box>
      </box>
    </button>
  )
}

export default function Launcher(monitor: Gdk.Monitor) {
  const query = Variable("")
  const visible = Variable(false)

  let entry: Gtk.Entry | null = null

  const results = query((q) =>
    q.trim() === ""
      ? apps.list.slice(0, 8)
      : apps.fuzzy_query(q).slice(0, 8),
  )

  function show() {
    query.set("")
    visible.set(true)
  }

  function hide() {
    visible.set(false)
    query.set("")
  }

  const win = (
    <window
      cssClasses={["launcher"]}
      name="zen0x-launcher"
      namespace="zen0x-launcher"
      gdkmonitor={monitor}
      application={App}
      visible={visible()}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      anchor={0}
      setup={(self) => {
        self.connect("show", () => {
          entry?.set_text("")
          entry?.grab_focus()
        })
      }}
    >
      <box cssClasses={["launcher-box"]} vertical={true} spacing={4}>
        <entry
          cssClasses={["launcher-entry"]}
          placeholderText="Search apps…"
          onChanged={(self) => query.set(self.text)}
          setup={(self) => { entry = self }}
          onActivate={() => {
            const list = query.get().trim() === ""
              ? apps.list.slice(0, 8)
              : apps.fuzzy_query(query.get()).slice(0, 8)
            if (list[0]) {
              list[0].launch()
              hide()
            }
          }}
        />
        <box cssClasses={["launcher-results"]} vertical={true} spacing={2}>
          {results.as((list) => list.map((app) => (
            <AppItem app={app} onSelect={hide} />
          )))}
        </box>
      </box>
    </window>
  ) as Astal.Window & { __show: () => void; __hide: () => void }

  win.__show = show
  win.__hide = hide

  const keyController = new Gtk.EventControllerKey()
  keyController.connect("key-pressed", (_self, keyval: number) => {
    if (keyval === Gdk.KEY_Escape) hide()
    return false
  })
  win.add_controller(keyController)

  return win
}
